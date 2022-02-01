import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/screens/home/homescreen.dart';
import 'package:transport/screens/login/login.dart';
import 'package:transport/screens/widget/CustomDropDown.dart';
import 'package:transport/screens/widget/CustomElevatedButton.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/screens/widget/CustomProgress.dart';
import 'package:transport/screens/widget/CustomTextField.dart';
import 'package:http/http.dart' as http;
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';

class RegisterScreen extends StatefulWidget {
  final String phone;
  RegisterScreen({this.phone});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String id = 'register';
  bool _value = false;
  bool _progressVisible = false;
  int purposeValue = 0;

  final TextEditingController fnameController = new TextEditingController();
  final TextEditingController lnameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List purposeList = [
    {
      'name': 'I will be using Gofed For',
      'value': 'NULL',
    }
  ];

  String isname(String name) {
    if (name.length == 0) return "Can't Be Empty";
    return null;
  }

  String isValidEmail(String email) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = new RegExp(pattern);
    if (email.length == 0) return "Can't Be Empty";
    if (!regex.hasMatch(email)) return "Invalid Email Adress";
    return null;
  }

  String dropBoxValidator(String val) {
    if (val == null) return "Please Select The Purpose";
    return null;
  }

  _register() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var fname = fnameController.text;
      var lname = lnameController.text;
      var email = emailController.text;
      var purpose = purposeList[purposeValue]['value'];

      prefs.setString("purpose", purposeList[purposeValue]['value']);

      setState(() {
        _progressVisible = true;
      });

      var response = await http.post(Uri.parse(registerUrl), body: {
        'first_name': fname.toString(),
        'last_name': lname.toString(),
        'email': email.toString(),
        'mobile': widget.phone.toString(),
        'purpose': purpose.toString(),
      });

      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("UserMobileNo", widget.phone.toString());
        if (data['status'] == 200) {
          _userdetails();
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

  _userdetails() async {
    setState(() {
      _progressVisible = true;
    });

    var response = await http.post(Uri.parse(userDetailsUrl), body: {
      'mobile': widget.phone.toString(),
    });

    if (response.statusCode != 200) {
      CustomMessage.toast('Internal Server Error');
    } else if (response.body != '') {
      var data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("UserMobileNo", widget.phone.toString());
      await SharedData().setUser(data['data'][0]['id']);
      if (data['status'] == 200) {
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false);
      } else {
        // CustomMessage.toast(data['message']);
      }
    }

    setState(() {
      _progressVisible = false;
    });
  }

  _data() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var response = await http.get(Uri.parse(purposeListUrl));

      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        for (var item in data['data']) {
          purposeList.add({
            'value': item['id'].toString(),
            'name': item['name'].toString(),
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

  @override
  void initState() {
    super.initState();
    _data();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SafeArea(
          maintainBottomViewPadding: true,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
            ),
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: height * 0.03),
                            child: Image.asset(
                              'assets/maps/splash.png',
                              height: height * 0.09,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.01),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/maps/india.png',
                              height: height * 0.04,
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Text(
                              widget.phone,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'change',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: fnameController,
                                validate: isname,
                                hintText: 'First Name',
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: lnameController,
                                validate: isname,
                                hintText: 'Last Name',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: CustomTextField(
                          controller: emailController,
                          validate: isValidEmail,
                          hintText: 'Email',
                          icon: Icons.email,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          'Requirement',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: CustomDropDown(
                          context: context,
                          func: (value) {
                            setState(() {
                              purposeValue = value;
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            });
                          },
                          items: purposeList,
                          value: purposeValue,
                        ),
                      ),
                      SizedBox(height: 18),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.15, vertical: height * 0.04),
                        child: CustomElevatedButton(
                          context: context,
                          onPressed: () {
                            if (!_formKey.currentState.validate()) return;
                            if (purposeValue == 0) return;

                            _register();
                          },
                          child: Center(
                            child: Text(
                              'Register',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Checkbox(
                              activeColor: Color(0xff706BF7),
                              value: _value,
                              onChanged: (bool newvalue) {
                                setState(() {
                                  _value = newvalue;
                                });
                              },
                            ),
                            Text(
                              'Receive WhatsApp Communication from Gofed',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Text(
                            'A One Time OTP will be sent to this number for verification',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ))
                    ],
                  ),
                ),
                CustomProgress(_progressVisible),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
