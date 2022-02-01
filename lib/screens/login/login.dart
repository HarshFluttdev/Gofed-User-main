import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transport/screens/login/otp.dart';
import 'package:http/http.dart' as http;
import 'package:transport/url.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _progressVisible = false;
  bool _value = true;
  final TextEditingController phoneController = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String isValidPhone(String number) {
    String pattern = r'(^(?:[0-9]{10}$))';
    RegExp regex = new RegExp(pattern);
    if (number.length == 0) return "Can't Be Empty";
    if (!regex.hasMatch(number)) return "Invalid Phone Number";
    return null;
  }

  _verifyPhone() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var mobile = phoneController.text;
      var response = await http.post(Uri.parse(mobileVerifyUrl), body: {
        'mobile': mobile,
      });

      if (response.statusCode != 200) {
        Fluttertoast.showToast(msg: 'Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        if (data['status'] == 200) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  phone: mobile,
                  login: true,
                ),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  phone: mobile,
                  login: false,
                ),
              ));
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
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment(-1.0, -2.0),
            end: Alignment(1.0, 2.0),
            colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.15,
            ),
            Container(
              width: double.infinity,
              child: Image.asset(
                'assets/maps/splash.png',
                height: height * 0.2,
              ),
            ),
            SizedBox(
              height: height * 0.22,
            ),
            Container(
                child: Text(
              'Login With OTP',
              style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            )),
            SizedBox(
              height: height * 0.07,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              height: height * 0.07,
              width: width * 0.76,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: phoneController,
                decoration: InputDecoration(
                  fillColor: Colors.black,
                  contentPadding: EdgeInsets.only(top: 10),
                  hintText: 'Mobile Number',
                  hintStyle: TextStyle(fontSize: 19, color: Colors.black),
                  prefixIcon: Icon(
                    FontAwesomeIcons.mobileAlt,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                ),
              ),
            ),
            SizedBox(
              height: height * 0.06,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              height: height * 0.07,
              width: width * 0.76,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff706BF7)),
              child: FlatButton(
                onPressed: _progressVisible ? null : _verifyPhone,
                child: _progressVisible
                    ? Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _value,
                    onChanged: (bool newvalue) {
                      setState(() {
                        _value = newvalue;
                      });
                    },
                  ),
                  Text(
                    'I agree to the terms of service and privacy policy',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  )
                ],
              ),
            ),
            // CustomProgress(_progressVisible),
          ],
        ),
      ),
    ));
  }
}
      // body: SafeArea(
      //   maintainBottomViewPadding: true,
      //   child: Stack(
      //     children: [
      //       Form(
      //         key: _formKey,
      //         child: ListView(
      //           shrinkWrap: true,
      //           physics: NeverScrollableScrollPhysics(),
      //           children: <Widget>[
      //             SizedBox(height: 50),
      //             Center(
      //               child: Text(
      //                 'Gofed',
      //                 style: TextStyle(
      //                   fontSize: 36,
      //                   fontWeight: FontWeight.w600,
      //                   color: Theme.of(context).primaryColor,
      //                 ),
      //               ),
      //             ),
      //             SizedBox(height: 70),
      //             Container(
      //               padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      //               child: CustomTextField(
      //                 controller: phoneController,
      //                 validate: isValidPhone,
      //                 context: context,
      //                 labelText: 'Mobile',
      //                 icon: Icons.phone_android,
      //                 keyboard: TextInputType.number,
      //               ),
      //             ),
      //             Container(
      //               padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      //               child: CustomElevatedButton(
      //                 context: context,
      //                 onPressed: _verifyPhone,
      //                 child: Center(
      //                   child: Text('Login'),
      //                 ),
      //               ),
      //             ),
      //             SizedBox(
      //               height: 350,
      //             ),
      //             Container(
      //               padding: EdgeInsets.symmetric(horizontal: 25),
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Checkbox(
      //                     value: _value,
      //                     onChanged: (bool newvalue) {
      //                       _value = newvalue;
      //                     },
      //                   ),
      //                   Text(
      //                     'I agree to the terms of service and privacy policy',
      //                     style: TextStyle(fontSize: 12),
      //                   )
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       CustomProgress(_progressVisible),
      //     ],
      //   ),
      // ),
   