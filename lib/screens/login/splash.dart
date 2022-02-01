import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transport/screens/home/homescreen.dart';
import 'package:transport/screens/login/login.dart';
import 'package:transport/services/shared.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  _data() async {
    try {
      await Firebase.initializeApp();
      Timer(
          Duration(seconds: 3),
          (await SharedData().userLogged())
              ? () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()))
              : () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen())));
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment(-1.0, -2.0),
            end: Alignment(1.0, 2.0),
            colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
      ),
      child: Center(
          child: Image.asset(
        'assets/maps/splash.png',
        height: 150,
      )),
    ));
  }
}
