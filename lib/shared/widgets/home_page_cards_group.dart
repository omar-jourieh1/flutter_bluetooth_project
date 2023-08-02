import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/shared/widgets/home_page_card.dart';

Widget homePageCardsGroup(
    Animation _animation,
    Animation _animation2,
    Color color,
    IconData icon,
    String title,
    BuildContext context,
    Widget route,
    Color color2,
    IconData icon2,
    String title2,
    Widget route2,
    bool isAvailable) {
  double _w = MediaQuery.of(context).size.width;
  return Padding(
    padding: EdgeInsets.only(bottom: _w / 17),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        homePageCard(_animation, _animation2, color, icon, title, context,
            route, isAvailable),
        homePageCard(_animation, _animation2, color2, icon2, title2, context,
            route2, isAvailable),
      ],
    ),
  );
}
