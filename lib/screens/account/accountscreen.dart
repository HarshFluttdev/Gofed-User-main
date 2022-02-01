import 'dart:convert';

import 'package:expansion_card/expansion_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/screens/account/contactus.dart';
import 'package:transport/screens/account/refferfriends.dart';
import 'package:http/http.dart' as http;
import 'package:transport/screens/edit%20profile/editprofile.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isExpanded = false;
  var loading = false;

  var firstname = "", lastname = "", mobile = "", id = "", email = "";
  getProfileData() async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(profileUrl),
        body: {'mobile': prefs.get('UserMobileNo').toString()});

    var data = jsonDecode(response.body);
    var userdata = data['data'];
    setState(() {
      firstname = userdata[0]['first_name'];
      lastname = data['data'][0]['last_name'];
      mobile = data['data'][0]['mobile'];
      id = data['data'][0]['id'];
      email = data['data'][0]['email'];
      loading = false;
    });
  }

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: width * 4,
                  height: (_isExpanded) ? height * 0.55 : height * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment(-1.0, -2.0),
                          end: Alignment(1.0, 2.0),
                          colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      )),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionCard(
                          onExpansionChanged: (bool) {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          margin: EdgeInsets.only(top: height * 0.01),
                          title: Container(
                            margin: EdgeInsets.only(top: height * 0.015),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      firstname + lastname,
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      'View Details',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(children: [
                                  Text(mobile,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white)),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.verified,
                                    color: Colors.greenAccent,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          children: <Widget>[
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: height * 0.01,
                                      left: width * 0.04,
                                      right: width * 0.03),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        email,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Container(
                                        height: height * 0.04,
                                        width: width * 0.2,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: FlatButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfile()));
                                          },
                                          child: Text(
                                            'Verify',
                                            style: TextStyle(
                                                color: Color(0xff6F69F6)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: height * 0.01,
                                          left: width * 0.04,
                                        ),
                                        child: Text(
                                          'Unverified',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: width * 0.77),
                                      height: height * 0.04,
                                      width: width * 0.2,
                                      decoration: BoxDecoration(
                                          color: Color(0xff0ED678),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: FlatButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfile()));
                                        },
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(top: height * 0.02),
                            child: Image.asset('assets/maps/delivery.png'))
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Refferfriends(),
                SizedBox(height: 8),
                ContactUs()
              ],
            ),
          ),
        ),
        Visibility(
          maintainState: true,
          visible: loading,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Center(
              child: Container(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
