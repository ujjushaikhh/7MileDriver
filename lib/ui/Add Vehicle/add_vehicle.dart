import 'dart:convert';
import 'dart:io';
import 'package:driverflow/ui/Add%20Vehicle/model/add_vehicle.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;
import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Add%20Document/add_document.dart';
import 'package:driverflow/ui/Add%20Vehicle/model/get_vehiclemodel.dart';
import 'package:driverflow/utils/button.dart';
import 'package:driverflow/utils/textfeild.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../utils/dailog.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';

class MyAddVehicle extends StatefulWidget {
  const MyAddVehicle({super.key});

  @override
  State<MyAddVehicle> createState() => _MyAddVehicleState();
}

class _MyAddVehicleState extends State<MyAddVehicle> {
  // final TextEditingController textEditingController = TextEditingController();

  // @override
  // void dispose() {
  //   textEditingController.dispose();
  //   super.dispose();
  // }

  @override
  initState() {
    super.initState();
    getVehicleapi();
  }

  var token = getString('token');

  List<VehicleType> vehicleType = [];
  VehicleType? selectedVehicle;

  List<VehicleMake> vehicleMake = [];
  VehicleMake? selectedVehicleMake;

  List<VehicleModel> vehicleModel = [];
  VehicleModel? selectedVehicleModel;

  List<VehicleYear> vehicleModelYear = [];
  VehicleYear? selectedVehicleModelYear;

  final _numberplatecontroller = TextEditingController();

  String? vehicleModelid;
  String? vehicleMakeid;
  String? vehicleTypeid;
  String? vehicleYearid;

  final List<File>? selectedImages = [];
  File? _image;
  final picker = ImagePicker();

