import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Home/Delivered/delivered.dart';
import 'package:driverflow/ui/Home/home.dart';
import 'package:driverflow/ui/Item%20Summary/item_summary.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../../../constant/color_constant.dart';
import '../../../constant/font_constant.dart';
import '../../../utils/button.dart';
import '../../../utils/textwidget.dart';

class MyOnTheWay extends StatefulWidget {
  const MyOnTheWay({super.key});

  @override
  State<MyOnTheWay> createState() => _MyOnTheWayState();
}

class _MyOnTheWayState extends State<MyOnTheWay> {
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    getLocation();
  }

  bool isViewed = false;
  bool isLoading = true;
  String? customerNumber = getString('custmobilenum');
  String? _mapStyle;
  LatLng? _currentPosition;
  LocationPermission? permission;
  BitmapDescriptor? currentDestination;
  BitmapDescriptor? pickupDestination;

  final MapType _currentMapType = MapType.normal;
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyB-s7cqmVufTKO1Rp2amMq8tdmEKVMVE-U";

  List<LatLng> polylineCoordinates = [];

  final double _destLatitude = 23.2156;
  final double _destLongitude = 72.6369;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    print('$mapController');
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
                                    maxLines: 3,
                                    title:
                                        '${getString('houseno')} ,${getString('landmark')} , ${getString('address')} ,${getString('zipcode')}',
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
                  top: 10.0, bottom: 16.0, left: 16.0, right: 16.0),
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
                    text: 'On the Way',
                    color: Colors.white70,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (contex) => const MyDelivered()));
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
