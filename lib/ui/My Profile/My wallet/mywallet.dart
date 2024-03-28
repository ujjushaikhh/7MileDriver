import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/utils/button.dart';
import 'package:flutter/material.dart';

import '../../../constant/color_constant.dart';
import '../../../constant/font_constant.dart';
import '../../../utils/textwidget.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitecolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0.0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: getTextWidget(
              title: 'My Wallet',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 4.3,
              decoration: const BoxDecoration(
                color: background,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: getTextWidget(
                                    title: '\$',
                                    textFontSize: fontSize25,
                                    textFontWeight: fontWeightSemiBold,
                                    textColor: whitecolor),
                              ),
                              getTextWidget(
                                  title: '2039',
                                  textFontSize: fontSize45,
                                  textFontWeight: fontWeightSemiBold,
                                  textColor: whitecolor),
                            ],
                          ),
                          getTextWidget(
                              title: 'Total Balance',
                              textFontSize: fontSize14,
                              textFontWeight: fontWeightMedium,
                              textColor: whitecolor),
                        ]),
                        Container(
                          height: 65,
                          width: 1.5,
                          color: const Color(0xFF39455A),
                        ),
                        Column(children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: getTextWidget(
                                    title: '\$',
                                    textFontSize: fontSize25,
                                    textFontWeight: fontWeightSemiBold,
                                    textColor: whitecolor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 36.0),
                                child: getTextWidget(
                                    title: '2k',
                                    textFontSize: fontSize45,
                                    textFontWeight: fontWeightSemiBold,
                                    textColor: whitecolor),
                              ),
                            ],
                          ),
                          getTextWidget(
                              title: 'Transferred',
                              textFontSize: fontSize14,
                              textFontWeight: fontWeightMedium,
                              textColor: whitecolor),
                        ]),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: CustomizeButton(
                          text: 'Transfer to bank account', onPressed: () {}),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: getTextWidget(
                  title: 'Bank Details',
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightBold,
                  textColor: background),
            ),
            getBank(),
            getMaster(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16),
              child: getTextWidget(
                  title: 'Your Payouts',
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightBold,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
              child: getTextWidget(
                  title:
                      'Automatic deposits every Monday, free of charge. 2-3 days for the deposits to show on your bank statement.',
                  textFontSize: fontSize14,
                  textFontWeight: fontWeightRegular,
                  textColor: background),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 21.0, left: 16),
              child: getTextWidget(
                  title: 'Order Info',
                  textFontSize: fontSize20,
                  textFontWeight: fontWeightBold,
                  textColor: background),
            ),
            getAcceptOrder(),
            const Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: Divider(
                color: dividercolor,
                thickness: 1.0,
                height: 2.0,
              ),
            ),
            getCancelOrder(),
            const Padding(
              padding: EdgeInsets.only(top: 18.0),
              child: Divider(
                color: dividercolor,
                thickness: 1.0,
                height: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getAcceptOrder() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
      child: Row(
        children: [
          getTextWidget(
              title: 'Accepted Orders',
              textFontSize: fontSize14,
              textFontWeight: fontWeightMedium,
              textColor: background),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      icOrderContainer,
                    ),
                    fit: BoxFit.cover),
              ),
              child: Center(
                child: getTextWidget(
                    title: '34',
                    textFontSize: fontSize14,
                    textFontWeight: fontWeightMedium,
                    textColor: orangecolor),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget getCancelOrder() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
      child: Row(
        children: [
          getTextWidget(
              title: 'Cancelled Orders',
              textFontSize: fontSize14,
              textFontWeight: fontWeightMedium,
              textColor: background),
          Expanded(
              child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFFEF3F1)
                  // image: DecorationImage(
                  //     image: AssetImage(
                  //       icOrderContainer,
                  //     ),
                  //     fit: BoxFit.cover)

                  ),
              child: Center(
                child: getTextWidget(
                    title: '21',
                    textFontSize: fontSize14,
                    textFontWeight: fontWeightMedium,
                    textColor: orangecolor),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget getBank() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: orangeBorder)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 11, bottom: 10, left: 10, right: 10),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                icVisa,
                height: 39,
                width: 63,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: getTextWidget(
                    title: 'XXXX XXXX XXXX 3243',
                    textFontSize: fontSize15,
                    textFontWeight: fontWeightMedium,
                    textColor: blackcolor),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    icMore,
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getMaster() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: orangeBorder)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 11, bottom: 10, left: 10, right: 10),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                icMaster,
                height: 39,
                width: 63,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: getTextWidget(
                    title: 'XXXX XXXX XXXX 3243',
                    textFontSize: fontSize15,
                    textFontWeight: fontWeightMedium,
                    textColor: blackcolor),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    icMore,
                    height: 24,
                    width: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
