import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:transport/screens/home/location_pickup.dart';
import 'package:transport/screens/home/packersucess.dart';
import 'package:transport/screens/widget/CustomDropDown.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/screens/widget/customColor.dart';
import 'package:transport/screens/widget/customgoodsdropdown.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:http/http.dart' as http;

class RentalsandMovers extends StatefulWidget {
  @override
  _RentalsandMoversState createState() => _RentalsandMoversState();
}

class _RentalsandMoversState extends State<RentalsandMovers> {
  DateTime selectedDate = DateTime.now();
  bool _progressVisible = false;
  bool visible = true;
  int locationValue = 0;
  int _vehicleTypeValue = 0;
  int monthValue = 0;
  String _movefrom;
  String _moveTo;
  Coordinates _pickCoord;
  Coordinates _dropCoord;
  Coordinates _dropCoord2;
  var format = DateFormat.yMd().add_jm();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime rentalDate = DateTime.now();
  List _rentalVehicleType = [];
  TextEditingController value = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String validateString(String value) {
    if (value.length <= 2) {
      return 'This field is required.';
    }
    return null;
  }

  getVehicleData() async {
    final response = await http.get(Uri.parse(vehicleTypeUrl + '0'));
    if (response.statusCode != 200) {
      CustomMessage.toast('Internal Server Error');
    } else if (response.body != '') {
      var data = jsonDecode(response.body);
      if (data['status'] == 200) {
        for (var item in data['data']) {
          vehicleList.add({
            'value': item['id'].toString(),
            'name': item['name'].toString(),
          });
        }
      } else {
        CustomMessage.toast(data['message']);
      }
    }
  }

