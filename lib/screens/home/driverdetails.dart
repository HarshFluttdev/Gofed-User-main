import 'dart:convert';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/providers/location_provider.dart';
import 'package:transport/booking_screens/confirmride.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/screens/widget/customgoodsdropdown.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:transport/validators/validators.dart';

class DriverDetails extends StatefulWidget {
  final truckName, id, pickUpLocation, dropUpLocation, helper;

  const DriverDetails(
      {this.truckName,
      this.id,
      this.pickUpLocation,
      this.dropUpLocation,
      this.helper});
  @override
  _DriverDetailsState createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final _formKey = GlobalKey<FormState>();
  LatLng currentLocation = LatLng(0, 0);
  bool isLoading;
  AnimationController animationController;
  Animation animation;
  GoogleMapController _mapController;
  bool _progressVisible = false;
  String coupon = "GoFed 100";
  String token;
  bool isSwitched = false;
  Set<Marker> markers = {};
  Map<dynamic, dynamic> points = {};
  var loading = false;
  List coupons = [];
  var newpicklng;
  var newpicklat;
  var newdroplng;
  var newdroplat;
  final List goodTypeList = [
    {
      'name': 'Select Goods Types',
      'value': 'NULL',
    }
  ];
  int _goodTypeValue = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor droppinLocationIcon;
  int radioValue = -1;
  bool _value = true;

  void _getPolyline() async {
    List<LatLng> polylineCoordinates = [];
    var pickUpPlacemark =
        await Geolocator().placemarkFromAddress(widget.pickUpLocation);

    var dropUpPlacemark =
        await Geolocator().placemarkFromAddress(widget.dropUpLocation);
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
    setState(() {});
  }

