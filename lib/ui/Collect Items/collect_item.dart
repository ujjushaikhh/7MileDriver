import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/ui/Collect%20Items/model/all_itemmodel.dart';
import 'package:driverflow/ui/Collect%20Items/model/item_tickmodel.dart';
import 'package:driverflow/ui/Home/Out%20of%20Delivery/out_of_delivery.dart';
import 'package:driverflow/utils/button.dart';
import 'package:driverflow/utils/sharedprefs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../../constant/api_constant.dart';
import '../../constant/color_constant.dart';
import '../../constant/font_constant.dart';
import '../../utils/dailog.dart';
import '../../utils/internetconnection.dart';
import '../../utils/progressdialogue.dart';
import '../../utils/textwidget.dart';
import '../Home/model/delivery_status.dart';

class MyCollectItems extends StatefulWidget {
  const MyCollectItems({
    super.key,
  });

  @override
  State<MyCollectItems> createState() => _MyCollectItemsState();
}

class _MyCollectItemsState extends State<MyCollectItems> {
  @override
  void initState() {
    super.initState();
    itemlistapi();
  }

  // final List<Items> items = [
  //   Items(itemImg: icItem1, itemName: 'Disposable Item', itemPrice: '129'),
  //   Items(itemImg: icItem2, itemName: 'Disposable Item', itemPrice: '129'),
  //   Items(itemImg: icItem3, itemName: 'Disposable Item', itemPrice: '129')
  // ];
  List<AllItems> _allitems = [];
  int isEnable = 0;
  Future<void> itemtickapi(int cartDetailId, int isCollected,
      {bool showprogress = true}) async {
    if (await checkUserConnection()) {
      if (showprogress) {
        if (!mounted) return;
        ProgressDialogUtils.showProgressDialog(context);
      }
      try {
        var apiurl = itemstatusurl;
        debugPrint(apiurl);
        var headers = {
          'authkey': 'Bearer ${getString('token')}',
          'Content-Type': 'application/json',
        };

        debugPrint(getString('token'));

        var request = http.Request('POST', Uri.parse(apiurl));

        request.body = json.encode({
          "cart_details_id": cartDetailId,
          "collected": isCollected,
        });

        debugPrint(request.body);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var itemSatus = ItemListModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (itemSatus.status == 1) {
            setState(() {
              debugPrint(itemSatus.message);
              itemlistapi(showProgress: false);
              // collected = itemSatus.data!.collected!;
              // debugPrint(collected);
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
            desc: '${itemSatus.message}',
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
            desc: '${itemSatus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${itemSatus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${itemSatus.message}',
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

  Future<void> itemlistapi({bool showProgress = true}) async {
    if (await checkUserConnection()) {
      if (!mounted) return;
      if (showProgress) {
        ProgressDialogUtils.showProgressDialog(context);
      }
      try {
        var apiurl = orderdetailsurl;
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
        var itemListmodel = AllItemsModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (itemListmodel.status == 1) {
            setState(() {
              _allitems = itemListmodel.data!.items!;
              bool isAnyItemNotCollected =
                  _allitems.any((item) => item.collected == 0);
              if (isAnyItemNotCollected) {
                isEnable = 0;
              } else {
                isEnable = 1;
              }

              debugPrint('Collected:- $isAnyItemNotCollected');
              // debugPrint(itemListmodel.message);
              // for (var iscollected in _allitems) {
              //   if (iscollected.collected == 0) {
              //     setState(() {
              //       isEnable = 0;
              //     });
              //   } else {
              //     setState(() {
              //       isEnable == 1;
              //     });
              //   }
              // }
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

  Future<void> deliverystatusapi() async {
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
          'is_pickup': 1,
          'is_collect': 1,
          'is_ofd': 1
        });

        debugPrint(request.body);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        final responsed = await http.Response.fromStream(response);
        var jsonResponse = jsonDecode(responsed.body);
        var itemSatus = DeliveryStatusModel.fromJson(jsonResponse);

        if (response.statusCode == 200) {
          debugPrint(responsed.body);
          ProgressDialogUtils.dismissProgressDialog();
          if (itemSatus.status == 1) {
            setState(() {
              debugPrint(itemSatus.message);

              Navigator.push(context,
                  MaterialPageRoute(builder: (contex) => const MyOnTheWay()));
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
            desc: '${itemSatus.message}',
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
            desc: '${itemSatus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 400) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${itemSatus.message}',
            onPressed: () {
              Navigator.pop(context);
            },
          ).show();
        } else if (response.statusCode == 500) {
          ProgressDialogUtils.dismissProgressDialog();
          if (!mounted) return;
          vapeAlertDialogue(
            context: context,
            desc: '${itemSatus.message}',
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'Order ID: ${getString('orderid')}',
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
      body: ListView.builder(
        itemCount: _allitems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 17.0, left: 16, right: 16),
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
                        imageUrl: _allitems[index].productImage!.toString(),
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
                              title: _allitems[index].productName.toString(),
                              textFontSize: fontSize15,
                              textFontWeight: fontWeightSemiBold,
                              textColor: background),
                          Padding(
                            padding: const EdgeInsets.only(top: 17.0),
                            child: getTextWidget(
                                title: '\$ ${_allitems[index].productPrice}',
                                textFontSize: fontSize15,
                                textColor: orangecolor),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            if (_allitems[index].collected == 0) {
                              itemtickapi(_allitems[index].cartDetailsId!, 1,
                                  showprogress: false);
                            } else if (_allitems[index].collected == 1) {
                              itemtickapi(_allitems[index].collected!, 0,
                                  showprogress: false);
                            }
                          },
                          icon: Image.asset(
                            _allitems[index].collected == 0
                                ? icUnChecked
                                : icChecked,
                            height: 29,
                            width: 29,
                            fit: BoxFit.cover,
                          )),
                    ))
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
      ),
      bottomNavigationBar: SizedBox(
        // height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16,
                top: 10.0,
                bottom: 16.0,
              ),
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
                    color: isEnable == 0 ? Colors.grey : greencolor,
                    text: 'Out for Delivery',
                    onPressed: () {
                      if (isEnable != 1) {
                        Fluttertoast.showToast(msg: 'Please select all item');
                      } else if (isEnable != 0) {
                        deliverystatusapi();
                      }
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
}

// class Items {
//   String? itemImg;
//   String? itemName;
//   String? itemPrice;
//   bool isChecked;

//   Items({this.itemImg, this.itemName, this.itemPrice, this.isChecked = true});
// }