  Future<DateTime> selectDate(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(seconds: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
  }

  _packercitydata() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var response = await http.get(Uri.parse(stateListUrl));

      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        for (var item in data['data']) {
          location.add({
            'value': item['id'].toString(),
            'name': item['state'].toString(),
          });
        }
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  _bookRentalMovers() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();
      var pick = await Geocoder.local.findAddressesFromQuery(_moveTo);
      var drop = await Geocoder.local.findAddressesFromQuery(_movefrom);
      var response = await http.post(Uri.parse(bookRentalMoversUrl), body: {
        'id': user.toString(),
        'pick_lat': pick.first.coordinates.latitude.toString(),
        'pick_lng': pick.first.coordinates.longitude.toString(),
        'pick_location': _moveTo.toString(),
        'vehicle_type': vehicleList[_vehicleTypeValue]['name'].toString(),
        'date': DateFormat('yyyy-mm-dd HH:m:s').format(rentalDate),
        'drop_lat': drop.first.coordinates.latitude.toString(),
        'drop_lng': drop.first.coordinates.longitude.toString(),
        'drop_location': _movefrom.toString(),
        'time': value.text.toString(),
      });
      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        if (data['status'] == 200) {
          print(data);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackerSuccess(
                  title: 'Rentals And Movers',
                ),
              ));
        } else {
          CustomMessage.toast(data['message']);
        }
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getVehicleData();
    _packercitydata();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Rentals',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.02),
              Card(
                  child: Column(children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: height * 0.02),
                  child: Text(
                    'Enter Location Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildInputWidget(
                        text: _moveTo ?? "Moving To",
                        onTap: () async {
                          var moveToloc = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LocationReaderScreen(
                                        title: "Moving To",
                                      )));
                          if (moveToloc == null) return;
                          var ploc = await Geocoder.local
                              .findAddressesFromQuery(moveToloc);
                          _pickCoord = ploc.first.coordinates;
                          setState(() {
                            _moveTo = moveToloc;
                          });
                        },
                        // onMapTap: () => Pin(),
                        hint: "Moving To".toString(),
                      ),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      buildInputWidget(
                        text: _movefrom ?? "Moving From",
                        onTap: () async {
                          var moveloc = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LocationReaderScreen(
                                        title: "Moving From",
                                      )));
                          if (moveloc == null) return;
                          var dloc = await Geocoder.local
                              .findAddressesFromQuery(moveloc);
                          _dropCoord = dloc.first.coordinates;
                          setState(() {
                            _movefrom = moveloc;
                          });
                        },
                        hint: "Moving From".toString(),
                      ),
                      SizedBox(height: height * 0.01),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
              ])),
              SizedBox(height: height * 0.01),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 15,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: height * 0.05,
                        width: width * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            'Where Are you Planning to Move?',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                            readOnly: true,
                            style: TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(FontAwesomeIcons.calendarAlt),
                                  onPressed: () async {
                                    var selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now()
                                          .add(Duration(seconds: 1)),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (selectedDate == null) return;
                                    var selectedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (selectedTime == null) return;

                                    DateTime timeDate = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    );

                                    setState(() {
                                      this.selectedDate = timeDate;
                                    });
                                  },
                                ),
                                contentPadding: EdgeInsets.only(
                                    top: height * 0.01,
                                    bottom: height * 0.01,
                                    left: width * 0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: borderColor),
                                    gapPadding: 12),
                                hintText:
                                    selectedDate.toString().substring(0, 19))),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: height * 0.06,
                              width: width * 0.55,
                              //  margin: EdgeInsets.only(left: 11, right: 11, bottom: 11),
                              decoration: BoxDecoration(
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Container(
                                padding: EdgeInsets.only(left: 20),
                                child: DropdownButton(
                                  underline: SizedBox(),
                                  icon: Container(
                                      margin: EdgeInsets.only(left: 120),
                                      child:
                                          Icon(Icons.arrow_drop_down_outlined)),
                                  hint:
                                      Text('Day'), // Not necessary for Option 1
                                  value: _selectedLocation,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedLocation = newValue;
                                    });
                                  },
                                  items: _locations.map((location) {
                                    return DropdownMenuItem(
                                      child: new Text(location),
                                      value: location,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Container(
                              height: height * 0.06,
                              width: width * 0.3,
                              padding: EdgeInsets.only(left: 15.0, right: 10.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: borderColor)),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextFormField(
                                      validator: (value) =>
                                          validateString(value),
                                      controller: value,
                                      maxLines: 1,
                                      textAlign: TextAlign.justify,
                                      decoration: InputDecoration(
                                        hintText: 'value',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  margin: EdgeInsets.only(left: width * 0.01),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      children: [
                        Container(
                          height: height * 0.05,
                          width: width * 2,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: width * 0.01, top: height * 0.01),
                            child: Text(
                              'Type of Vehicles You are moving FROM',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: height * 0.01),
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
                                _vehicleTypeValue = value;
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              });
                            },
                            items: vehicleList,
                            value: _vehicleTypeValue,
                          ),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        )
                        // wrapHouseType(
                        //     height1: height * 0.04, width1: width * 0.25),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(height: height * 0.02),
              Center(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12)),
                  child: GestureDetector(
                    onTap: _progressVisible ? () {} : _bookRentalMovers,
                    child: _progressVisible
                        ? Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Text(
                            'Proceed',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List location = [
    {
      'name': 'Select Location',
      'value': 'NULL',
    }
  ];

  List<String> _locations = ['Day', 'Hours']; // Option 2
  String _selectedLocation;

  final List vehicleList = [
    {
      'name': 'Select Vehicle',
      'value': 'NULL',
    }
  ];

  final List houseTypes = [];
  String selectedval;
  Widget wrapHouseType({height1, width1}) {
    return Wrap(
        children: houseTypes
            .map((e) => InkWell(
                  onTap: () {
                    setState(() {
                      selectedval = e;
                    });
                  },
                  child: Container(
                      height: height1,
                      width: width1,
                      margin: EdgeInsets.only(right: 7, bottom: 7),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: (selectedval == e)
                                  ? Colors.green
                                  : borderColor),
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                          child: Text(
                        e.toString(),
                        style: TextStyle(
                            color: (selectedval == e)
                                ? Colors.green
                                : borderColor),
                      ))),
                ))
            .toList()
            .cast<Widget>());
  }
}

Widget buildInputWidget({String text, String hint, onTap, onMapTap}) {
  return Container(
    padding: EdgeInsets.only(left: 15.0, right: 10.0),
    decoration: BoxDecoration(
      color: Color(0xffeeeeee).withOpacity(0.5),
      border: Border.all(color: borderColor),
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
