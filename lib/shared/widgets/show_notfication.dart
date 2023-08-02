// Method to show a Snackbar,
// taking message as the text
import 'package:flutter/material.dart';

Future show(
  GlobalKey<ScaffoldState> _scaffoldKey,
  String message, {
  Duration duration: const Duration(seconds: 3),
}) async {
  await new Future.delayed(new Duration(milliseconds: 100));
  _scaffoldKey.currentState.showSnackBar(
    new SnackBar(
      content: new Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Alexandria'),
      ),
      duration: duration,
    ),
  );
}
