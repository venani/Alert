
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mindfulAlert/levelhistory.dart';
import 'package:mindfulAlert/main.dart';
import 'startapp.dart';
import 'commondialogs.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 100), () =>  Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    String title = "Welcome to the Alertness Excercisor";
    String info =  "This text is very very very very very very very very very very very very very M "
        "very very very very very very very very very very very long";
    return CommonDialogs.popupDialog(context, title, info);
  }
}
