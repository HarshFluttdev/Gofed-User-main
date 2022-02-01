import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:transport/providers/location_provider.dart';
import 'package:transport/screens/home/googlemaps.dart';
import 'package:transport/screens/home/packersucess.dart';
import 'package:transport/screens/home/ride_cancel.dart';
import 'package:transport/screens/login/login.dart';
import 'package:transport/screens/login/register.dart';
import 'package:transport/screens/login/splash.dart';
import 'package:transport/services/enabledprovider.dart';
import 'screens/login/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  HttpOverrides.global = MyHttpOverrides();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => LocationProvider(),
      ),
      ChangeNotifierProvider(create: (_) => EnabledProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/register': (context) => RegisterScreen(),
        '/googlemap': (context) => GoogleMaps(),
        '/packersuccess': (context) => PackerSuccess(),
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..connectionTimeout = Duration(seconds: 20)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
