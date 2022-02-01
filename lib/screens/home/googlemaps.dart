import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/booking_screens/destinationbottom.dart';
import 'package:transport/providers/location_provider.dart';
import 'package:transport/booking_screens/confirmride.dart';
import 'package:transport/screens/home/location_pickup.dart';
import 'package:transport/screens/home/packersnmovers.dart';
import 'package:transport/screens/home/packersucess.dart';
import 'package:transport/screens/home/rentalandmovers.dart';
import 'package:transport/screens/widget/CustomDropDown.dart';
import 'package:transport/screens/widget/CustomElevatedButton.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/screens/widget/customColor.dart';
import 'package:transport/screens/widget/no_services.dart';
import 'package:transport/screens/widget/packersWidget.dart';
import 'package:transport/screens/widget/rentalsWidget.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:location/location.dart';

class GoogleMaps extends StatefulWidget {
  static const String id = 'googlemap';
  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  LatLng currentLocation;
  var vehicleData;
  GoogleMapController _mapController;
  String _pickUp;
  Coordinates _pickCoord;
  Coordinates _dropCoord;
  Coordinates _dropCoord2;
  bool addContainer = false;
  String _dropOff;
  bool _progressVisible = false;
  bool _color;
  int _selectedRide = 0;
  var format = DateFormat.yMd().add_jm();
  DateTime selectedDate = DateTime.now();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime rentalDate = DateTime.now();
  List _workingCities = [];
  String addressString = '';

  Future<DateTime> selectDate(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(seconds: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
  }

  enableLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  _checkWorking() async {
    try {
      var response = await http.get(workingCitiesUrl);
      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        bool exist = false;

        if (data['status'] == 200) {
          for (var item in data['data']) {
            if (addressString.contains(item['city'])) {
              exist = true;
              break;
            }
          }
        }

        if (!addressString.contains('Please') && !exist) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NoServicesScreen(),
              ),
              (route) => false);
          return;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    enableLocation();
    super.initState();
    _color = true;
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

    Widget RideWidget(
      String title,
      String subtitle,
      String price,
      int index,
      Function bottomState, {
      bool isSelected = false,
    }) {
      Color bgColor = Colors.white;
      Image asset = Image.asset(
        'assets/maps/long-truck.png',
        height: 30,
      );

      return Container(
        width: 200,
        color: Colors.white,
        child: ListTile(
          hoverColor: Colors.black,
          leading: asset,
          title: Text(
            title,
            style: TextStyle(
              color: _selectedRide == index ? primaryColor : Colors.black,
            ),
          ),
          subtitle: Text(
            subtitle + " drop-off",
            style: TextStyle(
              color: _selectedRide == index ? primaryColor : Colors.black,
            ),
          ),
          trailing: Text(
            "₹ " + price,
            style: TextStyle(
              color: _selectedRide == index ? primaryColor : Colors.black,
            ),
          ),
          onTap: () {
            bottomState(() {
              _selectedRide = index;
            });
          },
        ),
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
            child: Consumer<LocationProvider>(builder: (context, loc, child) {
          addressString = loc.getAddress.toString();
          _checkWorking();
          if (loc.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          var currentLocation = LatLng(loc.latitude, loc.longitude);
          return Stack(
            children: [
              GoogleMap(
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
              ),
              Container(
                margin: EdgeInsets.only(left: width * 0.3, top: height * 0.36),
                height: height * 0.035,
                width: width * 0.4,
                child: InkWell(
                  onTap: () async {
                    var droploc = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                LocationReaderScreen(
                                  title: "Destination Location",
                                )));

                    setState(() {
                      _dropOff = droploc;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: new Text(
                        loc.getAddress.toString(),
                        style: TextStyle(fontSize: 15, color: Colors.black),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                  child: Container(
                      height: height * 0.04,
                      margin: EdgeInsets.only(bottom: height * 0.04),
                      child: Image.asset('assets/maps/source_pin.png'))),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.02,
                    vertical: 15,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: width * 0.01),
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 50,
                                width: width / 1.09,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DestinationBottom()));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        height: height * 0.05,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ),
                                      Text(
                                        'Where is Your Drop?',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.black),
                                      )
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(22))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Row(
                          children: [
                            PackersWidget(width: width),
                            SizedBox(
                              width: width * 0.03,
                            ),
                            RentalsWidget(width: width),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                maintainState: true,
                visible: _progressVisible,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          );
        })));
  }

  Widget buildInputWidget1(
      {String text, String hint, onTap, onMapTap, bool extra}) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 10.0),
      decoration: BoxDecoration(
        color: Color(0xffeeeeee).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                (text.isEmpty) ? "$hint" : "$text",
                maxLines: 1,
                textAlign: TextAlign.justify,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 4.0,
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}
