import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/constant/api_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Item%20Summary/model/summary_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constant/color_constant.dart';
import '../../constant/font_constant.dart';
import '../../utils/dailog.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';
import '../../utils/sharedprefs.dart';
import '../../utils/textwidget.dart';

class MyItemSummary extends StatefulWidget {
  const MyItemSummary({super.key});

  @override
  State<MyItemSummary> createState() => _MyItemSummaryState();
}

class _MyItemSummaryState extends State<MyItemSummary> {
  String? orderId;
  String? date;
  String? userimg;
  String? username;
  String? address;
  String? houseno;
  String? zipcode;
  int? itemCount;
  DateTime? dateTime;
  String? totalPrice;
  int? statusPickup;
  int? statusCollectitem;
  int? statusOutofDelivery;
  int? statusDelivery;
  String? status;
  String? time;
  List<Items> items = [];

  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    itemlistapi();
  }

  Future<void> itemlistapi() async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      ProgressDialogUtils.showProgressDialog(context);
      try {
        var apiurl = viewsummaryurl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(getString('token'));

        var request = http.Request('POST', Uri.parse(apiurl));

        request.body = json.encode({
          'id': getInt('oid'),
        });

        debugPrint(request.body);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var itemListmodel = ViewSummaryModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (itemListmodel.status == 1) {
            setState(() {
              items = itemListmodel.data!.items!;
              orderId = itemListmodel.data!.rmdId ?? '';
              dateTime =
                  DateTime.parse(itemListmodel.data!.createdAt!).toLocal();
              date = DateFormat("dd MMM yy").format(dateTime!);
              time = DateFormat.jm().format(dateTime!);
              userimg = itemListmodel.data!.userImage ?? '';
              username = itemListmodel.data!.userName ?? '';
              address = itemListmodel.data!.address ?? '';
              zipcode = itemListmodel.data!.zipcode ?? '';
              houseno = itemListmodel.data!.houseNo ?? '';
              itemCount = itemListmodel.data!.itemCount ?? 0;
              statusPickup = itemListmodel.data!.isPickup ?? 0;
              statusCollectitem = itemListmodel.data!.isCollect ?? 0;
              statusOutofDelivery = itemListmodel.data!.isOfd ?? 0;
              statusDelivery = itemListmodel.data!.isCompleted ?? 0;
              totalPrice = itemListmodel.data!.totalAmount!.toString();

              isLoad = false;

              debugPrint("Date:- $date");
              debugPrint("Time:- $time");
            });

            if (statusPickup != 0 &&
                statusCollectitem == 0 &&
                statusOutofDelivery == 0 &&
                statusDelivery == 0) {
              setState(() {
                status = 'Picked up';
              });
            } else if (statusPickup != 0 &&
                statusCollectitem != 0 &&
                statusOutofDelivery == 0 &&
                statusDelivery == 0) {
              setState(() {
                status = 'Item collected';
              });
            } else if (statusPickup != 0 &&
                statusCollectitem != 0 &&
                statusOutofDelivery != 0 &&
                statusDelivery == 0) {
              setState(() {
                status = 'On the way';
              });
            } else if (statusPickup != 0 &&
                statusCollectitem != 0 &&
                statusOutofDelivery != 0 &&
                statusDelivery != 0) {
              setState(() {
                status = 'Delivered';
              });
            } else {
              status = 'Not Picked';
            }
            debugPrint(' status :-$status');
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
            desc: '${itemListmodel.message}',
            onPressed: () {
              Navigator.pop(context);
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
            desc: '${itemListmodel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${itemListmodel.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${itemListmodel.message}',
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'Order Summary',
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
        padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16.0),
        child: isLoad
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.transparent,
                ),
              )
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getTextWidget(
                                    title: 'Order ID',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightRegular,
                                    textColor: const Color(0xFF6C7381)),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                getTextWidget(
                                    title: orderId!.toString(),
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightMedium,
                                    textColor: background),
                              ]),
                          const SizedBox(
                            width: 48.0,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getTextWidget(
                                    title: 'Date',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightRegular,
                                    textColor: const Color(0xFF6C7381)),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                getTextWidget(
                                    title: date!.toString(),
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightMedium,
                                    textColor: background),
                              ]),
                        ]),
                    getContainer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 26.0, top: 24.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTextWidget(
                                      title: 'Status',
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightRegular,
                                      textColor: const Color(0xFF6C7381)),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  getTextWidget(
                                      title: status!.toString(),
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightMedium,
                                      textColor: background),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTextWidget(
                                      title: 'No. of Items',
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightRegular,
                                      textColor: const Color(0xFF6C7381)),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  getTextWidget(
                                      title: itemCount!.toString(),
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightMedium,
                                      textColor: background),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTextWidget(
                                      title: 'Delivery by',
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightRegular,
                                      textColor: const Color(0xFF6C7381)),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  getTextWidget(
                                      title: time!.toString(),
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightMedium,
                                      textColor: background),
                                ]),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                getTextWidget(
                                    title: 'Total Amount',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightRegular,
                                    textColor: const Color(0xFF6C7381)),
                                const SizedBox(
                                  height: 4.0,
                                ),
                                getTextWidget(
                                    title: '\$ $totalPrice',
                                    textFontSize: fontSize13,
                                    textFontWeight: fontWeightMedium,
                                    textColor: background),
                              ]),
                          Padding(
                            padding: const EdgeInsets.only(left: 42.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTextWidget(
                                      title: 'Payment',
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightRegular,
                                      textColor: const Color(0xFF6C7381)),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  getTextWidget(
                                      title: 'Paid by Card',
                                      textFontSize: fontSize13,
                                      textFontWeight: fontWeightMedium,
                                      textColor: background),
                                ]),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: getTextWidget(
                          title: 'Items',
                          textFontSize: fontSize20,
                          textFontWeight: fontWeightSemiBold,
                          textColor: background),
                    ),
                    getItems()
                  ],
                ),
              ),
      ),
    );
  }

  Widget getItems() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 13.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: CachedNetworkImage(
                      imageBuilder: (context, imageProvider) => Container(
                        height: 71.0,
                        width: 71.0,
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
                          height: 71.0,
                          width: 71.0,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.rectangle),
                        ),
                      ),
                      imageUrl: items[index].productImage!.toString(),
                      height: 71.0,
                      width: 71.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        getTextWidget(
                            title: items[index].productName.toString(),
                            textFontSize: fontSize15,
                            textFontWeight: fontWeightSemiBold,
                            textColor: background),
                        Padding(
                          padding: const EdgeInsets.only(top: 17.0),
                          child: getTextWidget(
                              title: '\$ ${items[index].productPrice}',
                              textFontSize: fontSize15,
                              textFontWeight: fontWeightSemiBold,
                              textColor: orangecolor),
                        )
                      ],
                    ),
                  ),
                  // Expanded(
                  //     child: Align(
                  //   alignment: Alignment.centerRight,
                  //   child: IconButton(
                  //       onPressed: () {
                  //         setState(() {
                  //           items[index].isChecked = !items[index].isChecked;
                  //         });
                  //       },
                  //       icon: Image.asset(
                  //         items[index].isChecked == true
                  //             ? icChecked
                  //             : icUnChecked,
                  //         height: 29,
                  //         width: 29,
                  //         fit: BoxFit.cover,
                  //       )),
                  // ))
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Divider(
                  color: dividercolor,
                  thickness: 1.0,
                  height: 2.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getContainer() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFF0F0F0)),
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 15.0, right: 15),
          child: Column(
            children: [
              Row(children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageBuilder: (context, imageProvider) => Container(
                      height: 49.0,
                      width: 49.0,
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
                        height: 49.0,
                        width: 49.0,
                        decoration: const BoxDecoration(
                            color: Colors.grey, shape: BoxShape.circle),
                      ),
                    ),
                    imageUrl: userimg.toString(),
                    height: 49.0,
                    width: 49.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11.0),
                  child: getTextWidget(
                    title: username!.toString(),
                    textFontSize: fontSize18,
                    textFontWeight: fontWeightSemiBold,
                    textColor: background,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _makePhoneCall(getString('custmobilenum'));
                  },
                  child: Image.asset(
                    icCall,
                    height: 49,
                    width: 49,
                    fit: BoxFit.cover,
                  ),
                )
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 13.0),
                child: Container(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 15.0, bottom: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: whitecolor,
                      borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTextWidget(
                          title: 'Delivery location',
                          textFontSize: fontSize13,
                          textFontWeight: fontWeightRegular,
                          textColor: const Color(0xFF6C7381)),
                      const SizedBox(
                        height: 6.0,
                      ),
                      getTextWidget(
                          maxLines: 5,
                          title: '$houseno , $address , $zipcode',
                          textFontSize: fontSize13,
                          textFontWeight: fontWeightMedium,
                          textColor: background),
                    ],
                  ),
                ),
              )
            ],
          ),
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
