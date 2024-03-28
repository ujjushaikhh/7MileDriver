import 'package:driverflow/constant/color_constant.dart';
import 'package:driverflow/constant/font_constant.dart';
import 'package:driverflow/constant/image_constant.dart';
import 'package:driverflow/utils/textwidget.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../utils/sharedprefs.dart';
import '../login/login.dart';

class MyIntro extends StatefulWidget {
  const MyIntro({super.key});

  @override
  State<MyIntro> createState() => _MyIntroState();
}

class _MyIntroState extends State<MyIntro> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  final List title = [
    'Lorem ipsum dolor sit amet, consectetur.',
    'Aenean  dignissim metus vitae'
  ];

  final List subTitle = [
    'Find the perfect home for your holiday accommodation',
    'Find the perfect home for your holiday accommodation'
  ];
  final List image = [icIntor1, icIntor2];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: background,
            image: DecorationImage(image: AssetImage(icBackground))),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: title.length,
                itemBuilder: (context, index, realIndex) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 56.0),
                        child: Image.asset(
                          image[index],
                          height: 330,
                          width: 330,
                        ),
                      ),
                      getTitle(title[index]),
                      getSubTitle(subTitle[index]),
                    ],
                  );
                },
                options: CarouselOptions(
                  // scrollPhysics: const NeverScrollableScrollPhysics(),
                  initialPage: 0,
                  viewportFraction: 1.0,
                  height: MediaQuery.of(context).size.height / 1.2,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                )),
            getBottomBar()
          ],
        ),
      ),
    );
  }

  void _onNextPress() {
    if (_currentIndex < title.length - 1) {
      _carouselController.nextPage();
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MyLogin()));
      setBool('seen', true);
    }
  }

  void onSkipPress() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyLogin()),
      (route) => false,
    );
    await setBool('seen', true);
  }

  Widget getBottomBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 16.0),
      child: Row(
        children: [
          _currentIndex == 0
              ? GestureDetector(
                  onTap: () {
                    onSkipPress();
                  },
                  child: getTextWidget(
                      title: 'Skip',
                      textFontSize: fontSize14,
                      textFontWeight: fontWeightRegular),
                )
              : Container(),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Image.asset(
                  _currentIndex == 0 ? icIndicator1 : icIndicator2,
                  height: 3,
                  width: 48,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(right: 16.0),
              //   child: Image.asset(
              //     icIndicator2,
              //     height: 3,
              //     width: 48,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                    onTap: () {
                      _onNextPress();
                    },
                    child: _currentIndex == 0
                        ? Container(
                            width: 56,
                            height: 58,
                            decoration: ShapeDecoration(
                              color: greencolor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  _onNextPress();
                                },
                                icon: Image.asset(
                                  icRightArrow,
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.cover,
                                )),
                          )
                        : GestureDetector(
                            onTap: () {
                              _onNextPress();
                            },
                            child: Container(
                              width: 122,
                              height: 58,
                              decoration: ShapeDecoration(
                                color: greencolor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Center(
                                child: getTextWidget(
                                    title: 'Get Started',
                                    textFontSize: fontSize14,
                                    textFontWeight: fontWeightMedium,
                                    textColor: background),
                              ),
                            ),
                          )),
              )
            ],
          )),
        ],
      ),
    );
  }

  Widget getTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 48),
      child: getTextWidget(
          title: title,
          textColor: whitecolor,
          textFontSize: fontSize40,
          textFontWeight: fontWeightBold),
    );
  }

  Widget getSubTitle(String subTitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 34),
      child: Opacity(
        opacity: 0.60,
        child: getTextWidget(
            title: subTitle,
            textColor: whitecolor,
            textFontSize: fontSize16,
            textFontWeight: fontWeightRegular),
      ),
    );
  }
}
