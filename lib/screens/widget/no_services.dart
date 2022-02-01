import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transport/screens/home/homescreen.dart';
import 'package:transport/screens/login/login.dart';
import 'package:transport/services/shared.dart';

class NoServicesScreen extends StatefulWidget {
  @override
  _NoServicesScreenState createState() => _NoServicesScreenState();
}

class _NoServicesScreenState extends State<NoServicesScreen> {
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
      child: Container(
        margin: EdgeInsets.only(top: 250),
        alignment: Alignment.center,
        child: Column(
          children: [
            Image.asset(
              'assets/maps/splash.png',
              height: 150,
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Text(
                  'We will provide services in your city soon!! So stay tuned..!!',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    ));
  }
}
