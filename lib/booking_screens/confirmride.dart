import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/providers/location_provider.dart';
import 'package:transport/screens/home/PushNotificationService.dart';
import 'package:transport/screens/home/homescreen.dart';
import 'package:transport/screens/home/packersucess.dart';
import 'package:transport/screens/home/ride_cancel.dart';
import 'package:transport/screens/widget/CustomDropDown.dart';
import 'package:transport/screens/widget/CustomElevatedButton.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/services/shared.dart';
import 'package:http/http.dart' as http;
import 'package:transport/url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart';

class ConfirmRide extends StatefulWidget {
  final truckName, id, pickUpLocation, dropUpLocation;

  const ConfirmRide(
      {this.truckName, this.id, this.pickUpLocation, this.dropUpLocation});

  @override
  _ConfirmRideState createState() => _ConfirmRideState();
}

class _ConfirmRideState extends State<ConfirmRide> {
  LatLng currentLocation;
  bool isLoading = false;
  AnimationController animationController;
  Animation animation;
  GoogleMapController _mapController;
  bool _progressVisible = false;
  String _pickUp;
  String _dropOff;
  bool isSwitched = false;
  var percent = 0.0;
  Marker origin;
  Marker destination;
  var loading = false;
  var truckName = '';
  TextEditingController review = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  final Set<Marker> markers = new Set();
  Timer timer;
  double driverrating;
  final _formKey = GlobalKey<FormState>();

  void _getPolyline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pickup = prefs.getString("pickUpLocation");
    var dropoff = prefs.getString("dropUpLocation");
    truckName = await prefs.getString('truck');

