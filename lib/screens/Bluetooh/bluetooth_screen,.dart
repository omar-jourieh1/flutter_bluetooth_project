// For performing some operations asynchronously

// For using PlatformException
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/screens/Home/home.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:flutter_bluetooth/shared/widgets/show_notfication.dart';
import 'package:flutter_bluetooth/utils/storage/cacheHelper.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  //! Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    }).catchError((onError) {
      show(_scaffoldKey, 'لايوجد ميزة بلوتوث في هذا الجهاز');
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    // if (isConnected) {
    //   isDisconnecting = true;
    //   // connection.dispose();
    //   connection = null;
    // }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    if (BluetoothState.ERROR != null) {
      print('لايوجد ميزة بلوتوث في هذا الجهاز');
    } else {
      _bluetoothState = await FlutterBluetoothSerial.instance.state;

      // If the bluetooth is off, then turn it on first
      // and then retrieve the devices that are paired.
      if (_bluetoothState == BluetoothState.STATE_OFF) {
        await FlutterBluetoothSerial.instance.requestEnable();
        await getPairedDevices();
        return true;
      } else {
        await getPairedDevices();
      }
      return false;
    }
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode ?? false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          // backgroundColor: Colors.white,
          key: _scaffoldKey,
          body: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.fromLTRB(_w / 25, _w / 20, _w / 20, _w / 10),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: _w / 15,
                      ),
                      Text(
                        'إعداد بلوتوث',
                        style: TextStyle(
                          fontSize: 35,
                          fontFamily: "Alexandria",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Visibility(
                        visible: _isButtonUnavailable &&
                            _bluetoothState == BluetoothState.STATE_ON,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.yellow,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                      SizedBox(height: _w / 100),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'تشغيل البلوتوث',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Alexandria",
                                ),
                              ),
                            ),
                            Switch(
                              value: _bluetoothState.isEnabled,
                              onChanged: (bool value) {
                                future() async {
                                  if (_bluetoothState !=
                                      BluetoothState.UNKNOWN) {
                                    if (value) {
                                      await FlutterBluetoothSerial.instance
                                          .requestEnable();
                                    } else {
                                      await FlutterBluetoothSerial.instance
                                          .requestDisable();
                                    }
                                  } else if (_bluetoothState ==
                                      BluetoothState.UNKNOWN) {
                                    show(_scaffoldKey,
                                        'لايوجد ميزة بلوتوث في هذا الجهاز');
                                  }
                                  await getPairedDevices();
                                  _isButtonUnavailable = false;

                                  if (_connected) {
                                    _disconnect();
                                  }
                                }

                                future().then((_) {
                                  setState(() {});
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(height: _w / 9),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "الأجهزة المقترنة",
                                  style: TextStyle(
                                      fontFamily: "Alexandria",
                                      fontSize: 24,
                                      color: Colors.blue),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: _w / 6),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'الجهاز:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Alexandria",
                                      ),
                                    ),
                                    DropdownButton(
                                      items: _getDeviceItems(),
                                      onChanged: (value) =>
                                          setState(() => _device = value),
                                      value: _devicesList.isNotEmpty
                                          ? _device
                                          : null,
                                    ),
                                    RaisedButton(
                                      onPressed: _isButtonUnavailable
                                          ? null
                                          : _connected ? _disconnect : _connect,
                                      child: Text(
                                        _connected ? 'قطع الاتصال' : 'الاتصال',
                                        style: TextStyle(
                                          fontFamily: "Alexandria",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: new BorderSide(
                                      color: _deviceState == 0
                                          ? colors['neutralBorderColor']
                                          : _deviceState == 1
                                              ? colors['onBorderColor']
                                              : colors['offBorderColor'],
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  elevation: _deviceState == 0 ? 4 : 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "DEVICE 1",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: _deviceState == 0
                                                  ? colors['neutralTextColor']
                                                  : _deviceState == 1
                                                      ? colors['onTextColor']
                                                      : colors['offTextColor'],
                                            ),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: _connected
                                              ? _sendOnMessageToBluetooth
                                              : null,
                                          child: Text("ON"),
                                        ),
                                        FlatButton(
                                          onPressed: _connected
                                              ? _sendOffMessageToBluetooth
                                              : null,
                                          child: Text("OFF"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      SizedBox(height: _w / 6),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "ملاحطة: اذا لم تجد الجهاز المطلوب ضمن القائمة اعلاه, رجاءً قم بالربط عن طريق صفحة البلوتوث الموجودة في الإعدادات",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Alexandria",
                                    wordSpacing: 3,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 15),
                                RaisedButton(
                                  elevation: 2,
                                  child: Text(
                                    "إعدادات البلوتوث",
                                    style: TextStyle(
                                      fontFamily: "Alexandria",
                                    ),
                                  ),
                                  onPressed: () {
                                    FlutterBluetoothSerial.instance
                                        .openSettings();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              /// SETTING ICON
              Padding(
                padding: EdgeInsets.fromLTRB(_w / 17, _w / 9.5, _w / 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        // So, that when new devices are paired
                        // while the app is running, user can refresh
                        // the paired devices list.
                        await getPairedDevices().then((_) {
                          show(_scaffoldKey, 'تم تحديث قائمة الأجهزة');
                        });
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
                                Icons.refresh,
                                size: _w / 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(
                                    device: _device, connection: connection)));

                        // Navigator.pop(context);
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
                                Icons.arrow_forward,
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
            ],
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text(''),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show(_scaffoldKey, 'لم يتم اختيار أي جهاز');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('متصل بالجهاز');
          connection = _connection;
          setState(() {
            _connected = true;
            CacheData.setData(key: 'bluetooth_connection', value: connection);
            CacheData.setData(key: 'bluetooth_isConnected', value: isConnected);
            CacheData.setData(key: 'bluetooth_name', value: _device.name);

            CacheData.setData(key: 'bluetooth_address', value: _device.address);
            print(_device.address);
          });

          connection.input.listen(_onDataReceived).onDone(() {
            if (isDisconnecting) {
              print('قطع الاتصال محليا!');
            } else {
              print('قطع الاتصال عن بعد!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('لا يمكن الاتصال ، حدث خطأ');
          print(error.toString());
          CacheData.setData(key: 'bluetooth_name', value: _device.name);

          CacheData.setData(key: 'bluetooth_address', value: _device.address);
          show(_scaffoldKey, 'لا يمكن الاتصال ، حدث خطأ');
        });

        setState(() => _isButtonUnavailable = false);
      } else {
        show(_scaffoldKey, 'الجهاز متصل');
      }
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    //   // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
          print(data.toString());
        }
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show(_scaffoldKey, 'الجهاز غير متصل');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("a" + "\r\n"));
    await connection.output.allSent;
    show(_scaffoldKey, 'تم تشغيل الجهاز');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("a" + "\r\n"));
    await connection.output.allSent;
    show(_scaffoldKey, 'الجهاز متوقف');
    setState(() {
      _deviceState = -1; // device off
    });
  }
}
