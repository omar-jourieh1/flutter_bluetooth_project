import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:flutter_bluetooth/screens/Bluetooh/bluetooth_screen,.dart';
import 'package:flutter_bluetooth/screens/settings/settings.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:flutter_bluetooth/shared/widgets/home_page_card.dart';
import 'package:flutter_bluetooth/shared/widgets/home_page_cards_group.dart';
import 'package:flutter_bluetooth/utils/storage/cacheHelper.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../Bluetooh/led.dart';
import '../../main.dart';
import '../Readings/data_reading_page.dart';

class HomePage extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothConnection connection;
  HomePage({this.device, this.connection, Key key});
  @override
  _HomePageState createState() => _HomePageState();
}

//محتوى
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
          ..addListener(() {
            setState(() {});
          });

    _animation2 = Tween<double>(begin: -30, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.dispose();
    super.dispose();
  }

  //صناديق
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode ?? false;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            /// ListView
            ListView(
              physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                Padding(
                  padding:
                      EdgeInsets.fromLTRB(_w / 17, _w / 20, _w / 17, _w / 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الصحة',
                        style: TextStyle(
                          fontSize: 35,
                          // color: Colors.black.withOpacity(.8),
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: _w / 50),
                      Text(
                        'الفحص الذاتي',
                        style: TextStyle(
                          fontSize: 22,
                          // color: Colors.black.withOpacity(.8),
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                homePageCardsGroup(
                    _animation,
                    _animation2,
                    Color(0xfff37736),
                    // Icons.analytics_outlined,
                    FontAwesomeIcons.heartbeat,
                    'نبضات القلب',
                    context,
                    DataReadingPage(
                        gradientColor: Color(0xfff37736),
                        cardName: 'نبضات القلب',
                        orderNumber: '1',
                        connection: widget.connection),
                    Color(0xffFF6D6D),
                    Icons.all_inclusive,
                    'أكسجة الدم',
                    DataReadingPage(
                        gradientColor: Color(0xffFF6D6D),
                        cardName: 'أكسجة الدم',
                        orderNumber: '2',
                        connection: widget.connection),
                    true),
                homePageCardsGroup(
                    _animation,
                    _animation2,
                    Colors.lightGreen,
                    // Icons.gamepad_outlined,
                    FontAwesomeIcons.temperatureHigh,
                    'الحرارة',
                    context,
                    DataReadingPage(
                        gradientColor: Colors.lightGreen,
                        cardName: 'الحرارة',
                        orderNumber: '3',
                        connection: widget.connection),
                    Color(0xffffa700),
                    // Icons.article,
                    FontAwesomeIcons.fire,
                    'الرطوبة',
                    DataReadingPage(
                        gradientColor: Color(0xffffa700),
                        cardName: 'الرطوبة',
                        orderNumber: '4',
                        connection: widget.connection),
                    true),
                homePageCardsGroup(
                    _animation,
                    _animation2,
                    Color(0xff63ace5),
                    FontAwesomeIcons.fulcrum,
                    'معدل الروائح',
                    context,
                    DataReadingPage(
                        gradientColor: Color(0xff63ace5),
                        cardName: 'معدل الروائح',
                        orderNumber: '5',
                        connection: widget.connection),
                    Color(0xfff37736),
                    Icons.gps_fixed,
                    'GPS',
                    HomePage(),
                    false),
                Padding(
                  padding: EdgeInsets.only(right: _w / 17, bottom: _w / 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      homePageCard(
                          _animation,
                          _animation2,
                          Color(0xff0000),
                          FontAwesomeIcons.walking,
                          'حساس حركة',
                          context,
                          DataReadingPage(
                              gradientColor: Color(0xff0000),
                              cardName: 'حساس حركة',
                              orderNumber: '6',
                              connection: widget.connection),
                          true),
                    ],
                  ),
                ),
              ],
            ),

            /// SETTING ICON & Bluetooth ICON
            Padding(
              padding: EdgeInsets.fromLTRB(_w / 17, _w / 9.5, _w / 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // InkWell(
                  //   highlightColor: Colors.transparent,
                  //   splashColor: Colors.transparent,
                  //   onTap: () {
                  //     HapticFeedback.lightImpact();
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return BluetoothScreen();
                  //         },
                  //       ),
                  //     );
                  //   },
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.all(Radius.circular(99)),
                  //     child: BackdropFilter(
                  //       filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                  //       child: Container(
                  //         height: _w / 8.5,
                  //         width: _w / 8.5,
                  //         decoration: BoxDecoration(
                  //           color: isDark
                  //               ? Colors.white.withOpacity(.05)
                  //               : Colors.black.withOpacity(.05),
                  //           shape: BoxShape.circle,
                  //         ),
                  //         child: Center(
                  //           child: Icon(
                  //             Icons.bluetooth,
                  //             size: _w / 17,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Settings();
                          },
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                        child: Container(
                          height: _w / 8.5,
                          width: _w / 8.5,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(.05)
                                : Colors.black.withOpacity(.05),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.settings,
                              size: _w / 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
// Blur the Status bar
            blurTheStatusBar(context),
          ],
        ),
      ),
    );
  }

  Widget blurTheStatusBar(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
        child: Container(
          height: _w / 18,
          color: Colors.transparent,
        ),
      ),
    );
  }
}

