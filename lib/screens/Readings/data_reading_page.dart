import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:flutter_bluetooth/shared/widgets/show_notfication.dart';
import 'package:flutter_bluetooth/utils/storage/cacheHelper.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DataReadingPage extends StatefulWidget {
  final Color gradientColor;
  final String cardName;
  final BluetoothDevice device;
  final String orderNumber;
  final BluetoothConnection connection;

  // final BluetoothDevice server;
  DataReadingPage(
      {Key key,
      this.gradientColor,
      this.cardName,
      this.device,
      this.orderNumber,
      this.connection})
      : super(key: key);

  @override
  _DataReadingPageState createState() => _DataReadingPageState();
}

class _DataReadingPageState extends State<DataReadingPage>
    with SingleTickerProviderStateMixin {
  bool isConnection = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool get isConnected =>
      widget.connection != null && widget.connection.isConnected;
  bool isDisconnecting = false;
  AnimationController _animationController;
  Animation<double> _animation;
  bool isOn = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    sendOnMessageToBluetooth(orderNumber: widget.orderNumber);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (_animationController.isCompleted) {
      setState(() {
        isOn = false;
      });
      _animationController.reverse();
    } else {
      setState(() {
        isOn = true;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    String bluetoothName = CacheData.getData(key: 'bluetooth_name') ?? '';

    String bluetoothAddress = CacheData.getData(key: 'bluetooth_address') ?? '';
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode ?? false;
    print(isOn);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      _startAnimation();
                      print('$bluetoothName -------------');
                      print('$bluetoothAddress -------------');
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              widget.gradientColor,
                              isDark ? Colors.grey : Colors.white
                            ]),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Color(0xfffffff).withOpacity(.05)
                                : Color(0xff040039).withOpacity(.15),
                            blurRadius: 30,
                          ),
                        ],
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      child: Icon(
                        isOn ? Icons.pause : Icons.play_arrow,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  isOn
                      ? 'يتم الأن قراءة البيانات ${widget.cardName}'
                      : 'انقر الزر لبدء قراءة البيانات ${widget.cardName} ',
                  style: TextStyle(fontSize: 18, fontFamily: 'Alexandria'),
                ),
                SizedBox(height: _w / 10),
                SfCartesianChart()
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(_w / 17, _w / 9.5, _w / 15, 0),
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
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
                        Icons.arrow_back,
                        size: _w / 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Method to send message,
  // تستخدم لأرسال رسالة وتلقي المعلومات
  void sendOnMessageToBluetooth({String orderNumber}) async {
    widget.connection.output.add(utf8.encode("$orderNumber" + "\r\n"));
    await widget.connection.output.allSent;
    show(_scaffoldKey, 'تم تشغيل ${widget.cardName}');
    setState(() {
      // _deviceState = 1; // device on
    });
  }
}
