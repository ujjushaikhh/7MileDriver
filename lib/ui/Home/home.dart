import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/ui/Home/StartPickup/start_pickup.dart';
import 'package:driverflow/ui/Home/model/accept_rejectmodel.dart';
import 'package:driverflow/ui/Home/model/home_model.dart';
import 'package:driverflow/ui/Home/model/notify_count.dart';
import 'package:driverflow/ui/Home/model/online_offline.dart';
import 'package:driverflow/ui/My%20Profile/myprofile.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/color_constant.dart';
import '../../constant/font_constant.dart';
import '../../constant/image_constant.dart';
import '../../utils/dailog.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';
import '../../utils/textwidget.dart';
import '../Notification/notification.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String? _mapStyle;
  var token = getString('token');
  bool isload = false;
  int? cartId;
  int? notifyCount = 0;

  Future<dynamic> acceptrejectapi(int cartid, int acceptreject) async {
    if (await checkUserConnection()) {
      try {
        var apichange = acceptrejecturl;
        debugPrint('Url: $apichange');

        debugPrint('Token: $token');
        var headers = {
          'authkey': 'Bearer $token',
          'Content-Type': 'application/json',
        };
        var request = http.Request('POST', Uri.parse(apichange));
        request.body =
            json.encode({'cart_id': cartid, "accept_reject": acceptreject});

        debugPrint('Body :-${request.body}');

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var acceptrejectModel = AcceptRejectModel.fromJson(jsonResponse);
        debugPrint(responsed.body);
        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          if (acceptrejectModel.status == 1) {
            debugPrint('Success');
            setState(() {
              setString('custname', acceptrejectModel.userName!.toString());
              setInt('oid', acceptrejectModel.id!);
              setString('enterprisemobilenum',
                  acceptrejectModel.s7mileNumber!.toString());
              setString(
                  'custmobilenum', acceptrejectModel.userMobile!.toString());
              setString('orderid', acceptrejectModel.orderId!.toString());
              setInt('addressid', acceptrejectModel.addressId!);
              setString('houseno', acceptrejectModel.houseNo!.toString());
              setString('landmark', acceptrejectModel.landmark!.toString());
              setString('address', acceptrejectModel.address!.toString());
              setString('zipcode', acceptrejectModel.zipcode!.toString());
            });
            if (acceptrejectModel.message == 'Order rejected') {
              Fluttertoast.showToast(msg: 'Order has been rejected');
              getHomeapi();
            } else {
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyStartPickup()));
            }
          } else {
            if (!mounted) return;
            debugPrint(acceptrejectModel.message);
            vapeAlertDialogue(
              context: context,
              desc: '${acceptrejectModel.message}',
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        } else if (response.statusCode == 401) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${acceptrejectModel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 404) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${acceptrejectModel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            type: AlertType.info,
            desc: '${acceptrejectModel.message}',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ).show();
        }
      } catch (error) {
        // ProgressDialogUtils.dismissProgressDialog();
        debugPrint("$error");

        if (!mounted) return;
        vapeAlertDialogue(
          context: context,
          desc: 'Something went wrong',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      // ProgressDialogUtils.dismissProgressDialog();

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

  Future<dynamic> onlineOfflineapi(int isOnline) async {
    if (await checkUserConnection()) {
      try {
        // if (!mounted) return;
        // ProgressDialogUtils.showProgressDialog(context);

        var apichange = onlineofflineurl;

        debugPrint('Token: $token');
        var headers = {
          'authkey': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        var request = http.Request('POST', Uri.parse(apichange));

        request.body = json.encode({'is_online': isOnline});

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var onlineoffline = OnlineOfflineModel.fromJson(jsonResponse);
        debugPrint(responsed.body);
        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          // ProgressDialogUtils.dismissProgressDialog();
          if (onlineoffline.status == 1) {
            debugPrint('Success');
            if (onlineoffline.isOnline != 0) {
              getHomeapi();
            } else {
              Fluttertoast.showToast(msg: 'You are  offline');
            }
          } else {
            if (!mounted) return;
            debugPrint(onlineoffline.message);
            vapeAlertDialogue(
              context: context,
              desc: '${onlineoffline.message}',
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        } else if (response.statusCode == 401) {
          // ProgressDialogUtils.dismissProgressDialog();

          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${onlineoffline.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else {
          // ProgressDialogUtils.dismissProgressDialog();

          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${onlineoffline.message}',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ).show();
        }
      } catch (error) {
        // ProgressDialogUtils.dismissProgressDialog();
        debugPrint("$error");

        if (!mounted) return;
        vapeAlertDialogue(
          context: context,
          desc: 'Something went wrong',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      // ProgressDialogUtils.dismissProgressDialog();

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

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    handleLocationPermission();
    getLocation();
    getIcons();
    getNotifycountapi();
    _checkGps();
    // createMarkers();
  }

  List<Data> _data = [];

  String? getuserImage;
  String? getuserName;
  String? deliveryLocation;
  String? landmark;
  String? hounseNo;
  String? homenumber;
  String? zipcode;
  int? item;

  Future<void> getNotifycountapi() async {
    if (await checkUserConnection()) {
      try {
        var apiurl = getnotifycounturl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(token);

        var request = http.Request('GET', Uri.parse(apiurl));

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var getNotifyCount = NotifyCountModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          // ProgressDialogUtils.dismissProgressDialog();
          if (getNotifyCount.status == 1) {
            setState(() {
              notifyCount = getNotifyCount.count ?? 0;
            });
            debugPrint('is it success');
          } else {
            debugPrint('failed to load');
          }
        } else if (response.statusCode == 401) {
          // ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {},
          ).show();
        } else if (response.statusCode == 404) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getNotifyCount.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        }
      } catch (e) {
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
        type: AlertType.info,
        desc: 'Please check your internet connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  Future<void> getHomeapi() async {
    if (await checkUserConnection()) {
      try {
        var apiurl = gethomeurl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(token);

        var request = http.Request('GET', Uri.parse(apiurl));

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var getHome = GetHomeModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          // ProgressDialogUtils.dismissProgressDialog();
          if (getHome.status == 1) {
            setState(() {
              _data = getHome.data ?? [];
              if (_data.isNotEmpty) {
                for (var data in _data) {
                  setString('custimage', data.userImage!.toString());
                  getuserImage = data.userImage ?? '';
                  getuserName = data.userName ?? '';
                  deliveryLocation = data.address ?? '';
                  landmark = data.landmark ?? '';
                  zipcode = data.zipcode ?? '';
                  item = data.itemCount ?? 0;
                  hounseNo = data.houseNo ?? '';
                  cartId = data.cartId ?? 0;
                }
              } else {
                debugPrint('NO Data added in _data');
              }

              isload = true;
            });
            debugPrint('is it success');
          } else {
            debugPrint('failed to load');
          }
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getHome.message}',
            onPressed: () {},
          ).show();
        } else if (response.statusCode == 404) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getHome.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getHome.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getHome.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        }
      } catch (e) {
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
        type: AlertType.info,
        desc: 'Please check your internet connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  Future _checkGps() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Geolocator.openLocationSettings().then(
          (_) => Fluttertoast.showToast(msg: 'Please turn on the location'));

      // showDialog(
      //   context: context, // Assuming you have access to the context
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Location Services Disabled'),
      //       content:
      //           const Text('Please enable location services to use this app.'),
      //       actions: [
      //         TextButton(
      //           child: const Text('OK'),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //             Geolocator.openLocationSettings();

      //             // You may choose to navigate to the device settings here
      //             // for the user to enable location services manually.
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    } else {
      debugPrint('Location service is on');
    }
  }

  bool? isSwitch = false;

  // final Completer<GoogleMapController> _completer = Completer();
  // static const LatLng _center = LatLng(45.521563, -122.677433);

  // static const LatLng _defaultLocation = LatLng(45.521563, -122.677433);

  final MapType _currentMapType = MapType.normal;
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  // LatLng _lastMapPosition = _center;
  BitmapDescriptor? icon;
  LocationPermission? permission;
  LatLng? _currentPosition;
  Location? location;

  String getName = getString('name');
  String getImage = getString('userimage');
  //  const LatLng(45.521563, -122.677433);

  bool isLoading = true;
  bool? serviceEnabled;

  // void _onCameraMove(CameraPosition position) {
  //   _lastMapPosition = position.target;
  // }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    debugPrint('$mapController');
  }

  getIcons() async {
    var icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 3.2), icMarker);
    setState(() {
      this.icon = icon;
    });
  }

  // Crear Marker
  createMarkers() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude);

    String address = placemarks.isNotEmpty
        ? '${placemarks[0].postalCode},${placemarks[0].name},${placemarks[0].street},${placemarks[0].thoroughfare} ${placemarks[0].administrativeArea}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].locality}, ${placemarks[0].subLocality}'
        : "Unknown";

    debugPrint('Address :-$address');

    _markers.add(
      Marker(
        markerId: const MarkerId("MarkerCurrent"),
        position: _currentPosition!,
        icon: icon!,
        infoWindow: InfoWindow(title: "You are here", snippet: address),
        // "Lat ${_currentPosition!.latitude} - Lng ${_currentPosition!.longitude}"),
      ),
    );
  }

  getLocation() async {
    permission = await Geolocator.requestPermission();
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );
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
        debugPrint("This is  :- $_currentPosition");
      });
      createMarkers();
    }
  }

  Future<bool> handleLocationPermission() async {
    LocationPermission permission;

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   if (!mounted) {
    //     return false;
    //   }
    //   showDialog(
    //     context: context, // Assuming you have access to the context
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: const Text('Location Services Disabled'),
    //         content:
    //             const Text('Please enable location services to use this app.'),
    //         actions: [
    //           TextButton(
    //             child: const Text('OK'),
    //             onPressed: () {
    //               openAppSettings().then((_) =>
    //                   {Fluttertoast.showToast(msg: 'Please turn on location')});
    //               // You may choose to navigate to the device settings here
    //               // for the user to enable location services manually.
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   return false;
    // }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // if (!mounted) return false;
        Navigator.pop(context);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      openAppSettings().then((_) => Fluttertoast.showToast(
          msg: 'please allow the location permission from the app settings'));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    // debugPrint(' In widget default location :-$_defaultLocation');

    // debugPrint(' In widget default location :-$_currentPosition');
    // debugPrint('Marker : $_markers');
    // LatLng initialLocation = _currentPosition ?? _defaultLocation;

    // debugPrint(' In widget initialLocation:-$initialLocation');
    return Scaffold(
      body: Stack(children: [
        isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                color: greencolor,
              ))
            : GoogleMap(
                // myLocationEnabled: true,
                markers: _markers,
                // onCameraMove: _onCameraMove,
                compassEnabled: false,
                initialCameraPosition:
                    CameraPosition(target: _currentPosition!, zoom: 11.0),
                mapType: _currentMapType,
                onMapCreated: _onMapCreated),
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 64, bottom: 32),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: whitecolor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4)),
                    border:
                        Border.all(width: 1, color: const Color(0xFFEEEEEE))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 10, bottom: 8.0, top: 15.0),
                  child: Row(children: [
                    ClipOval(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contex) => const MyProfile()));
                        },
                        child: CachedNetworkImage(
                          imageBuilder: (context, imageProvider) => Container(
                            height: 35.0,
                            width: 35.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 35.0,
                              width: 35.0,
                              decoration: const BoxDecoration(
                                  color: Colors.grey, shape: BoxShape.circle),
                            ),
                          ),
                          imageUrl: getImage.toString(),
                          height: 35.0,
                          width: 35.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 13.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contex) => const MyProfile()));
                        },
                        child: getTextWidget(
                          title: getName,
                          textFontSize: fontSize18,
                          textFontWeight: fontWeightSemiBold,
                          textColor: background,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        IconButton(
                          icon: Image.asset(icNotification,
                              height: 24, width: 24, color: background),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyNotification(),
                              ),
                            ).whenComplete(() => getNotifycountapi());
                          },
                        ),
                        if (notifyCount! > 0)
                          Positioned(
                            top: 1,
                            right: 3,
                            child: Container(
                                height: 22.0,
                                width: 22.0,
                                decoration: const BoxDecoration(
                                  color: orangecolor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18.0,
                                  minHeight: 18.0,
                                ),
                                child: Center(
                                  child: Text(
                                    notifyCount!.toString(),
                                    style: const TextStyle(
                                      color: whitecolor,
                                      fontSize: fontSize13,
                                      fontFamily: fontfamilybeVietnam,
                                      fontWeight: fontWeightSemiBold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          )
                        // : Container(),
                      ],
                    )
                  ]),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Color(0xffEEEEEE),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 12.0, right: 10, left: 15, bottom: 12.0),
                  child: Row(
                    children: [
                      getTextWidget(
                          title: isSwitch! == false
                              ? 'You are Offline'
                              : 'You are Online',
                          textFontSize: fontSize14,
                          textFontWeight: fontWeightRegular,
                          textColor: background),
                      Expanded(
                          child: Align(
                        alignment: Alignment.centerRight,
                        child: _getOfflineButton(),
                      ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
            child: isSwitch == false
                ? Container(
                    height: 250,
                    decoration: BoxDecoration(
                        color: whitecolor,
                        border: Border.all(
                            width: 1, color: const Color(0xFFD1D1D1)),
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 27.0, bottom: 26.0, left: 20.0, right: 20.0),
                      child: Column(
                        children: [
                          Image.asset(
                            icNoDeliveries,
                            width: 188,
                            height: 97,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 31.0),
                            child: getTextWidget(
                                title: 'No Delivery Requests',
                                textFontSize: fontSize17,
                                textFontWeight: fontWeightSemiBold,
                                textColor: background),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 6.0, left: 36, right: 36),
                            child: getTextWidget(
                                textAlign: TextAlign.center,
                                title:
                                    'Kindly make your status online to accept new deliveries.',
                                textFontSize: fontSize13,
                                textFontWeight: fontWeightRegular,
                                textColor: background),
                          )
                        ],
                      ),
                    ),
                  )
                : isload != true
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.transparent,
                        ),
                      )
                    : _data.isEmpty
                        ? Container(
                            height: 250,
                            width: screenSize!.width - 20,
                            decoration: BoxDecoration(
                                color: whitecolor,
                                border: Border.all(
                                    width: 1, color: const Color(0xFFD1D1D1)),
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 27.0,
                                  bottom: 26.0,
                                  left: 20.0,
                                  right: 20.0),
                              child: Column(
                                children: [
                                  Image.asset(
                                    icNoDeliveries,
                                    width: 188,
                                    height: 97,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 31.0),
                                    child: getTextWidget(
                                        title: 'No Delivery Requests',
                                        textFontSize: fontSize17,
                                        textFontWeight: fontWeightSemiBold,
                                        textColor: background),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 6.0, left: 36, right: 36),
                                    child: getTextWidget(
                                        textAlign: TextAlign.center,
                                        title: 'No orders are there',
                                        textFontSize: fontSize13,
                                        textFontWeight: fontWeightRegular,
                                        textColor: background),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: whitecolor,
                                    border: Border.all(
                                        width: 1,
                                        color: const Color(0xFFD1D1D1)),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 17.0,
                                      left: 15.0,
                                      right: 15.0,
                                      bottom: 21.0),
                                  child: Column(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      getTextWidget(
                                          title: 'N  E  W       O  R  D  E  R ',
                                          textFontSize: fontSize13,
                                          textFontWeight: fontWeightRegular,
                                          textColor: background),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Row(children: [
                                          ClipOval(
                                            child: CachedNetworkImage(
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                height: 35.0,
                                                width: 35.0,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  height: 35.0,
                                                  width: 35.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.grey,
                                                          shape:
                                                              BoxShape.circle),
                                                ),
                                              ),
                                              imageUrl: getuserImage.toString(),
                                              height: 35.0,
                                              width: 35.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 13.0),
                                            child: getTextWidget(
                                              title: getuserName!.toString(),
                                              textFontSize: fontSize18,
                                              textFontWeight:
                                                  fontWeightSemiBold,
                                              textColor: background,
                                            ),
                                          ),
                                          Expanded(
                                              child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  acceptrejectapi(cartId!, 2);
                                                },
                                                child: Image.asset(
                                                  icCross,
                                                  height: 49,
                                                  width: 49,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 11,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  acceptrejectapi(cartId!, 1);
                                                },
                                                child: Image.asset(
                                                  icRight,
                                                  height: 49,
                                                  width: 49,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ))
                                        ]),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, top: 9),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              icLocation,
                                              height: 77,
                                              width: 10,
                                              fit: BoxFit.cover,
                                            ),
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 24.0, top: 4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    getTextWidget(
                                                        title:
                                                            'Pickup Location',
                                                        textFontSize:
                                                            fontSize13,
                                                        textFontWeight:
                                                            fontWeightRegular,
                                                        textColor: const Color(
                                                            0xFF6C7381)),
                                                    const SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    getTextWidget(
                                                        maxLines: 3,
                                                        title:
                                                            '2464 Royal Ln. Mesa, New Jersey 45463',
                                                        textFontSize:
                                                            fontSize13,
                                                        textFontWeight:
                                                            fontWeightMedium,
                                                        textColor: background),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20.0),
                                                      child: getTextWidget(
                                                          title:
                                                              'Delivery Location',
                                                          textFontSize:
                                                              fontSize13,
                                                          textFontWeight:
                                                              fontWeightRegular,
                                                          textColor:
                                                              const Color(
                                                                  0xFF6C7381)),
                                                    ),
                                                    const SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    getTextWidget(
                                                        title:
                                                            '$hounseNo, $landmark , $deliveryLocation , $zipcode',
                                                        textFontSize:
                                                            fontSize13,
                                                        maxLines: 3,
                                                        textFontWeight:
                                                            fontWeightMedium,
                                                        textColor: background)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: background,
                                    border:
                                        Border.all(width: 1, color: background),
                                    borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(4))),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'No.of Items: ',
                                          style: const TextStyle(
                                            fontSize: fontSize13,
                                            fontWeight: fontWeightMedium,
                                            fontFamily: fontfamilybeVietnam,
                                            color: Color(0xFFB0B8C5),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: item!.toString(),
                                              style: const TextStyle(
                                                fontSize: fontSize13,
                                                fontWeight: fontWeightMedium,
                                                fontFamily: fontfamilybeVietnam,
                                                color:
                                                    whitecolor, // Change the color as needed
                                                // Add other style properties as needed
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: const TextSpan(
                                          text: 'Delivery by: ',
                                          style: TextStyle(
                                            fontSize: fontSize13,
                                            fontFamily: fontfamilybeVietnam,
                                            fontWeight: fontWeightMedium,
                                            color: Color(0xFFB0B8C5),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '2:00 pm',
                                              style: TextStyle(
                                                fontSize: fontSize13,
                                                fontWeight: fontWeightMedium,
                                                fontFamily: fontfamilybeVietnam,
                                                color: whitecolor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
          ),
        ),
      ]),
    );
  }

  Widget _getOfflineButton() {
    return SizedBox(
      width: 60,
      height: 37,
      child: CupertinoSwitch(
        value: isSwitch!,
        activeColor: orangecolor,
        trackColor: trackcolor,
        onChanged: (value) {
          if (isSwitch == true) {
            setState(() {
              // setBool('notification', false);
              isSwitch = false;
              onlineOfflineapi(0);
              // settingapi();
            });
          } else {
            setState(() {
              // setBool('notification', true);
              isSwitch = true;

              onlineOfflineapi(1);
              // settingapi();
            });
          }
        },
      ),
    );
  }
}
