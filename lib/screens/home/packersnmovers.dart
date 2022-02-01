import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:transport/screens/home/location_pickup.dart';
import 'package:transport/screens/home/packersucess.dart';
import 'package:transport/screens/widget/CustomDropDown.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/screens/widget/customColor.dart';
import 'package:http/http.dart' as http;
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';

class PackersAndMovers extends StatefulWidget {
  @override
  _PackersAndMoversState createState() => _PackersAndMoversState();
}

class _PackersAndMoversState extends State<PackersAndMovers> {
  DateTime selectedDate = DateTime.now();
  bool visible = true;
  bool _progressVisible = false;
  int locationValue = 0;
  String _movefrom;
  String _moveTo;
  var format = DateFormat.yMd().add_jm();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime rentalDate = DateTime.now();

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

  _packerflatdata() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var response = await http.get(Uri.parse(pamFlatListUrl));

      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        for (var item in data['data']) {
          houseTypes.add(
            {
              'name': item['name'].toString(),
              'id': item['id'].toString(),
            },
          );
        }
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  _bookPAM() async {
    try {
      var flatType = '0';
      for (var item in houseTypes) {
        if (item['name'] == selectedval) flatType = item['id'].toString();
      }
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();
      var response = await http.post(Uri.parse(bookpamUrl), body: {
        'id': user.toString(),
        'city': locationValue.toString(),
        'lat': _movefrom,
        'lng': _movefrom,
        'location': _movefrom,
        'date': selectedDate.toString(),
        'flat': flatType.toString()
      });
      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        if (data['status'] == 200) {
          CustomMessage.toast(data['message']);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackerSuccess(
                  title: 'Packers And Movers',
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
    _packercitydata();
    _packerflatdata();
    _bookPAM();
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
          'Packers And Movers',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
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
              Container(
                height: height * 0.06,
                width: width * 0.9,
                margin: EdgeInsets.only(left: 11, right: 11, bottom: 11),
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(10)),
                child: CustomDropDown(
                  context: context,
                  func: (value) {
                    setState(() {
                      locationValue = value;
                    });
                  },
                  items: location,
                  value: locationValue,
                ),
              ),
              (locationValue == 0)
                  ? Column(
                      children: [
                        SizedBox(height: 20),
                        Center(
                            child: Icon(
                          Icons.add_location,
                          size: 50,
                          color: iconColor,
                        )),
                        SizedBox(height: 5),
                        Text(
                          'Please Select Location to Proceed',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 20),
                      ],
                    )
                  : Padding(
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

                              setState(() {
                                _moveTo = moveToloc;
                              });
                              print(_moveTo);
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
                    )
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
                            'Type of house You are moving FROM',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      wrapHouseType(
                          height1: height * 0.04, width1: width * 0.25),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            SizedBox(height: height * 0.02),
            Center(
              child: InkWell(
                onTap: (locationValue == 0) ? null : () {},
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  decoration: BoxDecoration(
                      color: (locationValue == 0) ? Colors.grey : primaryColor,
                      borderRadius: BorderRadius.circular(12)),
                  child: GestureDetector(
                    onTap: _progressVisible ? () {} : _bookPAM,
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
            ),
          ],
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

  List<Map> houseTypes = [];
  String selectedval;
  Widget wrapHouseType({height1, width1}) {
    return Wrap(
        children: houseTypes
            .map((e) => InkWell(
                  onTap: () {
                    setState(() {
                      selectedval = e['name'];
                    });
                  },
                  child: Container(
                      height: height1,
                      width: width1,
                      margin: EdgeInsets.only(right: 7, bottom: 7),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: (selectedval == e['name'])
                                  ? Colors.green
                                  : borderColor),
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                          child: Text(
                        e['name'],
                        style: TextStyle(
                            color: (selectedval == e['name'])
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
