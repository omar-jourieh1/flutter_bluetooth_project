import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:flutter_bluetooth/utils/storage/cacheHelper.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class Settings extends StatefulWidget {
  const Settings({Key key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = provider.isDarkMode ?? false;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          body: Padding(
        padding: EdgeInsets.fromLTRB(_w / 20, _w / 20, _w / 20, _w / 10),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _w / 15,
                  ),
                  Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontSize: 35,
                      fontFamily: "Alexandria",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: _w / 50),
                  Text(
                    'الإعدادات العامة',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: "Alexandria",
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              InkWell(
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
                          Icons.arrow_forward,
                          size: _w / 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            // Divider(
            //   height: 5,
            //   color: Colors.grey,
            // ),
            SizedBox(
              height: _w / 15,
            ),
            Row(
              children: [
                Text(
                  'الوضع المظلم',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Alexandria",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Checkbox(
                  onChanged: (value) async {
                    setState(() {
                      isDark = value;
                      provider.toggleTheme(value);
                    });
                    await CacheData.setData(key: 'isDark', value: isDark);
                  },
                  value: isDark,
                )
              ],
            ),
            SizedBox(
              height: _w / 15,
            ),
            Row(
              children: [
                Text(
                  'ربط البلوتوث',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Alexandria",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    child: Icon(Icons.bluetooth))
              ],
            )
          ],
        ),
      )),
    );
  }
}
