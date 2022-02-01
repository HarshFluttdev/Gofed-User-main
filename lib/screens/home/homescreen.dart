import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/controller/notification_controller.dart';
import 'package:transport/screens/account/accountscreen.dart';
import 'package:transport/booking_screens/confirmride.dart';
import 'package:transport/screens/home/googlemaps.dart';
import 'package:transport/screens/orders/ordersscreen.dart';
import 'package:transport/screens/payment/paymentscreen.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng currentLocation;
  final PageController _pageController = PageController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var statusLoading = false;
  var loading = false;
  bool _progressVisible = false;
  var _selectedTab = 0;
  void _handleIndexChanged(int i) {
    _pageController.animateToPage(i,
        duration: Duration(microseconds: 200), curve: Curves.elasticInOut);
    setState(() {
      _selectedTab = i;
    });
  }

  static const MethodChannel _channel = MethodChannel('flutter_not');
  Map<String, String> channelMap = {
    "id": "Ride",
    "name": "Ride name",
    "description": "Ride notifications",
  };

  var rideId = '' ?? 0;
  anyRideActive() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("rideId", rideId);
      var response = await http.post(Uri.parse(anyRideActiveURL), body: {
        'id': user.toString(),
      });
      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        setState(() {
          return rideId = data['data'][0]['id'].toString();
        });
        print('myride $rideId');
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  var ridestatus = '' ?? 0;
  Future RideStatus() async {
    setState(() {
      _progressVisible = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pending = prefs.getString('pending');
    if (pending == 'Pending') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ConfirmRide()));
    } else if (pending == 'Accepted') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ConfirmRide()));
    } else if (pending == 'Ongoing') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ConfirmRide()));
    } else {}
    setState(() {
      _progressVisible = false;
    });
  }

  updateFcmToken(var token) async {
    setState(() {
      loading = true;
    });
    var user = await SharedData().getUser();
    await NotificationController(context);
    try {
      var response = await http.post(Uri.parse(updateTokenUrl), body: {
        'id': user.toString(),
        'token': token.toString(),
      });

      if (response.statusCode != 200) {
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  getToken() {
    _firebaseMessaging.getToken().then((token) {
      updateFcmToken(token);
    });
  }

  firebaseTrigger() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
      await NotificationController(context);
    } catch (e) {
      CustomMessage.toast("Error");
    }
  }

  @override
  void initState() {
    RideStatus();
    firebaseTrigger();
    anyRideActive();
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    List<Widget> _pages = [
      GoogleMaps(),
      OrdersScreen(),
      PaymentScreen(),
      AccountScreen(),
    ];
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: height * 0.08,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: BottomNavigationBar(
              elevation: 5,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/maps/house.png')),
                    label: "Home"),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/maps/wall-clock.png')),
                    label: "Order"),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/maps/payment.png')),
                    label: "Payment"),
                BottomNavigationBarItem(
                    icon: ImageIcon(AssetImage('assets/maps/user.png')),
                    label: "Account"),
              ],
              currentIndex: _selectedTab,
              iconSize: 25,
              onTap: (i) => _handleIndexChanged(i),
            ),
          ),
        ),
      ),
    );
  }
}
