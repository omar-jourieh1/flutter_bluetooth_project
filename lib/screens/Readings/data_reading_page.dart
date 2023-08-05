import 'dart:convert';
import 'dart:typed_data';
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

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _DataReadingPageState extends State<DataReadingPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  AnimationController _animationController;
  Animation<double> _animation;
  bool isOn = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress('00:22:06:01:0D:66').then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
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
    // sendOnMessageToBluetooth(orderNumber: widget.orderNumber);
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
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
    int alarm;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode ?? false;
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  alarm = int.parse(text);

                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(fontFamily: 'Alexandria')),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: _w / 1.2,
            decoration: BoxDecoration(
                color: widget.orderNumber == '1' //نبضات القلب
                    ? (alarm >= 60 && alarm <= 100
                        ? Colors.green
                        : alarm > 100 ? Colors.red : Colors.orange)
                    : widget.orderNumber == '2' //اكسجة الدم
                        ? (alarm >= 94 && alarm <= 99
                            ? Colors.green
                            : alarm < 94
                                ? Colors.orange
                                : alarm > 100 ? Colors.red : Colors.green)
                        : widget.orderNumber == '3' //الحرارة
                            ? (alarm >= 38 && alarm <= 39
                                ? Colors.orange[700]
                                : alarm >= 40 ? Colors.red : Colors.green)
                            : widget.orderNumber == '4' //الرطوبة
                                ? (alarm <= 60 && alarm >= 30
                                    ? Colors.green
                                    : alarm >= 70
                                        ? Colors.red
                                        : alarm < 30
                                            ? Colors.orange
                                            : Colors.green)
                                : widget.orderNumber == '5' //معدل الروائح
                                    ? (alarm >= 400 && alarm <= 900
                                        ? Colors.orange[700]
                                        : alarm >= 900
                                            ? Colors.red
                                            : Colors.green)
                                    : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.center,
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: (isConnecting
              ? Text(
                  ' الأتصال مع حساس' + ' ' + widget.cardName + '.....',
                  style: TextStyle(
                      fontFamily: "Alexandria",
                      color: isDark ? Colors.white : Colors.black),
                )
              : isConnected
                  ? Text(
                      'متصل بحساس' + ' ' + widget.cardName,
                      style: TextStyle(
                          fontFamily: "Alexandria",
                          color: isDark ? Colors.white : Colors.black),
                    )
                  : Text(
                      'تم فصل مع حساس' + ' ' + widget.cardName,
                      style: TextStyle(
                          fontFamily: "Alexandria",
                          color: isDark ? Colors.white : Colors.black),
                    ))),
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              // height: 120,
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
          ),
          SizedBox(height: 10),
          Text(
            isOn
                ? widget.orderNumber == '1' //نبضات القلب
                    ? (alarm >= 60 && alarm <= 100
                        ? 'نبضات القلب طبيعية'
                        : alarm > 100
                            ? 'تسارع في دقات القلب يرجى مراجعة الطبيب'
                            : alarm < 60
                                ? 'مراجعة الطبيب'
                                : 'نبضات القلب طبيعية')
                    : widget.orderNumber == '2' //اكسجة الدم
                        ? (alarm >= 94 && alarm <= 99
                            ? 'أكسجة الدم طبيعية'
                            : alarm < 94
                                ? 'نقص في أكسجة الدم يرجى مراجعة الطبيب'
                                : alarm > 100
                                    ? 'فرط في أكسجة الدم ويرجى مراجعة الطبيب'
                                    : 'أكسجة الدم طبيعية')
                        : widget.orderNumber == '3' //الحرارة
                            ? (alarm >= 38 && alarm <= 39
                                ? 'حرارة مرتفعة ومرضية'
                                : alarm >= 40
                                    ? 'يرجى مرتفعة جداً مراجعة الطبيب بشكل فوري'
                                    : 'حرارة طبيعي')
                            : widget.orderNumber == '4' //الرطوبة
                                ? (alarm <= 60 && alarm >= 30
                                    ? 'مستوى طبيعي وصحي'
                                    : alarm >= 70
                                        ? 'مستوى رطوبة عالي'
                                        : alarm < 30
                                            ? 'مستوى رطوبة منخفض'
                                            : 'مستوى طبيعي وصحي')
                                : widget.orderNumber == '5' //معدل الروائح
                                    ? ((alarm >= 400 && alarm <= 900
                                        ? 'نسبة الغاز مرتفعة'
                                        : alarm >= 900
                                            ? 'يرجى مغادرة المكان'
                                            : 'نسبة الغاز طبيعية'))
                                    : 'test'
                : 'انقر الزر لبدء قراءة البيانات ${widget.cardName} ',
            style: TextStyle(fontSize: 18, fontFamily: 'Alexandria'),
          ),
          SizedBox(height: 10),
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
                if (isConnected == false) {
                  show(_scaffoldKey, 'انتظر حتى يتصل');
                } else {
                  _startAnimation();
                  if (isOn && isConnected) {
                    _sendMessage(widget.orderNumber);
                  }
                }
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
          SizedBox(height: _w / 10),
        ],
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    String dataString = String.fromCharCodes(data);
    setState(() {
      messages.add(_Message(1, dataString));
    });

    Future.delayed(Duration(milliseconds: 333)).then((_) {
      listScrollController.animateTo(
        listScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 333),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
        if (messages.length < 1) {
          setState(() {
            messages.add(_Message(0, '0'));
          });
        }
        Future.delayed(Duration(milliseconds: 333)).then((_) {
          if (listScrollController.positions.isNotEmpty) {
            listScrollController.animateTo(
                listScrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 333),
                curve: Curves.easeOut);
          } else {}
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
// Method to send message,
// // تستخدم لأرسال رسالة وتلقي المعلومات
// void sendOnMessageToBluetooth({String orderNumber}) async {
//   widget.connection.output.add(utf8.encode("$orderNumber" + "\r\n"));
//   await widget.connection.output.allSent;
//   show(_scaffoldKey, 'تم تشغيل ${widget.cardName}');
//   setState(() {
//     // _deviceState = 1; // device on
//   });
// }
