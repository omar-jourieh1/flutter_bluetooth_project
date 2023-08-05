import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/screens/Readings/data_reading_page.dart';
import 'package:flutter_bluetooth/screens/Splash/splash_screen.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import 'screens/Bluetooh/connection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: Builder(builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MaterialApp(
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            debugShowCheckedModeBanner: false,
            locale: Locale('ar'),
            home: FutureBuilder(
              future: FlutterBluetoothSerial.instance.requestEnable(),
              builder: (context, future) {
                if (future.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Container(
                      height: double.infinity,
                      child: Center(
                        child: Icon(
                          Icons.bluetooth_disabled,
                          size: 200.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                } else if (future.connectionState == ConnectionState.done) {
                  // return MyHomePage(title: 'Flutter Demo Home Page');
                  return MyCustomSplashScreen();
                } else {
                  return Home();
                }
              },
              // child: MyHomePage(title: 'Flutter Demo Home Page'),
            ),
          );
        }));
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Connection'),
      ),
      body: SelectBondedDevicePage(
        onCahtPage: (device1) {
          BluetoothDevice device = device1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return DataReadingPage(device: device);
              },
            ),
          );
        },
      ),
    ));
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _currentStep = 0;
//   BluetoothDevice device;
//
//   void onStepContinue() async {
//     if (_currentStep == 0) {
//       setState(() {
//         _currentStep = 1;
//       });
//     }
//   }
//
//   void onStepCancel() {
//     if (_currentStep == 1) {
//       setState(() {
//         _currentStep = 0;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Step> _steps = [
//       Step(
//         title: Text('Connection'),
//         content: Container(
//           height: 500,
//           child: SelectBondedDevicePage(
//             onCahtPage: (BluetoothDevice device) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return ChatPage(server: device);
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//         state: StepState.editing,
//         isActive: true,
//       ),
//       Step(
//         title: Text('Led'),
//         content: Container(
//             // child: onCahtPage,
//             ),
//       ),
//     ];
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Stepper(
//         steps: _steps,
//         type: StepperType.horizontal,
//         currentStep: _currentStep,
//         onStepContinue: onStepContinue,
//         onStepCancel: onStepCancel,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           //
//         },
//         tooltip: 'Increment',
//         child: Icon(Icons.search),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
