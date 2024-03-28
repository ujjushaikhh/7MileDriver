import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Home/Delivered/model/sendotp_model.dart';
import 'package:driverflow/ui/Home/home.dart';
import 'package:driverflow/ui/Item%20Summary/item_summary.dart';
import 'package:driverflow/ui/Otp/model/verifyotpmodel.dart';
import 'package:driverflow/ui/Pop%20ups/Congratulation%20Pop%20up/congratulation_screen.dart';
import 'package:driverflow/utils/progressdialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../constant/api_constant.dart';
import '../../../constant/color_constant.dart';
import '../../../constant/font_constant.dart';
import '../../../utils/button.dart';
import '../../../utils/dailog.dart';
import '../../../utils/internetconnection.dart';
import '../../../utils/sharedprefs.dart';
import '../../../utils/textwidget.dart';

class MyDelivered extends StatefulWidget {
  const MyDelivered({super.key});

  @override
  State<MyDelivered> createState() => _MyDeliveredState();
}

class _MyDeliveredState extends State<MyDelivered> {
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    getLocation();
    // Future.delayed(const Duration(seconds: 4), () {
    //   showCustomerCode(context);
    // });
  }

  bool isViewed = false;

  String? _mapStyle;
  LatLng? _currentPosition;
  LocationPermission? permission;
  bool isLoading = true;
  TextEditingController otpController = TextEditingController();
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyB-s7cqmVufTKO1Rp2amMq8tdmEKVMVE-U";

  List<LatLng> polylineCoordinates = [];
  BitmapDescriptor? currentDestination;
  BitmapDescriptor? pickupDestination;
  final double _destLatitude = 23.2156;
  final double _destLongitude = 72.6369;
  final MapType _currentMapType = MapType.normal;
  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    print('$mapController');
  }

  Future<dynamic> verifyotpapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);
      try {
        var apichange = verifyotpapiurl;
        debugPrint('Url: $apichange');

        debugPrint('Token: ${getString('token')}');
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };
        var request = http.Request('POST', Uri.parse(apichange));
        request.body = json.encode(
            {"id": getInt('oid'), "otp": otpController.text.toString()});

        debugPrint(request.body);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var verifyotpapi = VerifyOtpModel.fromJson(jsonResponse);

        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);
        debugPrint(responsed.body);

        if (response.statusCode == 200) {
          ProgressDialogUtils.dismissProgressDialog();
          debugPrint(responsed.body);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyCongratualtion()));
        } else if (response.statusCode == 401) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${verifyotpapi.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${verifyotpapi.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 404) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${verifyotpapi.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            type: AlertType.info,
            desc: '${verifyotpapi.message}',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ).show();
        }
      } catch (error) {
        // ProgressDialogUtils.dismissProgressDialog();
        ProgressDialogUtils.dismissProgressDialog();
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
      if (!mounted) return;
      ProgressDialogUtils.dismissProgressDialog();
      vapeAlertDialogue(
        context: context,
        desc: 'Check Internet Connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  Future<dynamic> sendotpapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);
      try {
        var apichange = sendotpurl;
        debugPrint('Url: $apichange');

        debugPrint('Token: ${getString('token')}');
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };
        var request = http.Request('POST', Uri.parse(apichange));
        request.body = json.encode({"id": getInt('oid')});

        debugPrint(request.body);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var sendotpapi = SendOtpModel.fromJson(jsonResponse);

        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);
        debugPrint(responsed.body);

        if (response.statusCode == 200) {
          ProgressDialogUtils.dismissProgressDialog();
          debugPrint(responsed.body);
          if (!mounted) return;
          showCustomerCode(context);
        } else if (response.statusCode == 401) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${sendotpapi.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${sendotpapi.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 404) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${sendotpapi.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            type: AlertType.info,
            desc: '${sendotpapi.message}',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ).show();
        }
      } catch (error) {
        // ProgressDialogUtils.dismissProgressDialog();
        ProgressDialogUtils.dismissProgressDialog();
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
      if (!mounted) return;
      ProgressDialogUtils.dismissProgressDialog();
      vapeAlertDialogue(
        context: context,
        desc: 'Check Internet Connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

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
        const ImageConfiguration(devicePixelRatio: 2.4), icDestination);

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

  getLocation() async {
    permission = await Geolocator.requestPermission();

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
      print('Location :- $location');

      setState(() {
        _currentPosition = location;
        isLoading = false;
        debugPrint("This is  :- $_currentPosition");
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
          isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(
                    color: greencolor,
                  ),
                )
              : GoogleMap(
                  // myLocationEnabled: true,
                  // markers: _markers,
                  // onCameraMove: _onCameraMove,
                  compassEnabled: false,
                  markers: Set<Marker>.of(markers.values),
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition:
                      CameraPosition(target: _currentPosition!, zoom: 11.0),
                  mapType: _currentMapType,
                  onMapCreated: _onMapCreated),
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
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MyHome()),
                        (route) => false);
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
              child: Column(
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
                          top: 15.0, left: 15, right: 15, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageBuilder: (context, imageProvider) =>
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
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 35.0,
                                      width: 35.0,
                                      decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle),
                                    ),
                                  ),
                                  imageUrl: getString('custimage'),
                                  height: 35.0,
                                  width: 35.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 13.0),
                                child: getTextWidget(
                                    title: getString('custname'),
                                    textColor: background,
                                    textFontWeight: fontWeightSemiBold),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      _makePhoneCall(
                                          getString('custmobilenum'));
                                    },
                                    child: Image.asset(
                                      icCall,
                                      width: 49,
                                      height: 49,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 51),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getTextWidget(
                                    title: 'Delivery Location',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightRegular,
                                    textColor: const Color(0xFF6C7381)),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                getTextWidget(
                                    maxLines: 2,
                                    title:
                                        '${getString('houseno')} , ${getString('landmark')} , ${getString('address')} , ${getString('zipcode')}',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightSemiBold,
                                    textColor: background),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyItemSummary()));
                    },
                    child: Container(
                        padding: const EdgeInsets.only(top: 13.0, bottom: 13.0),
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
              ))
        ],
      ),
      bottomNavigationBar: SizedBox(
        // height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 16.0, right: 16.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getTextWidget(
                            title: 'Delivery Location',
                            textFontSize: fontSize13,
                            textFontWeight: fontWeightRegular,
                            textColor: const Color(0xFF6C7381)),
                        const SizedBox(
                          height: 4.0,
                        ),
                        getTextWidget(
                            maxLines: 3,
                            title:
                                '${getString('houseno')} , ${getString('landmark')} , ${getString('address')} , ${getString('zipcode')}',
                            textFontSize: fontSize13,
                            textFontWeight: fontWeightMedium,
                            textColor: background),
                      ],
                    ),
                  ),
                  CustomizeButton(
                    text: 'Delivered',
                    onPressed: () {
                      sendotpapi();
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

  void showCustomerCode(BuildContext context) {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Container(
              color: whitecolor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getTextWidget(
                      title: 'Enter 4 digit customer code',
                      textFontSize: fontSize15,
                      textFontWeight: fontWeightMedium,
                      textColor: background),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 27.0, left: 20, right: 20),
                    child: PinCodeTextField(
                      enableActiveFill: true,
                      cursorColor: background,
                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      textStyle: const TextStyle(
                          color: background,
                          fontFamily: fontfamilybeVietnam,
                          fontSize: fontSize22,
                          fontWeight: fontWeightSemiBold),
                      onChanged: (value) {},
                      onCompleted: (String verificationCode) {
                        otpController.text = verificationCode;
                      },
                      appContext: context,
                      length: 4,
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 45,
                          fieldWidth: 45,
                          activeFillColor: whitecolor,
                          inactiveColor: const Color(0xFFE0E0E0),
                          inactiveFillColor: whitecolor,
                          selectedFillColor: whitecolor,
                          selectedColor: const Color(0xFFE0E0E0),
                          activeColor: background),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16),
                    child: CustomizeButton(
                        text: 'Submit',
                        onPressed: () {
                          if (otpController.text.isNotEmpty) {
                            verifyotpapi();
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(msg: 'Please enter otp');
                          }
                        }),
                  )
                ],
              ),
            ),
          );
        },
        context: context);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
