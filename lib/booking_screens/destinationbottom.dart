import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as https;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/booking_screens/info_screen.dart';
import 'package:transport/model/google_location.dart';
import 'package:transport/providers/location_provider.dart';
import 'package:transport/providers/vehicle_dataProvider.dart';
import 'package:transport/screens/home/driverdetails.dart';
import 'package:transport/screens/home/location_pickup.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/screens/widget/customColor.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';

class DestinationBottom extends StatefulWidget {
  GoogleLocation location;
  DestinationBottom({this.location});
  @override
  _DestinationBottomState createState() => _DestinationBottomState();
}

class _DestinationBottomState extends State<DestinationBottom>
    with TickerProviderStateMixin<DestinationBottom> {
  LatLng currentLocation;
  var loading = false;
  bool isLoading;
  AnimationController animationController;
  Animation animation;
  GoogleMapController _mapController;
  bool _progressVisible = false;
  String _pickUp;
  bool addContainer = false;
  String _dropOff;
  String _dropOff2;
  int addlocation = 0;
  int _selectedRide = 0;
  var vehicleData;
  int newContainer = 0;
  var newAddress = [];
  List _rentalVehicleType = [];
  var distancedata = '';

  getVehicleData() async {
    final response = await https.get(Uri.parse(vehicleTypeUrl + distancedata));
    if (response.statusCode != 200) {
      CustomMessage.toast('Internal Server Error');
    } else if (response.body != '') {
      var data = jsonDecode(response.body);
      if (data['status'] == 200) {
        setState(() {
          _rentalVehicleType.clear();
          _rentalVehicleType = data['data'];
        });
      } else {
        CustomMessage.toast(data['message']);
      }
    }
  }

  getDistance() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var purpose = prefs.getString("purpose");
    var pickUpPlacemark =
        await Geolocator().placemarkFromAddress(_pickUp.toString());

    var dropUpPlacemark =
        await Geolocator().placemarkFromAddress(_dropOff.toString());
    double distance = await Geolocator().distanceBetween(
        pickUpPlacemark.first.position.latitude,
        pickUpPlacemark.first.position.longitude,
        dropUpPlacemark.first.position.latitude,
        dropUpPlacemark.first.position.longitude);
    var distance_in_km = (distance ~/ 1000);
    setState(() {
      distancedata = distance_in_km.toString();
    });
    setState(() {
      loading = false;
    });
  }

  Widget RideWidget({
    int index,
    var asset,
    String id,
    String name,
    String price,
    String pickup,
    String drop,
    String helper,
    Function bottomState,
  }) {
    return ListTile(
      onTap: () async {
        bottomState(() {
          _selectedRide = index;
        });

        var user = await SharedData().getUser();
      },
      leading: Image.network(
        asset,
        width: 40,
        color: _selectedRide == index ? primaryColor : null,
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: _selectedRide == index ? primaryColor : Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  price,
                  style: TextStyle(
                    color: _selectedRide == index ? primaryColor : Colors.black,
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditions(
                                  data: _rentalVehicleType[index]['terms']
                                      .toString(),
                                  image: _rentalVehicleType[index]['icon']
                                      .toString(),
                                )));
                  },
                  child: Icon(
                    Icons.info,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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

    List images = [
      "assets/maps/truck.png",
      "assets/maps/truck2.png",
      "assets/maps/truck3.png",
      "assets/maps/long-truck.png",
      "assets/maps/long-truck.png",
      "assets/maps/long-truck.png",
      "assets/maps/long-truck.png",
      "assets/maps/long-truck.png",
    ];

    Widget _buildBottomSheet(
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
      Function bottomState,
    ) {
      return SafeArea(
        child: Material(
          child: Stack(children: [
            Column(
              children: [
                Container(
                  height: height * 0.3,
                  child: ListView.builder(
                    itemCount: _rentalVehicleType.length,
                    itemBuilder: (context, index) {
                      return RideWidget(
                        index: index,
                        // asset: images[index],
                        asset: _rentalVehicleType[index]['icon'].toString(),
                        id: _rentalVehicleType[index]['id'].toString(),
                        name: _rentalVehicleType[index]['name'].toString(),
                        price: _rentalVehicleType[index]['price'].toString(),
                        pickup: _pickUp,
                        drop: _dropOff,
                        helper: _rentalVehicleType[index]['helper'].toString(),
                        bottomState: bottomState,
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: height * 0.06,
                  width: width * 0.9,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriverDetails(
                              id: _rentalVehicleType[_selectedRide]['id']
                                  .toString(),
                              truckName: _rentalVehicleType[_selectedRide]
                                      ['name']
                                  .toString(),
                              pickUpLocation: _pickUp,
                              dropUpLocation: _dropOff,
                              helper: _rentalVehicleType[_selectedRide]
                                      ['helper']
                                  .toString(),
                            ),
                          ));
                    },
                    color: Color(0xff706BF7),
                    child: Text(
                      'Go Ahead',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      );
    }

    return Scaffold(
        bottomSheet: Container(
          height: height * 0.08,
          width: double.infinity,
          child: RaisedButton(
            onPressed: () async {
              if (_pickUp == null) {
                CustomMessage.toast("Add Pickup location");
              }
              if (_dropOff == null) {
                CustomMessage.toast("Add DropOff location");
              }
              if (_pickUp != null && _dropOff != null) {
                setState(() {
                  _progressVisible = true;
                });
                await getDistance();
                await getVehicleData();
                setState(() {
                  _progressVisible = false;
                });
                showFlexibleBottomSheet(
                  minHeight: 0,
                  initHeight: 0.4,
                  maxHeight: 1,
                  context: context,
                  builder: (context, scrollController, bottomSheetOffset) {
                    return StatefulBuilder(
                      builder: (context, bottomState) {
                        return _buildBottomSheet(context, scrollController,
                            bottomSheetOffset, bottomState);
                      },
                    );
                  },
                  anchors: [0, 0.5, 1],
                );
              }
            },
            color: Color(0xff706BF7),
            child: Text(
              'Book Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: SafeArea(
            child: Consumer<LocationProvider>(builder: (context, loc, child) {
          if (loc.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (_pickUp == null) {
            _pickUp = loc.getAddress.toString();
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
              Pin(height1: height * 0.04, height2: height * 0.04),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                  // margin: (newContainer)
                  //     ? EdgeInsets.only(top: height * 0.50)
                  //     : EdgeInsets.only(top: height * 0.70),
                  // height: (newContainer) ? height * 0.40 : height * 0.30,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 3.0, spreadRadius: 0.05)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: height * 0.02,
                      ),
                      buildInputWidget(
                        text: _pickUp ?? loc.getAddress.toString(),
                        onTap: () async {
                          var pickloc = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LocationReaderScreen(
                                        title: "PickUp Location",
                                      )));
                          // var ploc = await Geocoder.local
                          //     .findAddressesFromQuery(pickloc);
                          setState(() {
                            _pickUp = pickloc;
                          });
                        },
                        onMapTap: () => Pin(),
                        hint: "Pickup Location".toString(),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      buildInputWidget1(
                        extra: false,
                        text: _dropOff ?? "Destination Location",
                        onTap: () async {
                          var droploc = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LocationReaderScreen(
                                        title: "Destination Location",
                                      )));
                          var ploc = await Geocoder.local
                              .findAddressesFromQuery(droploc);
                          setState(() {
                            _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    ploc.first.coordinates.latitude,
                                    ploc.first.coordinates.longitude,
                                  ),
                                  zoom: 11,
                                ),
                              ),
                            );
                            _dropOff = droploc;
                          });
                        },
                        onMapTap: () => Pin2(),
                        hint: "Drop Location".toString(),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      (newContainer == 0)
                          ? Container()
                          : Container(
                              height: height * 0.40,
                              width: width,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: newContainer,
                                itemBuilder: (context, index) {
                                  return (index < 8)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: buildInputWidget1(
                                            extra: true,
                                            text:
                                                _dropOff2 ?? "DropOff Location",
                                            onTap: () async {
                                              var drop = await Navigator.of(
                                                      context)
                                                  .push(MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          LocationReaderScreen(
                                                            title:
                                                                "Drop Off Location",
                                                          )));

                                              setState(() {
                                                _dropOff2 = drop;
                                              });
                                            },
                                            onMapTap: () => Pin2(),
                                            hint: "Drop Location".toString(),
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                      (newContainer < 8)
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  newContainer = newContainer + 1;
                                });
                              },
                              child: Container(
                                  margin: EdgeInsets.all(15),
                                  child: Text(
                                    '+ Add Location',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  )),
                            )
                          : Container(),
                      SizedBox(height: 75),
                    ],
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

  Widget buildInputWidget({String text, String hint, onTap, onMapTap}) {
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
          IconButton(
            icon: Icon(Icons.location_on_outlined),
            onPressed: onMapTap,
          )
        ],
      ),
    );
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
          (extra)
              ? IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      newContainer = newContainer - 1;
                    });
                  })
              : IconButton(
                  icon: Icon(Icons.outlined_flag_outlined),
                  onPressed: onMapTap,
                )
        ],
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
