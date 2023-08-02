import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth/screens/Home/home.dart';
import 'package:flutter_bluetooth/screens/Splash/splash_screen.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:flutter_bluetooth/utils/storage/cacheHelper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheData.cacheInit();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
            locale: Locale('ar'),
            supportedLocales: [
              Locale('ar'),
              Locale('en'),
            ],
            debugShowCheckedModeBanner: false,
            home: MyCustomSplashScreen(),
          );
        }));
  }
}
