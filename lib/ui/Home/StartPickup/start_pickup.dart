import 'dart:async';
import 'dart:convert';

import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Collect%20Items/collect_item.dart';
import 'package:driverflow/ui/Home/model/delivery_status.dart';
import 'package:driverflow/ui/Item%20Summary/item_summary.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constant/color_constant.dart';
import '../../../constant/font_constant.dart';
import '../../../utils/button.dart';
import '../../../utils/dailog.dart';
import '../../../utils/internetconnection.dart';
import '../../../utils/progressdialogue.dart';
import '../../../utils/textwidget.dart';

class MyStartPickup extends StatefulWidget {
  const MyStartPickup({
    super.key,
  });

  @override
  State<MyStartPickup> createState() => _MyStartPickupState();
}

class _MyStartPickupState extends State<MyStartPickup> {
  String? enterprisenumber = getString('enterprisemobilenum');
  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    // getCurrentLocation();

    debugPrint('number:- $enterprisenumber');

    getLocation();
  }

  bool isViewed = false;
  bool isLoading = true;
  // bool? isServiceEnabled;

  LatLng? _currentPosition;
  LocationPermission? permission;
  final MapType _currentMapType = MapType.normal;
  String? _mapStyle;
  // final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    debugPrint('$mapController');
  }

  BitmapDescriptor? currentDestination;
  BitmapDescriptor? pickupDestination;

  StreamController<LatLng> streamController = StreamController();
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyB-s7cqmVufTKO1Rp2amMq8tdmEKVMVE-U";

  List<LatLng> polylineCoordinates = [];

  // final double _originLatitude = 23.0225;
  // final double _originLongitude = 72.5714;
  final double _destLatitude = 23.2156;
  final double _destLongitude = 72.6369;

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) async {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;
  }

  _getIcon() async {
    var currentdestination = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.4), icVehicle);

    var pickupdestination = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.4), icPickup);

    setState(() {
      currentDestination = currentdestination;
      pickupDestination = pickupdestination;
      _addMarker(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        "origin",
        currentDestination!,
      );

      /// destination marker
      _addMarker(
        LatLng(_destLatitude, _destLongitude),
        "destination",
        pickupDestination!,
      );
    });

    debugPrint('currentDestination ${currentDestination.toString()}');
    debugPrint('pickupDestination ${pickupDestination.toString()}');
  }

  getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      debugPrint("Polyline Coordinates: $polylineCoordinates");
    } else {
      debugPrint('The Error  of Polyline ${result.errorMessage}');
    }
    _addPolyLine();
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        width: 5,
        polylineId: id,
        color: greencolor,
        points: polylineCoordinates);
    polylines[id] = polyline;

    setState(() {});
  }

  Future<void> deliverystatusapi(int pickUp, int isCollect) async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);
      try {
        var apiurl = deliverystatusurl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(getString('token'));

        var request = http.Request('POST', Uri.parse(apiurl));

        request.body = json.encode({
          'order_id': getInt('oid'),
          'is_pickup': pickUp,
          'is_collect': isCollect,
          'is_ofd': 0
        });

        debugPrint(request.body);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var deliveryStaus = DeliveryStatusModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (deliveryStaus.status == 1) {
            setState(() {
              debugPrint(deliveryStaus.message);
            });
            debugPrint('is it success');
          } else {
            debugPrint('failed to load');
            ProgressDialogUtils.dismissProgressDialog();
          }
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${deliveryStaus.message}',
            onPressed: () {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (context) => LoginScreen()),
              //     (route) => false);
            },
          ).show();
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${deliveryStaus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${deliveryStaus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${deliveryStaus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        }
      } catch (e) {
        ProgressDialogUtils.dismissProgressDialog();
        debugPrint("$e");
        if (!mounted) return;
        vapeAlertDialogue(
          context: context,
          desc: '$e',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      if (!mounted) return;
      vapeAlertDialogue(
        context: context,
        desc: 'Check Internet Connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  // Future<void> camerToposition(LatLng pos) async {
  //   final GoogleMapController goolecontroller = await _controller.future;
  //   CameraPosition newcamerapposition = CameraPosition(target: pos, zoom: 13);

  //   await goolecontroller
  //       .animateCamera(CameraUpdate.newCameraPosition(newcamerapposition));
  // }

  // Future<void> getCurrentLocation() async {
  //   Location location = Location();
  //   bool serviceEnable;
  //   PermissionStatus permissionStatus;

  //   serviceEnable = await location.serviceEnabled();
  //   if (serviceEnable) {
  //     serviceEnable = await location.requestService();
  //   } else {
  //     return;
  //   }

  //   permissionStatus = await location.hasPermission();
  //   if (permissionStatus == PermissionStatus.denied) {
  //     permissionStatus = await location.requestPermission();
  //     if (permissionStatus == PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   location.onLocationChanged.listen((currentlocation) {
  //     if (currentlocation.latitude != null &&
  //         currentlocation.longitude != null) {
  //       setState(() {
  //         _currentPosition =
  //             LatLng(currentlocation.latitude!, currentlocation.longitude!);
  //         debugPrint("$_currentPosition");
  //         isLoading = false;

  //         camerToposition(_currentPosition!);
  //         _addMarker(
  //           LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
  //           "currentposition",
  //           currentposition,
  //         );
  //       });
  //       print('Successfully get location');
  //     } else {
  //       debugPrint("the Error is there ");
  //     }
  //   });
  //   // try {
  //   //   await location.getLocation().then(
  //   //     (locationData) {
  //   //       _currentPosition = locationData;
  //   //     },
  //   //   );

  //   //   debugPrint(
  //   //       ' current position :-${_currentPosition!.latitude} , ${_currentPosition!.longitude}');

  //   //   GoogleMapController googleMapController = await _controller.future;
  //   //   location.onLocationChanged.listen(
  //   //     (newLoc) {
  //   //       _currentPosition = newLoc;
  //   //       googleMapController.animateCamera(
  //   //         CameraUpdate.newCameraPosition(
  //   //           CameraPosition(
  //   //             zoom: 13.5,
  //   //             target: LatLng(
  //   //               newLoc.latitude!,
  //   //               newLoc.longitude!,
  //   //             ),
  //   //           ),
  //   //         ),
  //   //       );
  //   //       setState(() {
  //   //         isLoading = false;
  //   //       });
  //   //     },
  //   //   );
  //   // } catch (e) {
  //   //   debugPrint('Error fetching location: $e');
  //   //   // Handle the error as needed, e.g., show an error message to the user
  //   //   setState(() {
  //   //     isLoading = false;
  //   //   });
  //   // }
  // }

  getLocation() async {
    // permission = await Geolocator.requestPermission();

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
          timeLimit: const Duration(seconds: 15));
    } catch (e) {
      position = null;
      debugPrint('$e');
    }

    if (position != null) {
      double lat = position.latitude;
      double long = position.longitude;

      LatLng location = LatLng(lat, long);
      debugPrint('Location :- $location');

      setState(() {
        _currentPosition = location;
        isLoading = false;
        debugPrint("This is Current Position :- $_currentPosition");

        streamController.add(_currentPosition!);
        getPolyline();
        _getIcon();
      });

      // createMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: greencolor,
                  ),
                )
              : GoogleMap(
                  // myLocationEnabled: true,
                  // markers: _markers,
                  // onCameraMove: _onCameraMove,
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                  compassEnabled: false,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 11.0),
                  mapType: _currentMapType,
                  onMapCreated: _onMapCreated,
                  onCameraMove: (CameraPosition pos) {
                    streamController.add(pos.target);
                  },
                  // onMapCreated: (mapController) {
                  //   mapController.setMapStyle(_mapStyle);
                  //   _controller.complete(mapController);
                  // }
                ),
          Padding(
            padding: const EdgeInsets.only(top: 64.0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 49,
                    height: 49,
                    child: Image.asset(
                      icCircleback,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    icCircleHome,
                    width: 49,
                    height: 49,
                  ),
                )
              ],
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.only(bottom: 11.0, left: 16, right: 16.0),
              child: isViewed == true
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4)),
                              border: Border.all(
                                  width: 1, color: const Color(0xFFD1D1D1)),
                              color: whitecolor),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 19.0, left: 15, right: 15, bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        getTextWidget(
                                            title: '7 Mile Vape hut',
                                            textColor: background,
                                            textFontWeight: fontWeightSemiBold),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        getTextWidget(
                                            title:
                                                'Order ID: ${getString('orderid')}',
                                            textColor: const Color(0xFF6C7381))
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        // Uri phone = Uri.parse(
                                        //     getString(''));
                                        _makePhoneCall(
                                            getString('enterprisemobilenum'));

                                        // if (await launchUrl(phone)) {

                                        //   debugPrint('DialPad open');
                                        // } else {
                                        //   debugPrint(
                                        //       'Failed to open dial open pad ');
                                        // }
                                      },
                                      child: Image.asset(
                                        icCall,
                                        width: 49,
                                        height: 49,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 9.0),
                                  child: getTextWidget(
                                      title: 'Pickup Location',
                                      textFontSize: fontSize13,
                                      textColor: const Color(0xFF6C7381),
                                      textFontWeight: fontWeightRegular),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                getTextWidget(
                                    title:
                                        '2464 Royal Ln. Mesa, New Jersey 45463',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightMedium,
                                    textColor: background),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyItemSummary()));
                          },
                          child: Container(
                              padding: const EdgeInsets.only(
                                  top: 13.0, bottom: 13.0),
                              decoration: const BoxDecoration(
                                  color: background,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4))),
                              child: Center(
                                child: getTextWidget(
                                    title: 'View Order Summary',
                                    textFontSize: fontSize15,
                                    textFontWeight: fontWeightBold,
                                    textColor: greencolor),
                              )),
                        ),
                      ],
                    )
                  : Container())
        ],
      ),
      bottomNavigationBar: SizedBox(
        // height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isViewed == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    color: background,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 12.0),
                            child: getTextWidget(
                                title: 'You have one pending request',
                                textColor: const Color(0xFFB0B8C5),
                                textFontSize: fontSize13,
                                textFontWeight: fontWeightMedium),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 13.0, bottom: 13.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isViewed = true;
                                });
                              },
                              child: getTextWidget(
                                title: 'View',
                                textFontSize: fontSize15,
                                textFontWeight: fontWeightBold,
                                textColor: greencolor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTextWidget(
                          title: 'Pickup Location',
                          textFontSize: fontSize13,
                          textFontWeight: fontWeightRegular,
                          textColor: const Color(0xFF6C7381)),
                      const SizedBox(
                        height: 4.0,
                      ),
                      getTextWidget(
                          title: '2464 Royal Ln. Mesa',
                          textFontSize: fontSize13,
                          textFontWeight: fontWeightMedium,
                          textColor: background),
                    ],
                  ),
                  isViewed == false
                      ? CustomizeButton(
                          text: 'Start Pickup',
                          onPressed: () {
                            setState(() {
                              isViewed = true;
                              deliverystatusapi(1, 0);
                            });
                            // Navigator.push(

                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (contex) => const MyItemSummary()));
                          },
                          buttonWidth: MediaQuery.of(context).size.width / 2.5,
                        )
                      : CustomizeButton(
                          text: 'Collect Items',
                          onPressed: () {
                            deliverystatusapi(1, 1).then((_) => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MyCollectItems()))
                                });
                          },
                          buttonWidth: MediaQuery.of(context).size.width / 2.5,
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