    List<LatLng> polylineCoordinates = [];
    var pickUpPlacemark = await Geolocator().placemarkFromAddress(pickup);
    var dropUpPlacemark = await Geolocator().placemarkFromAddress(dropoff);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDJki66xdJ8dZy72cs0XoGqhCA0LNTfsdo",
      PointLatLng(
        pickUpPlacemark.first.position.latitude,
        pickUpPlacemark.first.position.longitude,
      ),
      PointLatLng(dropUpPlacemark.first.position.latitude,
          dropUpPlacemark.first.position.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Color(0xff706BF7),
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  getmarkers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pickup = prefs.getString("pickUpLocation");
    var dropoff = prefs.getString("dropUpLocation");
    var pickUpPlacemark = await Geolocator().placemarkFromAddress(pickup);
    var dropUpPlacemark = await Geolocator().placemarkFromAddress(dropoff);
    //markers to place on map

    Position pos = await Geolocator().getCurrentPosition();
    currentLocation = LatLng(pos.latitude, pos.longitude);

    setState(() {
      Marker origin = (Marker(
        markerId: MarkerId('origin'),
        position: LatLng(pickUpPlacemark.first.position.latitude,
            pickUpPlacemark.first.position.longitude), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title First ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      Marker destination = (Marker(
        //add second marker
        markerId: MarkerId('destination'),
        position: LatLng(dropUpPlacemark.first.position.latitude,
            dropUpPlacemark.first.position.longitude), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Marker Title Second ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      markers.add(origin);
      markers.add(destination);
      //add more markers here
    });
    _getPolyline();
    return markers;
  }

  var rideId = '';
  anyRideActive() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();

      var response = await http.post(Uri.parse(anyRideActiveURL), body: {
        'id': user.toString(),
      });
      if (response.statusCode != 200) {
        print('yor Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        setState(() {
          return rideId = data['data'][0]['id'].toString();
        });
        if (data['status'] == 200) {
          // CustomMessage.toast(data['message']);
        } else {
          // CustomMessage.toast(data['message']);
        }
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  var ridestatus = '',
      vehicleno = '',
      drivername = '',
      driverno = '',
      driverid = '',
      totalamount = '',
      pickup = '',
      dropoff = '',
      distance = '';
  RideStatus() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var response = await http.post(Uri.parse(RideStatusURL), body: {
        'id': user.toString(),
        'ride': rideId.toString(),
      });
      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        if (data['status'] == 200) {
          setState(() {
            ridestatus = data['data'][0]['ride_status'].toString();
            vehicleno = data['data'][0]['vehicle_no'].toString();
            drivername = data['data'][0]['partner_name'].toString();
            driverno = data['data'][0]['partner_mobile'].toString();
            totalamount = data['data'][0]['total_amount'].toString();
            pickup = data['data'][0]['pick_location'].toString();
            dropoff = data['data'][0]['drop_location'].toString();
            distance = data['data'][0]['distance'].toString();
            driverid = data['data'][0]['driver_id'].toString();
          });
          prefs.setString("pending", ridestatus);
        } else {}
      } else {}

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  cancelRide({BuildContext context, bool time = false}) async {
    var user = await SharedData().getUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List cancelReasons = [];
    int _selectedReason = 0;

    if (!time) {
      setState(() {
        _progressVisible = true;
      });
      var response = await http.get(cancelReasonsURL);
      setState(() {
        _progressVisible = false;
      });

      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        for (var item in data['data']) {
          cancelReasons.add({
            'name': item['name'],
            'value': item['id'],
          });
        }
      }

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(
                'Cancel Reason',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDropDown(
                    context: context,
                    value: _selectedReason,
                    items: cancelReasons,
                    func: (value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      context: context,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    setState(() {
      _progressVisible = true;
    });
    var response = await http.post(Uri.parse(cancelRideURL), body: {
      'id': user.toString(),
      'ride': rideId.toString(),
      'reason': cancelReasons.isEmpty
          ? '1'
          : cancelReasons[_selectedReason]['value'].toString(),
    });
    setState(() {
      _progressVisible = false;
    });
    var data = jsonDecode(response.body);
    if (data['status'] == 200) {
      prefs.remove("pending");
      prefs.remove("pickUpLocation");
      prefs.remove("dropUpLocation");
      prefs.remove("pickLat");
      prefs.remove("pickLng");
      Navigator.pushAndRemoveUntil(
        this.context,
        MaterialPageRoute(
          builder: (context) => time ? RideCancelScreen() : HomeScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  String validateString(String value) {
    if (value.length <= 2) {
      return 'This field is required.';
    }
    return null;
  }

  reviews() async {
    var user = await SharedData().getUser();
    var response = await http.post(Uri.parse(cancelRideURL), body: {
      'from_id': user.toString(),
      'to_id': driverid.toString(),
      'rating': driverrating,
      'review': review.text,
      'type': 'driver'
    });
    var data = jsonDecode(response.body);
    if (data['status'] == 200) {
      // CustomMessage.toast(data['message']);
    } else {}
  }

  PaymentTransaction() async {
    var user = await SharedData().getUser();
    var response = await http.post(Uri.parse(paymentURL), body: {
      'id': user.toString(),
      'ride': rideId.toString(),
      'amount': totalamount,
      'payment_method': '1',
      'pay_status': '1'
    });
    var data = jsonDecode(response.body);
    if (data['status'] == 200) {
      // CustomMessage.toast(data['message']);
    } else {}
  }

  bool isApiCallInprogress = false;
  var userId, phoneNo;
  Razorpay pay;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    CustomMessage.toast("Payment Success");
    if (response != null) {
      // PaymentTransaction();
      // Navigator.push(this.context, MaterialPageRoute(builder: (context) {
      //   return PackerSuccess();
      // }));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomMessage.toast("Payment failed");
    if (response != null) {
      //  PaymentTransaction();
      // Navigator.push(this.context, MaterialPageRoute(builder: (context) {
      //   return PackerSuccess();
      // }));
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(
        'You have chosen to pay via : ${response.walletName}. It will take some time to reflect your payment.');
  }

  void openCheckOut(var cost) {
    var options = {
      "key": "rzp_test_Fi1BvOwJJZomaI",
      "amount": totalamount,
      "name": "GoFed Transport",
      "description": "Payment for booking ride",
      "prefill": {
        "contact": phoneNo,
        "email": "",
      },
    };

    try {
      pay.open(options);
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _getPolyline();
    getmarkers();
    anyRideActive();
    Future.delayed(Duration(minutes: 10), () {
      CustomMessage.toast('No driver found for your ride..!!');
      cancelRide(time: true);
    });
    pay = Razorpay();
    pay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    pay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    pay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    final User user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user.toString();
      phoneNo = user.phoneNumber;
    });
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => RideStatus());
    Timer.periodic(
        Duration(seconds: 1), (Timer t) => ProgreddIndicatorPercentage());
  }

  ProgreddIndicatorPercentage() {
    if (percent < 0.9) {
      setState(() {
        percent = percent + 0.1;
      });
    }
  }

  @override
  void dispose() {
    cancelRide();
    pay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
        bottomSheet: (ridestatus == 'Pending')
            ? Container(
                height: height * 0.4,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: height * 0.02),
                      child: Text(
                        'We are Looking For a Driver !!!',
                        style: TextStyle(
                            color: Color(0xff565557),
                            fontWeight: FontWeight.w600,
                            fontSize: 21),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: new LinearPercentIndicator(
                        width: width * 0.85,
                        lineHeight: 10.0,
                        percent: percent,
                        progressColor: Colors.green,
                      ),
                    ),
                    Image.asset(
                      "assets/maps/face.jpg",
                      scale: 6.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: height * 0.01),
                      height: height * 0.06,
                      width: width * 0.9,
                      child: RaisedButton(
                        onPressed: () {
                          cancelRide(context: context);
                        },
                        color: Color(0xff706BF7),
                        child: Text(
                          'Cancel Ride',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : (ridestatus == 'Accepted')
                ? Container(
                    height: height * 0.25,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                top: height * 0.02, left: width * 0.05),
                            child: Text(
                              'Driver Is On The Way !!!',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 20),
                            )),
                        Container(
                          margin: EdgeInsets.only(
                              top: height * 0.04, left: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/maps/truck4.png',
                                    color: Color(0xff706BF7),
                                    height: height * 0.04,
                                  ),
                                  SizedBox(width: 30),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.truckName ?? truckName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color(0xff565557),
                                        ),
                                      ),
                                      Text(
                                        '$vehicleno',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: Color(0xff565557),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${drivername}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Color(0xff565557),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  InkWell(
                                      onTap: () async {
                                        final url = "tel:$driverno";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Icon(
                                        Icons.phone,
                                        color: Color(0xff706BF7),
                                      ))
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          height: height * 0.06,
                          width: double.infinity,
                          child: RaisedButton(
                            onPressed: () {
                              cancelRide();
                            },
                            color: Color(0xff706BF7),
                            child: Text(
                              'Cancel Ride',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : (ridestatus == 'Ongoing')
                    ? Container(
                        height: height * 0.25,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    top: height * 0.02, left: width * 0.05),
                                child: Text(
                                  'Your Ride is OnGoing !!!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                )),
                            Container(
                              margin: EdgeInsets.only(
                                  top: height * 0.04, left: width * 0.05),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/maps/truck4.png',
                                        color: Color(0xff706BF7),
                                        height: height * 0.04,
                                      ),
                                      SizedBox(width: 30),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${widget.truckName ?? truckName}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Color(0xff565557),
                                            ),
                                          ),
                                          Text(
                                            '$vehicleno',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: Color(0xff565557),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${drivername}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Color(0xff565557),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      InkWell(
                                          onTap: () async {
                                            final url = "tel:$driverno";
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          child: Icon(
                                            Icons.phone,
                                            color: Color(0xff706BF7),
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              height: height * 0.06,
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {},
                                color: Color(0xff706BF7),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Pay Amount',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        'Rs. ${totalamount}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (ridestatus == 'Completed')
                        ? Container(
                            height: height * 0.6,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: height * 0.04,
                                          left: width * 0.05),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/maps/truck4.png',
                                            color: Color(0xff706BF7),
                                            height: height * 0.04,
                                          ),
                                          SizedBox(
                                            width: width * 0.1,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${widget.truckName}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              Text(
                                                '$vehicleno',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: width * 0.15,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${drivername}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              Text(
                                                '${driverno}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: width * 0.05,
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                final url = "tel:$driverno";
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              child: Icon(
                                                Icons.phone,
                                                color: Color(0xff706BF7),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: height * 0.04,
                                          left: width * 0.05),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Pick Up :- ${pickup.substring(0, 30)}...'
                                                    .toString(),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              SizedBox(height: height * 0.02),
                                              Text(
                                                'Drop Off :- ${dropoff.substring(0, 30)}...'
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              SizedBox(height: height * 0.02),
                                              Text(
                                                'Total Distance :- ${distance}'
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              SizedBox(height: height * 0.02),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Amount :- ${totalamount}'
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: Color(0xff565557),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      openCheckOut(totalamount);
                                                    },
                                                    child: Container(
                                                      height: height * 0.04,
                                                      width: width * 0.2,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xff706BF7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Center(
                                                          child: Text(
                                                        'Pay Now',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: height * 0.02),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Text(
                                              'Review & Ratings'.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: Color(0xff565557),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: height * 0.02,
                                          ),
                                          RatingBar.builder(
                                            initialRating: 3,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            itemSize: 30,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              setState(() {
                                                driverrating = rating;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: width * 0.9,
                                      margin:
                                          EdgeInsets.only(top: height * 0.02),
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[350],
                                            offset: const Offset(
                                              0.0,
                                              3.0,
                                            ),
                                            blurRadius: 10.0,
                                            spreadRadius: 2.0,
                                          ), //BoxShadow
                                        ],
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: TextFormField(
                                              validator: (value) =>
                                                  validateString(value),
                                              controller: review,
                                              maxLines: 1,
                                              textAlign: TextAlign.justify,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Please Gives us Reviews',
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      height: height * 0.06,
                                      width: double.infinity,
                                      child: RaisedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            if (review.text == "") {
                                              CustomMessage.toast(
                                                  "Enter review");
                                            }
                                            if (review.text != "") {
                                              reviews();
                                            }

                                            _formKey.currentState.save();
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.remove('pending');
                                            prefs.remove("pickUpLocation");
                                            prefs.remove("dropUpLocation");
                                            prefs.remove("pickLat");
                                            prefs.remove("pickLng");
                                            Navigator.pushAndRemoveUntil(
                                              this.context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeScreen()),
                                              (Route<dynamic> route) => false,
                                            );
                                          }
                                        },
                                        color: Color(0xff706BF7),
                                        child: Text(
                                          'Your Ride Is Completed !!!',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : (ridestatus == 'Cancelled')
                            ? Container(
                                height: height * 0.6,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: height * 0.04,
                                          left: width * 0.05),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/maps/truck4.png',
                                            color: Color(0xff706BF7),
                                            height: height * 0.04,
                                          ),
                                          SizedBox(
                                            width: width * 0.1,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${widget.truckName}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              Text(
                                                '$vehicleno',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: width * 0.15,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '${drivername}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                              Text(
                                                '${driverno}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                  color: Color(0xff565557),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: width * 0.05,
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                final url = "tel:$driverno";
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              child: Icon(
                                                Icons.phone,
                                                color: Color(0xff706BF7),
                                              ))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      height: height * 0.06,
                                      width: double.infinity,
                                      child: RaisedButton(
                                        onPressed: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.remove('pending');
                                          prefs.remove("pickUpLocation");
                                          prefs.remove("dropUpLocation");
                                          prefs.remove("pickLat");
                                          prefs.remove("pickLng");
                                          Navigator.pushAndRemoveUntil(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        color: Color(0xff706BF7),
                                        child: Text(
                                          'Your Ride Is Cancelled!!!',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(child: CircularProgressIndicator()),
        body: SafeArea(
            child: Consumer<LocationProvider>(builder: (context, loc, child) {
          if (loc.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          var currentLocation = LatLng(loc.latitude, loc.longitude);
          return Stack(
            children: [
              GoogleMap(
                markers: markers,
                initialCameraPosition:
                    CameraPosition(target: currentLocation, zoom: 11),
                zoomControlsEnabled: false,
                minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.8),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                mapToolbarEnabled: true,
                onCameraMove: (CameraPosition position) {
                  loc.onCameraMove(position);
                },
                onMapCreated: onCreated,
                onCameraIdle: () {
                  loc.getMoveCamera();
                },
                polylines: Set<Polyline>.of(polylines.values),
              ),
            ],
          );
        })));
  }
}
