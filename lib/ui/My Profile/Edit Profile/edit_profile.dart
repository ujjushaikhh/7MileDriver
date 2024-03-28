import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:driverflow/constant/api_constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/My%20Profile/Edit%20Profile/model/update_drivermodel.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:driverflow/utils/textfeild.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/button.dart';
import '../../../utils/dailog.dart';
import '../../../utils/internetconnection.dart';
import '../../../utils/progressdialogue.dart';
import '../../../utils/validation.dart';

class MyEditProfile extends StatefulWidget {
  const MyEditProfile({super.key});

  @override
  State<MyEditProfile> createState() => _MyEditProfileState();
}

class _MyEditProfileState extends State<MyEditProfile> {
  final _fullnamecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _mobilecontroller = TextEditingController();
  // final _countrycodecontroller = TextEditingController();

  var countrycode;

  File? _image;
  File? _imageDriving;
  File? _imageRegistration;
  File? _imageImsaurance;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    countrycode = getcountrycode;
    _fullnamecontroller.text = getuserName;
    _emailcontroller.text = getuserEmail;
    _mobilecontroller.text = getuserMobile;
    debugPrint('User Image:- $getuserimage');
    debugPrint('Driving licence :-$getDrivinglicence');
    debugPrint('Registration :- $getVehicleRegistration');
    debugPrint('Insaurance:- $getVehicleInsaurance');
    // _countrycodecontroller.text = getcountrycode;
  }

  var token = getString('token');
  String getuserName = getString('name');
  String getuserEmail = getString('email');
  String getuserimage = getString('userimage');
  String getuserMobile = getString('mobilenum');
  String getcountrycode = getString('countrycode');
  String getDrivinglicence = getString('drivinglicence');
  String getVehicleRegistration = getString('vehicleRegistration');
  String getVehicleInsaurance = getString('vehicleInsaurance');

  Future<void> updateDriverapi() async {
    if (await checkUserConnection()) {
      try {
        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);

        var apiurl = updatedriverurl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(getString('token'));

        var request = http.MultipartRequest('POST', Uri.parse(apiurl));
        if (_image != null) {
          var imageFile =
              await http.MultipartFile.fromPath('profile_image', _image!.path);
          request.files.add(imageFile);
        } else {
          debugPrint('previous image $getuserimage');
          request.fields['profile_image'] = getuserimage;
        }
        if (_imageDriving != null) {
          var imageFile = await http.MultipartFile.fromPath(
              'driving_licence', _imageDriving!.path);
          request.files.add(imageFile);
        } else {
          debugPrint(' previous driving_licence $getDrivinglicence');
          request.fields['driving_licence'] = getDrivinglicence;
        }
        if (_imageRegistration != null) {
          var imageFile = await http.MultipartFile.fromPath(
              'vehicle_registration_documents', _imageRegistration!.path);
          request.files.add(imageFile);
        } else {
          debugPrint(
              'previous vehicle_registration_documents $getVehicleRegistration');
          request.fields['vehicle_registration_documents'] =
              getVehicleRegistration;
        }
        if (_imageImsaurance != null) {
          var imageFile = await http.MultipartFile.fromPath(
              'vehicle_insurance_number', _imageImsaurance!.path);
          request.files.add(imageFile);
        } else {
          debugPrint(
              'previous image vehicle_insurance_number$getVehicleInsaurance');
          request.fields['vehicle_insurance_number'] = getVehicleInsaurance;
        }
        request.fields['name'] = _fullnamecontroller.text.toString();
        request.fields['phone'] = _mobilecontroller.text.toString();
        request.fields['country_code'] = countrycode.toString();

        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var updateDriver = UpdateDriverModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);

          ProgressDialogUtils.dismissProgressDialog();
          if (updateDriver.status == 1) {
            if (!mounted) return;
            setState(() {
              setString('name', updateDriver.driver!.name!.toString());
              setString(
                  'userimage', updateDriver.driver!.profileImage!.toString());
              setString('drivinglicence',
                  updateDriver.driver!.drivingLicence!.toString());
              setString('vehicleInsaurance',
                  updateDriver.driver!.vehicleInsuranceNumber!.toString());
              setString(
                  'vehicleRegistration',
                  updateDriver.driver!.vehicleRegistrationDocuments!
                      .toString());
            });
            Fluttertoast.showToast(msg: 'Profile updated successfully');
            Navigator.pop(context, true);
          } else {
            debugPrint('failed to load');
            ProgressDialogUtils.dismissProgressDialog();
            if (!mounted) return;
            vapeAlertDialogue(
              context: context,
              desc: '${updateDriver.message}',
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();

          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${updateDriver.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${updateDriver.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 401) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${updateDriver.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${updateDriver.message}',
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
          desc: 'Something went Wrong ',
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ).show();
      }
    } else {
      ProgressDialogUtils.dismissProgressDialog();

      if (!mounted) return;
      vapeAlertDialogue(
        type: AlertType.info,
        context: context,
        desc: 'Check Internet Connection',
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'Edit Profile',
              textFontSize: fontSize15,
              textFontWeight: fontWeightSemiBold,
              textColor: whitecolor),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: whitecolor,
                size: 24,
              )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: getTextWidget(
                    title: 'Personal Detail ',
                    textFontSize: fontSize20,
                    textFontWeight: fontWeightBold,
                    textColor: background),
              ),
              _getImage(),
              Padding(
                padding: const EdgeInsets.only(top: 29.0),
                child: getTextWidget(
                    title: 'Full Name',
                    textFontSize: fontSize15,
                    textFontWeight: fontWeightMedium,
                    textColor: background),
              ),
              getFullname(),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: getTextWidget(
                    title: 'Email',
                    textFontSize: fontSize15,
                    textFontWeight: fontWeightMedium,
                    textColor: background),
              ),
              getEmail(),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: getTextWidget(
                    title: 'Mobile',
                    textFontSize: fontSize15,
                    textFontWeight: fontWeightMedium,
                    textColor: background),
              ),
              getMobileFeild(),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: getTextWidget(
                    title: 'Legal Documents & Details',
                    textFontSize: fontSize20,
                    textFontWeight: fontWeightBold,
                    textColor: background),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: getTextWidget(
                    title: 'Driving Licence',
                    textFontSize: fontSize15,
                    textColor: background,
                    textFontWeight: fontWeightMedium),
              ),
              _getImageDriving(),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: getTextWidget(
                    title: 'Vehicle Registration Documents',
                    textFontSize: fontSize15,
                    textColor: background,
                    textFontWeight: fontWeightMedium),
              ),
              _getImageRegistration(),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: getTextWidget(
                    title: 'Vehicle Insurance Number',
                    textFontSize: fontSize15,
                    textColor: background,
                    textFontWeight: fontWeightMedium),
              ),
              _getImageInsaurance(),
              getButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget getFullname() {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: TextFormDriver(
        borderColor: dropdownborder,
        fillColor: whitecolor,
        prefixiconcolor: background,
        controller: _fullnamecontroller,
        hintText: 'Bessie Cooper',
        hintColor: background,
        textstyle: background,
        fontWeight: fontWeightMedium,
        prefixIcon: icUser,
      ),
    );
  }

  Widget getEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: TextFormDriver(
        borderColor: dropdownborder,
        fillColor: whitecolor,
        textstyle: background,
        prefixiconcolor: background,
        keyboardType: TextInputType.emailAddress,
        controller: _emailcontroller,
        hintText: 'debra.holt@example.com',
        hintColor: background,
        fontWeight: fontWeightMedium,
        enable: false,
        prefixIcon: icEmail,
      ),
    );
  }

  Widget getMobileFeild() {
    return Padding(
      padding: const EdgeInsets.only(top: 22.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: whitecolor,
            border: Border.all(color: dropdownborder),
            borderRadius: BorderRadius.circular(6.0)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).

                  //Optional. Shows phone code before the country name.
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    setState(() {
                      countrycode = country.phoneCode;
                    });
                  },
                  // Optional. Sets the theme for the country list picker.
                  countryListTheme: CountryListThemeData(
                    // Optional. Sets the border radius for the bottomsheet.
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    // Optional. Styles the search field.
                    inputDecoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Start typing to search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF8C98A8).withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    IconButton(
                      splashRadius: 0.1,
                      onPressed: () {},
                      icon: Image.asset(
                        icMobile,
                        height: 24,
                        width: 24,
                        color: background,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                        child: getTextWidget(
                            title: '$countrycode',
                            textFontSize: fontSize16,
                            textFontWeight: fontWeightRegular,
                            textColor: background)),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: background,
                    )
                  ],
                ),
              )),
          Container(
            decoration: BoxDecoration(
                color: whitecolor,
                border: Border.all(color: dropdownborder),
                borderRadius: BorderRadius.circular(6.0)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextFormField(
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                      color: background,
                      fontFamily: fontfamilybeVietnam,
                      fontWeight: fontWeightMedium,
                      fontSize: fontSize14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 16.0),
                    hintText: 'Mobile Number',
                    hintStyle: TextStyle(
                      color: hintcolor,
                      fontSize: fontSize14,
                      fontWeight: fontWeightMedium,
                      fontFamily: fontfamilybeVietnam,
                    ),
                    // fillColor: background,

                    // filled: true,
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(
                    //     width: 1.0,
                    //     color: bordercolor,
                    //   ),
                    // ),
                    // disabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordercolor),
                    // ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordercolor),
                    // ),
                    // focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordercolor),
                    // ),
                    // errorBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(6.0),
                    //   borderSide: const BorderSide(color: bordererror),
                    // ),
                  ),
                  controller: _mobilecontroller,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    // setState(() {
                    //   mobileError =
                    //       Validation.validateMobileNumber(value) != null;
                    // });
                    return Validation.validateMobileNumber(value);
                  }),
            ),
          )
        ]),
      ),

      // Row(
      //   children: [
      //     GestureDetector(
      //       onTap: () {
      //         showCountryPicker(
      //             context: context,
      //             showPhoneCode: true,
      //             countryListTheme: CountryListThemeData(
      //               // Optional. Sets the border radius for the bottomsheet.
      //               borderRadius: const BorderRadius.only(
      //                 topLeft: Radius.circular(40.0),
      //                 topRight: Radius.circular(40.0),
      //               ),
      //               // Optional. Styles the search field.
      //               inputDecoration: InputDecoration(
      //                 labelText: 'Search',
      //                 hintText: 'Start typing to search',
      //                 prefixIcon: const Icon(Icons.search),
      //                 border: OutlineInputBorder(
      //                   borderSide: BorderSide(
      //                     color: const Color(0xFF8C98A8).withOpacity(0.2),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             onSelect: (Country country) {
      //               setState(() {
      //                 countrycode = country.phoneCode;
      //               });
      //             });
      //       },
      //       child: Padding(
      //         padding: const EdgeInsets.all(0.0),
      //         child: Row(
      //           children: [
      //             IconButton(
      //               splashRadius: 0.1,
      //               onPressed: () {},
      //               icon: Image.asset(
      //                 icMobile,
      //                 height: 24,
      //                 width: 24,
      //               ),
      //             ),
      //             Padding(
      //                 padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      //                 child: getTextWidget(
      //                     title: '+' "$countrycode",
      //                     textFontSize: fontSize16,
      //                     textFontWeight: fontWeightRegular,
      //                     textColor: background)),
      //             const Icon(Icons.arrow_drop_down)
      //           ],
      //         ),
      //       ),
      //     ),
      //     Container(
      //       //color: Color(0xff020202).withOpacity(0.2),
      //       width: 1,
      //       //height: 32,
      //       decoration: BoxDecoration(
      //           border: Border.all(color: const Color(0xffE8E8E8))),
      //     ),
      //     Expanded(
      //       child: TextFormDriver(
      //         // prefixIcon: icMobile,
      //         controller: _mobilecontroller,
      //         keyboardType: TextInputType.number,
      //         hintText: 'Mobile Number',
      //         validation: (value) => Validation.validateMobileNumber(value),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  // Widget getMobile() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 7.0),
  //     child: TextFormDriver(
  //       borderColor: dropdownborder,
  //       fillColor: whitecolor,
  //       prefixiconcolor: background,
  //       textstyle: background,
  //       keyboardType: TextInputType.number,
  //       controller: _countrycodecontroller + _mobilecontroller,
  //       hintText: '(219) 555-0114',
  //       hintColor: background,
  //       fontWeight: fontWeightMedium,
  //       prefixIcon: icMobile,
  //     ),
  //   );
  // }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150.0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  // Handle camera button tap
                  getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  // Handle gallery button tap
                  getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void getImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) {
        return;
      }
      final imgTemp = File(image.path);

      setState(() {
        _image = imgTemp;
      });
    } catch (e) {
      debugPrint("Failed to open $e");
    }
  }

  Widget _getImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(children: [
          Positioned(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0),
              child: ClipOval(
                child: _image == null
                    ? CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                          height: 147.0,
                          width: 147.0,
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
                            height: 40.0,
                            width: 40.0,
                            decoration: const BoxDecoration(
                                color: Colors.grey, shape: BoxShape.rectangle),
                          ),
                        ),
                        imageUrl: getuserimage.toString(),
                        height: 147.0,
                        width: 147.0,
                        fit: BoxFit.cover,
                      )
                    // ? CachedNetworkImage(
                    //     imageUrl: '$baseurl${getprofileImage.toString()}',
                    //     imageBuilder: (context, imageProvider) => Container(
                    //       height: 130.0,
                    //       width: 130.0,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: imageProvider,
                    //           fit: BoxFit.cover,
                    //         ),
                    //       ),
                    //     ),
                    //     placeholder: (context, url) => Image.asset(
                    //       'assets/images/person_icon.png',
                    //       height: 130.0,
                    //       width: 130.0,
                    //       fit: BoxFit.cover,
                    //     ),
                    //     errorWidget: (context, url, error) =>
                    //         const Icon(Icons.error),
                    //   )
                    : Image.file(
                        _image!,
                        height: 147.0,
                        width: 147.0,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          Positioned(
              bottom: 0.0,
              right: 2.0,
              child: GestureDetector(
                onTap: () {
                  _showBottomSheet();
                },
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(icCamera), fit: BoxFit.cover)),
                ),
              )

              // IconButton(
              //   onPressed: () {
              //     _showBottomSheet();
              //   },
              //   icon: Image.asset(
              //     icCamera,
              //     height: 38.0,
              //     width: 38.0,
              //     fit: BoxFit.cover,
              //   ),
              // ),

              )
        ]),
      ],
    );
  }

  Widget getButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 32.0),
      child: CustomizeButton(
        text: 'Save',
        onPressed: () {
          updateDriverapi();
        },
      ),
    );
  }

  Widget _getImageDriving() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _imageDriving == null
          ? GestureDetector(
              onTap: () {
                _showBottomSheetDriving();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 206,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: uploadphoto,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      height: 206.0,
                      width: MediaQuery.of(context).size.width,
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
                        height: 206.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.rectangle),
                      ),
                    ),
                    imageUrl: getDrivinglicence.toString(),
                    height: 206.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              )
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Image.asset(
              //       icUpload,
              //       height: 44,
              //       width: 44,
              //     ),
              //     // const SizedBox(
              //     //   height: 2.0,
              //     // ),
              //     getTextWidget(
              //         title: 'Tap to upload documents',
              //         textFontSize: fontSize14,
              //         textColor: taptoupload,
              //         textFontWeight: fontWeightRegular),
              //   ],
              // ),
              )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: 206,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // color: uploadphoto,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.file(
                  _imageDriving!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  getdrivingFile() {
    String extension = _imageDriving!.path;

    if (extension == ".pdf") {
      // Display a PDF icon or widget
      return const Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: 50,
          color: Colors.red,
        ),
      );
    }
  }

  Widget _getImageRegistration() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _imageRegistration == null
          ? GestureDetector(
              onTap: () {
                _showBottomSheetRegistration();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 206,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: uploadphoto,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      height: 206.0,
                      width: MediaQuery.of(context).size.width,
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
                        height: 206.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.rectangle),
                      ),
                    ),
                    imageUrl: getVehicleRegistration.toString(),
                    height: 206.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              )

              //  Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Image.asset(
              //       icUpload,
              //       height: 44,
              //       width: 44,
              //     ),
              //     // const SizedBox(
              //     //   height: 2.0,
              //     // ),
              //     getTextWidget(
              //         title: 'Tap to upload documents',
              //         textFontSize: fontSize14,
              //         textColor: taptoupload,
              //         textFontWeight: fontWeightRegular),
              //   ],
              // ),
              )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: 206,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // color: uploadphoto,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _imageRegistration!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  Widget _getImageInsaurance() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _imageImsaurance == null
          ? GestureDetector(
              onTap: () {
                _showBottomSheetInsaurance();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 206,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: uploadphoto,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      height: 206.0,
                      width: MediaQuery.of(context).size.width,
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
                        height: 206.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.rectangle),
                      ),
                    ),
                    imageUrl: getVehicleInsaurance.toString(),
                    height: 206.0,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
              )
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Image.asset(
              //       icUpload,
              //       height: 44,
              //       width: 44,
              //     ),
              //     // const SizedBox(
              //     //   height: 2.0,
              //     // ),
              //     getTextWidget(
              //         title: 'Tap to upload documents',
              //         textFontSize: fontSize14,
              //         textColor: taptoupload,
              //         textFontWeight: fontWeightRegular),
              //   ],
              // ),
              )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: 206,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // color: uploadphoto,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _imageImsaurance!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  void getImageDriving(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) {
        return;
      }
      final imgTemp = File(image.path);

      setState(() {
        _imageDriving = imgTemp;
      });
    } catch (e) {
      debugPrint("Failed to open $e");
    }
  }

  void getImageRegistration(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) {
        return;
      }
      final imgTemp = File(image.path);

      setState(() {
        _imageRegistration = imgTemp;
      });
    } catch (e) {
      debugPrint("Failed to open $e");
    }
  }

  void getImageInsaurance(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) {
        return;
      }
      final imgTemp = File(image.path);

      setState(() {
        _imageImsaurance = imgTemp;
      });
    } catch (e) {
      debugPrint("Failed to open $e");
    }
  }

  void _showBottomSheetDriving() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150.0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  // Handle camera button tap
                  getImageDriving(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  // Handle gallery button tap
                  getImageDriving(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheetRegistration() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150.0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  // Handle camera button tap
                  getImageRegistration(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  // Handle gallery button tap
                  getImageRegistration(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheetInsaurance() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150.0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  // Handle camera button tap
                  getImageInsaurance(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  // Handle gallery button tap
                  getImageInsaurance(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
