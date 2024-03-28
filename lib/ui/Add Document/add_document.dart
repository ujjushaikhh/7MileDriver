import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/ui/Add%20Document/model/upload_docmodel.dart';
import 'package:driverflow/ui/Pop%20ups/Succes%20Popup/success_screen.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../../constant/font_constant.dart';
import '../../constant/image_constant.dart';
import '../../utils/button.dart';
import '../../utils/dailog.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';
import '../../utils/textwidget.dart';

class MyAddDoc extends StatefulWidget {
  const MyAddDoc({super.key});

  @override
  State<MyAddDoc> createState() => _MyAddDocState();
}

class _MyAddDocState extends State<MyAddDoc> {
  File? _imageDriving;
  File? _imageRegistration;
  File? _imageInsaurance;

  String? _imagedrivingfile;
  String? _imageRegistrationfile;
  String? _imageInsaurancefile;

  final picker = ImagePicker();

  String token = getString('token');

  Future<void> uploadDocumentapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);

      try {
        var headers = {
          'authkey': 'Bearer $token',
          'Content-Type': 'application/json',
        };

        debugPrint(token);

        var apiurl = uploaddocumenturl;
        debugPrint(apiurl);
        var request = http.MultipartRequest('POST', Uri.parse(apiurl));

        if (_imageDriving != null) {
          var imagedriving = await http.MultipartFile.fromPath(
              'driving_licence', _imageDriving!.path);

          request.files.add(imagedriving);
        } else if (_imagedrivingfile != null) {
          var imagedrivingfile = await http.MultipartFile.fromPath(
              'driving_licence', _imagedrivingfile!
              // _imagedrivingfile!.bytes!,
              // filename: _imagedrivingfile!.name,
              );
          request.files.add(imagedrivingfile);
        } else {
          debugPrint('Not passed license');
        }
        if (_imageRegistration != null) {
          var imageregistration = await http.MultipartFile.fromPath(
              'vehicle_registration_documents', _imageRegistration!.path);

          request.files.add(imageregistration);
        } else if (_imageRegistrationfile != null) {
          var imageregistrationfile = await http.MultipartFile.fromPath(
            'vehicle_registration_documents',
            _imageInsaurancefile!,
          );

          request.files.add(imageregistrationfile);
        } else {
          debugPrint('Not passed Registration');
        }
        if (_imageInsaurance != null) {
          var imageinsaurance = await http.MultipartFile.fromPath(
              'vehicle_insurance_number', _imageRegistration!.path);

          request.files.add(imageinsaurance);
        } else if (_imageInsaurancefile != null) {
          var imageinsaurancefile = await http.MultipartFile.fromPath(
            'vehicle_insurance_number', _imageInsaurancefile!,
            // filename: _imageInsaurancefile!
          );

          request.files.add(imageinsaurancefile);
        } else {
          debugPrint('Not passed Insaurance');
        }

        // var imageFile =
        //     await http.MultipartFile.fromPath('image[]', _image!.path);
        // request.files.add(imageFile);
        // }
        debugPrint('${request.files}');
        request.headers.addAll(headers);
        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var uploadDocument = UploadDocModel.fromJson(jsonResponse);

        debugPrint('Response status code: ${response.statusCode}');
        debugPrint('Response body: ${responsed.body}');

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (uploadDocument.status == 1) {
            setString(
                'drivinglicence', uploadDocument.responses!.drivingLicence!);
            setString('vehicleRegistration',
                uploadDocument.responses!.vehicleRegistrationDocuments!);
            setString('vehicleInsaurance',
                uploadDocument.responses!.vehicleInsuranceNumber!);
            setString('isAdded', '1');

            if (!mounted) return;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MySuccessScreen()));

            // setString('userlogin', '1');
            // setString('isCompleted', 'true');
            // setString('profilepic',
            //     uploadDocument.profile!.profileImage.toString());

            // CollectionReference user =
            //     FirebaseFirestore.instance.collection('users');
            // DocumentReference mainDocRef =
            //     user.doc(uploadDocument.profile!.id.toString());
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
              desc: uploadDocument.message,
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
            desc: uploadDocument.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
          debugPrint(uploadDocument.message);
        } else if (response.statusCode == 401) {
          debugPrint('401');
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadDocument.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();

          debugPrint(uploadDocument.message);
        } else if (response.statusCode == 500) {
          debugPrint('500');
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadDocument.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();

          debugPrint(uploadDocument.message);
        } else if (response.statusCode == 404) {
          debugPrint('404');
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: uploadDocument.message,
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();

          debugPrint(uploadDocument.message);
        }
      } catch (e) {
        ProgressDialogUtils.dismissProgressDialog();
        debugPrint('The Error is Here :- $e');
        if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: background,
        leading: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 24,
                color: whitecolor,
              )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: getTextWidget(
                  title: 'Upload Some Legal Documents & Details',
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
                    padding: const EdgeInsets.only(top: 14.0),
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
            ))
          ],
        ),
      ),
    );
  }

  Widget getButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 32.0),
      child: CustomizeButton(
        text: 'Submit',
        onPressed: () {
          uploadDocumentapi();
        },
      ),
    );
  }

  Widget _getImageDriving() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _imageDriving == null && _imagedrivingfile == null
          ? DottedBorder(
              dashPattern: const [4, 4],
              strokeWidth: 1,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              color: taptoupload,
              child: GestureDetector(
                onTap: () {
                  _showBottomSheetDriving();
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
                        _showBottomSheetDriving();
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
                              title: 'Tap to upload documents',
                              textFontSize: fontSize14,
                              textColor: taptoupload,
                              textFontWeight: fontWeightRegular),
                        ],
                      ),
                    )),
              ),
            )
          : _imageDriving != null
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 206,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // color: uploadphoto,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageDriving!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 206,
                  decoration: BoxDecoration(
                    color: uploadphoto,
                    border: Border.all(color: blackcolor, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 44,
                        color: Colors.blue,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        _imagedrivingfile!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _getImageRegistration() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _imageRegistration == null && _imageRegistrationfile == null
          ? DottedBorder(
              dashPattern: const [4, 4],
              strokeWidth: 1,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              color: taptoupload,
              child: GestureDetector(
                onTap: () {
                  _showBottomSheetRegistration();
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
                        _showBottomSheetRegistration();
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
                              title: 'Tap to upload documents',
                              textFontSize: fontSize14,
                              textColor: taptoupload,
                              textFontWeight: fontWeightRegular),
                        ],
                      ),
                    )),
              ),
            )
          : _imageRegistration != null
              ? Container(
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
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 206,
                  decoration: BoxDecoration(
                    color: uploadphoto,
                    border: Border.all(color: blackcolor, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 44,
                        color: Colors.blue,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        _imageRegistrationfile!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _getImageInsaurance() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: _imageInsaurance == null && _imageInsaurancefile == null
          ? DottedBorder(
              dashPattern: const [4, 4],
              strokeWidth: 1,
              borderType: BorderType.RRect,
              radius: const Radius.circular(10),
              color: taptoupload,
              child: GestureDetector(
                onTap: () {
                  _showBottomSheetInsaurance();
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
                        _showBottomSheetInsaurance();
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
                              title: 'Tap to upload documents',
                              textFontSize: fontSize14,
                              textColor: taptoupload,
                              textFontWeight: fontWeightRegular),
                        ],
                      ),
                    )),
              ),
            )
          : _imageInsaurance != null
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 206,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // color: uploadphoto,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageInsaurance!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 206,
                  decoration: BoxDecoration(
                    color: uploadphoto,
                    border: Border.all(color: blackcolor, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 44,
                        color: Colors.blue,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        _imageInsaurancefile!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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
        _imageInsaurance = imgTemp;
      });
    } catch (e) {
      debugPrint("Failed to open $e");
    }
  }

  Future<void> _pickdrivingFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _imagedrivingfile = result.files.single.path!;
        });
        // Use the filePath as needed (e.g., upload it to a server or process locally).
        debugPrint('Selected file: $_imagedrivingfile');
      } else {
        // User canceled the picker
        debugPrint('File picking canceled.');
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _pickregistrationFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _imageRegistrationfile = result.files.single.path!;
        });
        // Use the filePath as needed (e.g., upload it to a server or process locally).
        debugPrint('Selected file: $_imageRegistrationfile');
      } else {
        // User canceled the picker
        debugPrint('File picking canceled.');
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _pickinsauranceFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _imageInsaurancefile = result.files.single.path!;
        });
        // Use the filePath as needed (e.g., upload it to a server or process locally).
        debugPrint('Selected file: $_imageInsaurancefile');
      } else {
        // User canceled the picker
        debugPrint('File picking canceled.');
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  // void _pickdrivingFile() async {
  //   // opens storage to pick files and the picked file or files
  //   // are assigned into result and if no file is chosen result is null.
  //   // you can also toggle "allowMultiple" true or false depending on your need
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: true);

  //   // if no file is picked
  //   if (result == null) return;

  //   // we get the file from result object
  //   final file = result.files.first;
  //   setState(() {
  //     _imagedrivingfile = file;
  //   });

  //   _openFile(_imagedrivingfile!);
  // }

  // void _pickregistrationFile() async {
  //   // opens storage to pick files and the picked file or files
  //   // are assigned into result and if no file is chosen result is null.
  //   // you can also toggle "allowMultiple" true or false depending on your need
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: true);

  //   // if no file is picked
  //   if (result == null) return;

  //   // we get the file from result object
  //   final file = result.files.first;
  //   setState(() {
  //     _imageRegistrationfile = file;
  //   });

  //   _openFile(_imageRegistrationfile!);
  // }

  // void _pickInsauranceFile() async {
  //   // opens storage to pick files and the picked file or files
  //   // are assigned into result and if no file is chosen result is null.
  //   // you can also toggle "allowMultiple" true or false depending on your need
  //   final result = await FilePicker.platform.pickFiles(allowMultiple: false);

  //   // if no file is picked
  //   if (result == null) return;

  //   // we get the file from result object
  //   final file = result.files.first;
  //   setState(() {
  //     _imageInsaurancefile = file;
  //   });

  //   _openFile(_imageInsaurancefile!);
  // }

  // void _openFile(PlatformFile file) {
  //   OpenFile.open(file.path);
  // }

  void _showBottomSheetDriving() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          // height: 150.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ListTile(
                leading: const Icon(Icons.file_copy),
                title: const Text('Pick from file'),
                onTap: () {
                  // Handle gallery button tap
                  _pickdrivingFile();
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
          // height: 150.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ListTile(
                leading: const Icon(Icons.file_copy),
                title: const Text('Pick from file'),
                onTap: () {
                  // Handle gallery button tap
                  _pickregistrationFile();
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
          // height: 150.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              ListTile(
                leading: const Icon(Icons.file_copy),
                title: const Text('Pick from file'),
                onTap: () {
                  // Handle gallery button tap
                  _pickinsauranceFile();
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