  getGoodType() async {
    try {
      var response = await http.get(goodTypeUrl);
      var data = jsonDecode(response.body);
      for (var item in data['data']) {
        goodTypeList.add({
          'value': item['id'].toString(),
          'name': item['name'].toString(),
        });
      }
      getmarkers();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  getCouponsList() async {
    try {
      var response = await http.get(CouponsListUrl);
      var data = jsonDecode(response.body);
      setState(() {
        coupons = data['data'];
      });
    } catch (e) {
      print(e);
    }
  }

  void pickupMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(5, 5)),
        'assets/maps/source_pin.png');
  }

  void dropMapPin() async {
    droppinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5, size: Size(48, 48)),
        'assets/maps/dest_pin.png');
  }

  getmarkers() async {
    var pickUpPlacemark =
        await Geolocator().placemarkFromAddress(widget.pickUpLocation);
    var dropUpPlacemark =
        await Geolocator().placemarkFromAddress(widget.dropUpLocation);
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
              // title: 'Your Pickup Location',
              // snippet: 'My Custom Subtitle',
              ),
          icon: pinLocationIcon //Icon for Marker
          ));

      Marker destination = (Marker(
        //add second marker
        markerId: MarkerId('destination'),
        position: LatLng(dropUpPlacemark.first.position.latitude,
            dropUpPlacemark.first.position.longitude), //position of marker
        infoWindow: InfoWindow(
            //popup info
            //  title: 'Marker Title Second ',
            //snippet: 'My Custom Subtitle',
            ),
        icon: droppinLocationIcon, //Icon for Marker
      ));
      markers.add(origin);
      markers.add(destination);
      //add more markers here
    });
    _getPolyline();
    return markers;
  }

  void addToDoItemScreen(String mycoupon) {
    Navigator.pop(context);

    setState(() {
      token = mycoupon;
    });
  }

  @override
  void initState() {
    getGoodType();
    getCouponsList();
    pickupMapPin();
    dropMapPin();
    super.initState();
  }

  bookRide() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var purpose = prefs.getString("purpose");
    var pickUpPlacemark = await Geolocator()
        .placemarkFromAddress(widget.pickUpLocation.toString());

    var dropUpPlacemark = await Geolocator()
        .placemarkFromAddress(widget.dropUpLocation.toString());
    double distance = await Geolocator().distanceBetween(
        pickUpPlacemark.first.position.latitude,
        pickUpPlacemark.first.position.longitude,
        dropUpPlacemark.first.position.latitude,
        dropUpPlacemark.first.position.longitude);
    var distance_in_km = (distance ~/ 1000);
    var user = await SharedData().getUser();
    try {
      var response = await http.post(Uri.parse(bookRideUrl), body: {
        'id': user.toString(),
        'vehicle_type': widget.id.toString(),
        'helper': isSwitched.toString() ?? "0",
        'pick_lat': pickUpPlacemark.first.position.latitude.toString(),
        'pick_lng': pickUpPlacemark.first.position.longitude.toString(),
        'pick_location': widget.pickUpLocation.toString(),
        'drop_lat': dropUpPlacemark.first.position.latitude.toString(),
        'drop_lng': dropUpPlacemark.first.position.latitude.toString(),
        'drop_location': widget.dropUpLocation.toString(),
        'distance': distance_in_km.toString(),
        'toll_count': (pickUpPlacemark.first.postalCode ==
                dropUpPlacemark.first.postalCode)
            ? '0'
            : '1',
        'purpose': purpose.toString(),
        'contact_person': nameController.text.toString(),
        'contact_number': mobileController.text,
        'good_type': goodTypeList[_goodTypeValue]['id'].toString(),
        'coupon_id': token ?? "0",
      });
      print(response.body);
      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 200) {
          print(data);
          CustomMessage.toast(data['message']);
          prefs.remove("pickUpLocation");
          prefs.remove("dropUpLocation");
          prefs.remove("pickLat");
          prefs.remove("pickLng");
          prefs.setString("pickUpLocation", widget.pickUpLocation.toString());
          prefs.setString("dropUpLocation", widget.dropUpLocation.toString());
          prefs.setString(
              "pickLat", pickUpPlacemark.first.position.latitude.toString());
          prefs.setString(
              "pickLng", pickUpPlacemark.first.position.longitude.toString());
          prefs.setString("truck", widget.truckName);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmRide(
                  id: widget.id,
                  dropUpLocation: widget.dropUpLocation,
                  pickUpLocation: widget.pickUpLocation,
                  truckName: widget.truckName,
                ),
              ),
              (route) => false);
        } else {
          // CustomMessage.toast(data['message']);
        }
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
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

    return Scaffold(body: SafeArea(
      child: Consumer<LocationProvider>(builder: (context, loc, child) {
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
                // loc.getMoveCamera();
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.46),
              height: height * 0.55,
              width: double.infinity,
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 3.0, spreadRadius: 0.05)],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      (isSwitched)
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                width: width,
                                decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Your fare has been updated from 904 to 1504",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: height * 0.02,
                            ),
                      Container(
                        margin: EdgeInsets.only(left: width * 0.02),
                        child: Text(
                          'Driver will call this contact at Delivery',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: height * 0.01,
                          left: 10,
                          right: 10,
                        ),
                        padding: EdgeInsets.only(
                          left: 15.0,
                          right: 10.0,
                          bottom: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
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
                                validator: (value) => validateMobile(value),
                                keyboardType: TextInputType.number,
                                controller: mobileController,
                                maxLines: 1,
                                textAlign: TextAlign.justify,
                                maxLength: 10,
                                decoration: InputDecoration(
                                  hintText: 'Mobile Number',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: height * 0.01,
                          left: 10,
                          right: 10,
                        ),
                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
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
                                validator: (value) => validateNames(value),
                                controller: nameController,
                                maxLines: 1,
                                textAlign: TextAlign.justify,
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: height * 0.01,
                          left: 10,
                          right: 10,
                        ),
                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
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
                        child: CustomGoodsDropDown(
                          context: context,
                          func: (value) {
                            setState(() {
                              _goodTypeValue = value;
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            });
                          },
                          items: goodTypeList,
                          value: _goodTypeValue,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(left: width * 0.04),
                                  child: Text(
                                    widget.helper != 1
                                        ? 'Include Helper'
                                        : 'No Helper',
                                    style: TextStyle(color: Color(0xff454545)),
                                  )),
                              Switch(
                                value: isSwitched,
                                onChanged: (bool value) {
                                  setState(() {
                                    isSwitched = value;
                                  });
                                  if (value) {
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            // vertical: height * 0.26,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            'Required Helper !!!',
                                            style: TextStyle(
                                              color: Color(0xff424242),
                                              fontSize: 16,
                                              height: 1.68,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                          height:
                                                              height * 0.03),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Checkbox(
                                                                  value: _value,
                                                                  onChanged: (bool
                                                                      newvalue) {
                                                                    setState(
                                                                        () {
                                                                      _value =
                                                                          newvalue;
                                                                    });
                                                                  },
                                                                ),
                                                                Text(
                                                                  'I agree to the terms of service and privacy policy',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets.only(
                                                                    top: height *
                                                                        0.04,
                                                                    right: width *
                                                                        0.05),
                                                                height: height *
                                                                    0.04,
                                                                width:
                                                                    width * 0.4,
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xff6B5ECD),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            30)),
                                                                child: Center(
                                                                    child: Text(
                                                                  'Submit',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                )),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: height *
                                                                  0.02),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {}
                                },
                                activeTrackColor: Color(0xffE7E7E7),
                                activeColor: Color(0xff706BF7),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.only(
                          top: height * 0.01,
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: Color(0xff63C916),
                              size: 30,
                            ),
                            SizedBox(
                              width: width * 0.03,
                            ),
                            InkWell(
                              onTap: () {
                                showFlexibleBottomSheet(
                                  minHeight: 0,
                                  initHeight: 1,
                                  maxHeight: 1,
                                  context: context,
                                  builder: (context, scrollController,
                                      bottomSheetOffset) {
                                    return StatefulBuilder(
                                      builder: (context, bottomState) {
                                        return _buildBottomSheet(
                                            context,
                                            scrollController,
                                            bottomSheetOffset,
                                            bottomState);
                                      },
                                    );
                                  },
                                  anchors: [0, 0.5, 1],
                                );
                              },
                              child: Text(
                                'Apply Coupon',
                                style: TextStyle(color: Color(0xff454545)),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        padding: EdgeInsets.only(left: 15.0, right: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
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
                              child: TextField(
                                maxLines: 1,
                                textAlign: TextAlign.justify,
                                decoration: InputDecoration(
                                  hintText: token ?? 'Add Coupon',
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                showFlexibleBottomSheet(
                                  minHeight: 0,
                                  initHeight: 0.4,
                                  maxHeight: 1,
                                  context: context,
                                  builder: (context, scrollController,
                                      bottomSheetOffset) {
                                    return StatefulBuilder(
                                      builder: (context, bottomState) {
                                        return _buildPaymentBottomSheet(
                                            context,
                                            scrollController,
                                            bottomSheetOffset,
                                            bottomState);
                                      },
                                    );
                                  },
                                  // builder: _buildPaymentBottomSheet,
                                  anchors: [0, 0.5, 1],
                                );
                              },
                              child: Container(
                                  height: height * 0.06,
                                  width: width * 0.3,
                                  margin: EdgeInsets.only(top: height * 0.01),
                                  padding:
                                      EdgeInsets.only(left: 15.0, right: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          height: 20,
                                          child: Image.asset(
                                            'assets/maps/cash.png',
                                          )),
                                      Text('Cash'),
                                      Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 10,
                                        color: Colors.black,
                                      ),
                                    ],
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: height * 0.01),
                              height: height * 0.07,
                              width: width * 0.56,
                              child: RaisedButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    bookRide();
                                  }
                                },
                                color: Color(0xff706BF7),
                                child: (loading)
                                    ? Center(
                                        child: Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      ))
                                    : Text(
                                        'Book Now',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    ));
  }

  Widget _buildBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
    Function bottomState,
  ) {
    return SafeArea(
      child: Material(
        child: Stack(children: [
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Icon(Icons.arrow_back)),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Coupons & Offers',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      height: 40,
                      width: 250,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Coupons',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green),
                      child: Center(
                          child: Text(
                        'APPLY',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  height: 400,
                  child: ListView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            addToDoItemScreen(coupons[index]['code']);
                          },
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              height: 95,
                              width: 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Coupon',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        coupons[index]['name'],
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Amount',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        coupons[index]['amount'],
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        coupons[index]['code'],
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'Quantity',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        coupons[index]['quantity'],
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildPaymentBottomSheet(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
    Function bottomState,
  ) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: SafeArea(
        child: Material(
          child: Stack(children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: 30),
                          child: Text(
                            'Select Payment',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )),
                    ],
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Icon(Icons.money)),
                        Container(
                            margin: EdgeInsets.only(left: 45),
                            child: Text(
                              'Cash',
                              style: TextStyle(fontSize: 20),
                            )),
                      ],
                    ),
                    trailing: Radio(
                      value: 0,
                      groupValue: radioValue,
                      onChanged: (value) {
                        bottomState(() {
                          radioValue = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 20),
                            child: Image.asset('assets/maps/razorpay.png')),
                        Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Text(
                              'Razor Pay',
                              style: TextStyle(fontSize: 20),
                            )),
                      ],
                    ),
                    trailing: Radio(
                      value: 1,
                      groupValue: radioValue,
                      onChanged: (value) {
                        bottomState(() {
                          radioValue = value;
                        });
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff706BF7),
                      ),
                      child: Center(
                          child: Text(
                        'Proceed',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget Pin({height1, height2}) {
    return Center(
        child: Container(
            height: height1,
            margin: EdgeInsets.only(bottom: height2),
            child: Image.asset('assets/maps/source_pin.png')));
  }

  Widget Pin2({height1, height2}) {
    return Center(
        child: Container(
            height: height1,
            margin: EdgeInsets.only(bottom: height2),
            child: Image.asset('assets/maps/dest_pin.png')));
  }
}