// //نبضات القلب
// class heartbeats extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         elevation: 50,
//         centerTitle: true,
//         shadowColor: Colors.white.withOpacity(.5),
//         title: Text(
//           'نبضات القلب',
//           style: TextStyle(
//               color: Colors.white.withOpacity(.7),
//               fontFamily: "Alexandria",
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             // color: Colors.black.withOpacity(.8),
//           ),
//           onPressed: () => Navigator.maybePop(context),
//         ), // systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//     );
//   }
// }

// //أكسجة الدم
// class temper extends StatelessWidget {
//   @override
//   Widget build(BuildContext heart) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         elevation: 50,
//         centerTitle: true,
//         shadowColor: Colors.white.withOpacity(.5),
//         title: Text(
//           'أكسجة الدم',
//           style: TextStyle(
//               color: Colors.white.withOpacity(.7),
//               fontFamily: "Alexandria",
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             // color: Colors.black.withOpacity(.8),
//           ),
//           onPressed: () => Navigator.maybePop(heart),
//         ), // systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//     );
//   }
// }

// //الحرارة
// class heat extends StatelessWidget {
//   @override
//   Widget build(BuildContext temper) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         elevation: 50,
//         centerTitle: true,
//         shadowColor: Colors.white.withOpacity(.5),
//         title: Text(
//           'الحرارة',
//           style: TextStyle(
//               color: Colors.white.withOpacity(.7),
//               fontFamily: "Alexandria",
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             // color: Colors.black.withOpacity(.8),
//           ),
//           onPressed: () => Navigator.maybePop(temper),
//         ), // systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//     );
//   }
// }

// //الرطوبة
// class humidity extends StatelessWidget {
//   @override
//   Widget build(BuildContext temper) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         elevation: 50,
//         centerTitle: true,
//         shadowColor: Colors.white.withOpacity(.5),
//         title: Text(
//           'الرطوبة',
//           style: TextStyle(
//               color: Colors.white.withOpacity(.7),
//               fontFamily: "Alexandria",
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             // color: Colors.black.withOpacity(.8),
//           ),
//           onPressed: () => Navigator.maybePop(temper),
//         ), // systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//     );
//   }
// }

// //معدل الروائح
// class gases extends StatelessWidget {
//   @override
//   Widget build(BuildContext temper) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         elevation: 50,
//         centerTitle: true,
//         shadowColor: Colors.white.withOpacity(.5),
//         title: Text(
//           'معدل الروائح',
//           style: TextStyle(
//               color: Colors.white.withOpacity(.7),
//               fontFamily: "Alexandria",
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             // color: Colors.black.withOpacity(.8),
//           ),
//           onPressed: () => Navigator.maybePop(temper),
//         ), // systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//     );
//   }
// }

// //تتبع
// class gps extends StatelessWidget {
//   @override
//   Widget build(BuildContext temper) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         elevation: 50,
//         centerTitle: true,
//         shadowColor: Colors.white.withOpacity(.5),
//         title: Text(
//           'GBS',
//           style: TextStyle(
//               color: Colors.white.withOpacity(.7),
//               fontFamily: "Alexandria",
//               fontWeight: FontWeight.w500,
//               letterSpacing: 1),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             // color: Colors.black.withOpacity(.8),
//           ),
//           onPressed: () => Navigator.maybePop(temper),
//         ), // systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//     );
//   }
// }
