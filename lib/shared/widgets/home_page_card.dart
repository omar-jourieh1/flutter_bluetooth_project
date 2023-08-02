import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth/shared/theme/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

Widget homePageCard(
    Animation _animation,
    Animation _animation2,
    Color color,
    IconData icon,
    String title,
    BuildContext context,
    Widget route,
    bool isAvailable) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  bool isDark = themeProvider.isDarkMode ?? false;
  double _w = MediaQuery.of(context).size.width;
  return Opacity(
    opacity: _animation.value,
    child: Transform.translate(
      offset: Offset(0, _animation2.value),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return route;
              },
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              height: _w / 2,
              width: _w / 2.4,
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Color(0xfffffff).withOpacity(.1)
                        : Color(0xff040039).withOpacity(.15),
                    blurRadius: 99,
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(),
                  Container(
                    height: _w / 8,
                    width: _w / 8,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(
                        icon,
                        color: color.withOpacity(.6),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 4,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      // color: Colors.black.withOpacity(.5),
                      fontFamily: "Alexandria",
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(),
                ],
              ),
            ),
            isAvailable || title != "GPS"
                ? SizedBox()
                : Banner(
                    message: 'قريباً',
                    location: BannerLocation.topStart,
                    textStyle:
                        TextStyle(fontFamily: 'Alexandria', fontSize: 12),
                  )
          ],
        ),
      ),
    ),
  );
}