  void getImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) {
        return;
      }
      // final imgTemp = image.map((img) => File(img.path)).toList();
      final imgTemp = File(image.path);

      setState(() {
        _image = imgTemp;
        selectedImages!.add(imgTemp);
      });
    } catch (e) {
      debugPrint("Failed to open $e");
    }
  }

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

  Future<void> uploadvehicleapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);

      try {
        var headers = {
          'authkey': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        debugPrint(token);

        var apiurl = uploadvehicleurl;
        debugPrint(apiurl);
        var request = http.MultipartRequest('POST', Uri.parse(apiurl));

        request.fields['model_id'] = selectedVehicleModel!.modelId!.toString();
        request.fields['make_id'] = selectedVehicleMake!.makeId.toString();
        request.fields['type_id'] = selectedVehicle!.typeId.toString();
        request.fields['year_id'] =
            selectedVehicleModelYear!.yearId!.toString();
        request.fields['vehicle_number'] =
            _numberplatecontroller.text.toString();
        if (_image != null) {
          for (var image in selectedImages!) {
            request.files
                .add(await http.MultipartFile.fromPath('image[]', image.path));
          }

          // var imageFile =
          //     await http.MultipartFile.fromPath('image[]', _image!.path);
          // request.files.add(imageFile);
        }

        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var uploadVehicle = UploadVehicleModel.fromJson(jsonResponse);

        debugPrint('Response status code: ${response.statusCode}');
        debugPrint('Response body: ${responsed.body}');

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (uploadVehicle.status == 1) {
            setString('vehicledoc', '1');
            if (!mounted) return;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyAddDoc()));
            // setString('userlogin', '1');
            // setString('isCompleted', 'true');
            // setString('profilepic',
            //     uploadVehicle.profile!.profileImage.toString());

            // CollectionReference user =
            //     FirebaseFirestore.instance.collection('users');
            // DocumentReference mainDocRef =
            //     user.doc(uploadVehicle.profile!.id.toString());
            // await mainDocRef.set({
            //   'name': name.toString(),
            //   'userid': id,
            //   'image': '$baseurl${image.toString()}',
            //   'fcmToken': fcmToken.toString(),
            //   'email': email.toString(),
            // });

            // ProgressDialogUtils.dismissProgressDialog();
            // vapeAlertDialogue(
            //     context: context,
            //     desc: 'Profile Completed Successfully',
            //     type: AlertType.success,
            //     onPressed: () {
            //       Navigator.push(context,
            //           MaterialPageRoute(builder: (context) => const MyHome()));
            //     }).show();
          } else {
            debugPrint('Failed to load');
            ProgressDialogUtils.dismissProgressDialog();
            if (!mounted) return;
            vapeAlertDialogue(
              context: context,
              desc: uploadVehicle.message,
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          debugPrint('400');
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadVehicle.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
          debugPrint(uploadVehicle.message);
        } else if (response.statusCode == 401) {
          debugPrint('401');
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadVehicle.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();

          debugPrint(uploadVehicle.message);
        } else if (response.statusCode == 500) {
          debugPrint('500');
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadVehicle.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();

          debugPrint(uploadVehicle.message);
        } else if (response.statusCode == 404) {
          debugPrint('404');
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadVehicle.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();

          debugPrint(uploadVehicle.message);
        }
      } catch (e) {
        ProgressDialogUtils.dismissProgressDialog();
        debugPrint('The Error is Here :- $e');
        vapeAlertDialogue(
          context: context,
          desc: '$e',
          onPressed: () {
            Navigator.pop(context);
          },
        ).show();
      }
    } else {
      ProgressDialogUtils.dismissProgressDialog();
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

  Future<void> getVehicleapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);
      try {
        var apiurl = getvehicleurl;
        debugPrint(apiurl);
        var headers = {
          // 'Authorization': 'Bearer' '$token',
          'Content-Type': 'application/json',
        };

        // debugPrint(token);

        var request = http.Request('GET', Uri.parse(apiurl));
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var getVehicle = GetVehicleModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (getVehicle.status == 1) {
            setState(() {
              vehicleMake = getVehicle.data!.vehicleMake!;
              vehicleModel = getVehicle.data!.vehicleModel!;
              vehicleType = getVehicle.data!.vehicleType!;
              vehicleModelYear = getVehicle.data!.vehicleYear!;
              // allProduct = getVehicle.products!;
              // for (var productid in allProduct) {
              //   productId = productid.id!;
              // }
            });
            debugPrint('is it success');
          } else {
            debugPrint('failed to load');
            ProgressDialogUtils.dismissProgressDialog();
          }
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getVehicle.message}',
            onPressed: () {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (context) => LoginScreen()),
              //     (route) => false);
            },
          ).show();
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();
          if (mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getVehicle.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getVehicle.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getVehicle.message}',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: background,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: getTextWidget(
                  title: 'Add Vehicle',
                  textColor: background,
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightBold),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 11.0),
                      child: getTextWidget(
                          title: 'Vehicle Type',
                          textFontSize: fontSize15,
                          textColor: background,
                          textFontWeight: fontWeightMedium),
                    ),
                    getVehicletype(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: getTextWidget(
                          title: 'Vehicle Make',
                          textFontSize: fontSize15,
                          textColor: background,
                          textFontWeight: fontWeightMedium),
                    ),
                    getVehiclemake(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: getTextWidget(
                          title: 'Vehicle Model',
                          textFontSize: fontSize15,
                          textColor: background,
                          textFontWeight: fontWeightMedium),
                    ),
                    getVehicleModel(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: getTextWidget(
                          title: 'Vehicle Model Year',
                          textFontSize: fontSize15,
                          textColor: background,
                          textFontWeight: fontWeightMedium),
                    ),
                    getVehicleModelYear(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: getTextWidget(
                          title: 'Vehicle Number Plate',
                          textFontSize: fontSize15,
                          textColor: background,
                          textFontWeight: fontWeightMedium),
                    ),
                    getNumberPlate(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: getTextWidget(
                          title: 'Upload Vehicle Photo',
                          textFontSize: fontSize15,
                          textColor: background,
                          textFontWeight: fontWeightMedium),
                    ),
                    _getImage(),
                    getButton()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 32.0),
      child: CustomizeButton(
          text: 'Continue',
          onPressed: () {
            uploadvehicleapi();
          }),
    );
  }

  Widget _getImage() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _image == null
          ? DottedBorder(
              dashPattern: const [4, 4],
              strokeWidth: 1,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              color: taptoupload,
              child: GestureDetector(
                onTap: () {
                  _showBottomSheet();
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 206,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: uploadphoto,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showBottomSheet();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            icUpload,
                            height: 44,
                            width: 44,
                          ),
                          // const SizedBox(
                          //   height: 2.0,
                          // ),
                          getTextWidget(
                              title: 'Tap to upload photo',
                              textFontSize: fontSize14,
                              textColor: taptoupload,
                              textFontWeight: fontWeightRegular),
                        ],
                      ),
                    )),
              ),
            )
          : Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 206,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: uploadphoto,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0.0,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _image = null;
                      });
                    },
                    icon: Image.asset(
                      icClose,
                      height: 24.0,
                      width: 24.0,
                      fit: BoxFit.cover,
                    )),
              )
            ]),
    );
  }

  Widget getNumberPlate() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextFormDriver(
          hintColor: dropdownhint,
          fillColor: whitecolor,
          borderColor: dropdownborder,
          textstyle: background,
          controller: _numberplatecontroller,
          hintText: 'ABC 64384'),
    );
  }

  Widget getVehiclemake() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonHideUnderline(
          child: DropdownButton2(
        style: const TextStyle(color: background),
        isExpanded: true,
        hint: const Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Select',
                  style: TextStyle(
                    color: dropdownhint,
                    fontSize: fontSize14,
                    fontWeight: fontWeightRegular,
                    fontFamily: fontfamilybeVietnam,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        items: vehicleMake.map((item) {
          return DropdownMenuItem<VehicleMake>(
            value: item,
            enabled: true,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.make.toString(),
                      style: const TextStyle(
                        fontSize: fontSize14,
                        fontFamily: fontfamilybeVietnam,
                        fontWeight: fontWeightRegular,
                        color: blackcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        // dropdownSearchData: DropdownSearchData(
        //   searchController: textEditingController,
        //   searchInnerWidgetHeight: 50,
        //   searchInnerWidget: Container(
        //     height: 50,
        //     padding: const EdgeInsets.only(
        //       top: 8,
        //       bottom: 4,
        //       right: 8,
        //       left: 8,
        //     ),
        //     child: TextFormField(
        //       expands: true,
        //       maxLines: null,
        //       controller: textEditingController,
        //       decoration: InputDecoration(
        //         isDense: true,
        //         contentPadding: const EdgeInsets.symmetric(
        //           horizontal: 10,
        //           vertical: 8,
        //         ),
        //         hintText: 'Search for an item...',
        //         hintStyle: const TextStyle(fontSize: 12),
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //     ),
        //   ),
        //   searchMatchFn: (item, searchValue) {
        //     return item.value.toString().contains(searchValue);
        //   },
        // ),
        // //This to clear the search value when you close the menu
        // onMenuStateChange: (isOpen) {
        //   if (!isOpen) {
        //     textEditingController.clear();
        //   }
        // },
        value: selectedVehicleMake,
        onChanged: (value) {
          setState(() {
            selectedVehicleMake = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: dropdownborder,
            ),
            color: whitecolor,
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: background,
          ),
          iconSize: 14,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.white,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: null,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), color: Colors.white),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      )),
    );
  }

  Widget getVehicleModel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonHideUnderline(
          child: DropdownButton2(
        style: const TextStyle(color: background),
        isExpanded: true,
        hint: const Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Select',
                  style: TextStyle(
                    color: dropdownhint,
                    fontSize: fontSize14,
                    fontWeight: fontWeightRegular,
                    fontFamily: fontfamilybeVietnam,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        items: vehicleModel.map((item) {
          return DropdownMenuItem(
            value: item,
            enabled: true,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.modelName.toString(),
                      style: const TextStyle(
                        fontSize: fontSize14,
                        fontFamily: fontfamilybeVietnam,
                        fontWeight: fontWeightRegular,
                        color: blackcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        // dropdownSearchData: DropdownSearchData(
        //   searchController: textEditingController,
        //   searchInnerWidgetHeight: 50,
        //   searchInnerWidget: Container(
        //     height: 50,
        //     padding: const EdgeInsets.only(
        //       top: 8,
        //       bottom: 4,
        //       right: 8,
        //       left: 8,
        //     ),
        //     child: TextFormField(
        //       expands: true,
        //       maxLines: null,
        //       controller: textEditingController,
        //       decoration: InputDecoration(
        //         isDense: true,
        //         contentPadding: const EdgeInsets.symmetric(
        //           horizontal: 10,
        //           vertical: 8,
        //         ),
        //         hintText: 'Search for an item...',
        //         hintStyle: const TextStyle(fontSize: 12),
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //     ),
        //   ),
        //   searchMatchFn: (item, searchValue) {
        //     return item.value.toString().contains(searchValue);
        //   },
        // ),
        // //This to clear the search value when you close the menu
        // onMenuStateChange: (isOpen) {
        //   if (!isOpen) {
        //     textEditingController.clear();
        //   }
        // },
        value: selectedVehicleModel,
        onChanged: (value) {
          setState(() {
            selectedVehicleModel = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: dropdownborder,
            ),
            color: whitecolor,
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: background,
          ),
          iconSize: 14,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.white,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: null,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), color: Colors.white),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      )),
    );
  }

  Widget getVehicletype() {
    return
        // return MyDropdown<VehicleType>(
        //     items: vehicleType,
        //     onChanged: (VehicleType? value) {
        //       setState(() {
        //         selectedVehicle = value!.toString();
        //       });
        //     },
        //     selectedValue: selectedVehicle);

        Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonHideUnderline(
          child: DropdownButton2(
        style: const TextStyle(color: background),
        isExpanded: true,
        hint: const Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Select',
                  style: TextStyle(
                    color: dropdownhint,
                    fontSize: fontSize14,
                    fontWeight: fontWeightRegular,
                    fontFamily: fontfamilybeVietnam,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        items: vehicleType.map((item) {
          return DropdownMenuItem(
            value: item,
            enabled: true,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.type.toString(),
                      style: const TextStyle(
                        fontSize: fontSize14,
                        fontFamily: fontfamilybeVietnam,
                        fontWeight: fontWeightRegular,
                        color: blackcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        value: selectedVehicle,
        onChanged: (value) {
          setState(() {
            selectedVehicle = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: dropdownborder,
            ),
            color: whitecolor,
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: background,
          ),
          iconSize: 14,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.white,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: null,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), color: Colors.white),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      )),
    );
  }

  Widget getVehicleModelYear() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: DropdownButtonHideUnderline(
          child: DropdownButton2(
        style: const TextStyle(color: background),
        isExpanded: true,
        hint: const Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'Select',
                  style: TextStyle(
                    color: dropdownhint,
                    fontSize: fontSize14,
                    fontWeight: fontWeightRegular,
                    fontFamily: fontfamilybeVietnam,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        items: vehicleModelYear.map((item) {
          return DropdownMenuItem(
            value: item,
            enabled: true,
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.yearName.toString(),
                      style: const TextStyle(
                        fontSize: fontSize14,
                        fontFamily: fontfamilybeVietnam,
                        fontWeight: fontWeightRegular,
                        color: blackcolor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        // dropdownSearchData: DropdownSearchData(
        //   searchController: textEditingController,
        //   searchInnerWidgetHeight: 50,
        //   searchInnerWidget: Container(
        //     height: 50,
        //     padding: const EdgeInsets.only(
        //       top: 8,
        //       bottom: 4,
        //       right: 8,
        //       left: 8,
        //     ),
        //     child: TextFormField(
        //       expands: true,
        //       maxLines: null,
        //       controller: textEditingController,
        //       decoration: InputDecoration(
        //         isDense: true,
        //         contentPadding: const EdgeInsets.symmetric(
        //           horizontal: 10,
        //           vertical: 8,
        //         ),
        //         hintText: 'Search for an item...',
        //         hintStyle: const TextStyle(fontSize: 12),
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //     ),
        //   ),
        //   searchMatchFn: (item, searchValue) {
        //     return item.value.toString().contains(searchValue);
        //   },
        // ),
        // //This to clear the search value when you close the menu
        // onMenuStateChange: (isOpen) {
        //   if (!isOpen) {
        //     textEditingController.clear();
        //   }
        // },
        value: selectedVehicleModelYear,
        onChanged: (value) {
          setState(() {
            selectedVehicleModelYear = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: dropdownborder,
            ),
            color: whitecolor,
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 24,
            color: background,
          ),
          iconSize: 14,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.white,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: null,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), color: Colors.white),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      )),
    );
  }
}
