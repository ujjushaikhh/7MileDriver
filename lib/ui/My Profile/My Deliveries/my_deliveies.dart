import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/ui/My%20Profile/My%20Deliveries/model/deliveries_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constant/api_constant.dart';
import '../../../constant/color_constant.dart';
import '../../../constant/font_constant.dart';
import '../../../utils/dailog.dart';
import '../../../utils/internetconnection.dart';
import '../../../utils/progressdialogue.dart';
import '../../../utils/sharedprefs.dart';
import '../../../utils/textwidget.dart';

class MyDeliveries extends StatefulWidget {
  const MyDeliveries({super.key});

  @override
  State<MyDeliveries> createState() => _MyDeliveriesState();
}

class _MyDeliveriesState extends State<MyDeliveries> {
  String? date;
  bool isload = true;

  @override
  void initState() {
    super.initState();
    getdeliveriesapi();
  }

  List<Data> mydeliveries = [
    // MyDeliveriess(
    //     custImg: icCustomer,
    //     custName: 'Guys Hawkins',
    //     date: '26 June 23',
    //     location: '2464 Royal Ln. Mesa, New Jersey 45463',
    //     orderId: '#5729323482384HK',
    //     status: 'Delivered'),
    // MyDeliveriess(
    //     custImg: icCustomer,
    //     custName: 'Guys Hawkins',
    //     date: '26 June 23',
    //     location: '2464 Royal Ln. Mesa, New Jersey 45463',
    //     orderId: '#5729323482384HK',
    //     status: 'Delivered'),
    // MyDeliveriess(
    //     custImg: icCustomer,
    //     custName: 'Guys Hawkins',
    //     date: '26 June 23',
    //     location: '2464 Royal Ln. Mesa, New Jersey 45463',
    //     orderId: '#5729323482384HK',
    //     status: 'Cancelled')
  ];

  Future<void> getdeliveriesapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);
      try {
        var apiurl = mydeliveriesurl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(getString('token'));

        var request = http.Request('GET', Uri.parse(apiurl));

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var getdeliveries = MyDeliveriesModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (getdeliveries.status == 1) {
            setState(() {
              mydeliveries = getdeliveries.data ?? [];
              if (mydeliveries.isNotEmpty) {
                for (var dateTime in mydeliveries) {
                  DateTime datetime =
                      DateTime.parse(dateTime.createdAt!).toLocal();
                  date = DateFormat("dd MMM yyyy").format(datetime);
                }
              }

              isload = false;
            });
            debugPrint('is it success');
          } else {
            debugPrint('failed to load');
            setState(() {
              mydeliveries = [];
              isload = false;
            });
          }
        } else if (response.statusCode == 401) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${getdeliveries.message}',
            onPressed: () {},
          ).show();
        } else if (response.statusCode == 404) {
          ProgressDialogUtils.dismissProgressDialog();
          debugPrint('Status code :-${response.statusCode}');
          debugPrint('Error :-${getdeliveries.message}');

          setState(() {
            isload = false;
            mydeliveries = [];
          });
          // if (!mounted) return;
          // vapeAlertDialogue(
          //   context: context,
          //   desc: '${getdeliveries.message}',
          //   onPressed: () {
          //     Navigator.pop(context);
          //   },
          // );
        } else if (response.statusCode == 400) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${getdeliveries.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          if (!mounted) return;
          ProgressDialogUtils.dismissProgressDialog();
          vapeAlertDialogue(
            context: context,
            desc: '${getdeliveries.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        }
      } catch (e) {
        debugPrint("$e");
        if (!mounted) return;
        ProgressDialogUtils.dismissProgressDialog();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'My Deliveries',
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
      body: isload
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.transparent,
              ),
            )
          : mydeliveries.isEmpty
              ? Center(
                  child: getTextWidget(
                      title: 'No Deliveries yet',
                      textFontSize: fontSize20,
                      textColor: background,
                      textFontWeight: fontWeightBold),
                )
              : ListView.builder(
                  itemCount: mydeliveries.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 17.0, left: 16.0, right: 16.0),
                          child: Column(
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
                                      imageUrl: mydeliveries[index]
                                          .userImage
                                          .toString(),
                                      height: 35.0,
                                      width: 35.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 13.0,
                                    ),
                                    child: getTextWidget(
                                        title: mydeliveries[index]
                                            .userName
                                            .toString(),
                                        textFontSize: fontSize14,
                                        textFontWeight: fontWeightSemiBold,
                                        textColor: background),
                                  ),
                                  const Spacer(),
                                  mydeliveries[index].isCompleted == 1
                                      ? Container(
                                          padding: const EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                              color: greencolor,
                                              borderRadius:
                                                  BorderRadius.circular(2)),
                                          child: getTextWidget(
                                              title: 'Delivered',
                                              textColor: whitecolor,
                                              textFontSize: fontSize12,
                                              textFontWeight:
                                                  fontWeightExtraBold),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                              color: orangecolor,
                                              borderRadius:
                                                  BorderRadius.circular(2)),
                                          child: getTextWidget(
                                              title: 'Cancelled',
                                              textColor: whitecolor,
                                              textFontSize: fontSize12,
                                              textFontWeight:
                                                  fontWeightExtraBold),
                                        )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 51.0),
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
                                            '${mydeliveries[index].houseNo} , ${mydeliveries[index].address} , ${mydeliveries[index].zipcode}',
                                        textFontSize: fontSize13,
                                        textFontWeight: fontWeightMedium,
                                        textColor: background),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, right: 16.0),
                                      child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getTextWidget(
                                                      title: 'Order ID',
                                                      textFontSize: fontSize13,
                                                      textFontWeight:
                                                          fontWeightRegular,
                                                      textColor: const Color(
                                                          0xFF6C7381)),
                                                  getTextWidget(
                                                      title: mydeliveries[index]
                                                          .rmdOrderId
                                                          .toString(),
                                                      textFontSize: fontSize13,
                                                      textFontWeight:
                                                          fontWeightMedium,
                                                      textColor: background),
                                                ]),
                                            const SizedBox(
                                              width: 27.0,
                                            ),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  getTextWidget(
                                                      title: 'Date',
                                                      textFontSize: fontSize13,
                                                      textFontWeight:
                                                          fontWeightRegular,
                                                      textColor: const Color(
                                                          0xFF6C7381)),
                                                  getTextWidget(
                                                      title: date!.toString(),
                                                      textFontSize: fontSize13,
                                                      textFontWeight:
                                                          fontWeightMedium,
                                                      textColor: background),
                                                ]),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Divider(
                            color: dividercolor,
                            thickness: 1.0,
                            height: 3.0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
