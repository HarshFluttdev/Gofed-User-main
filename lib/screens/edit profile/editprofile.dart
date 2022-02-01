import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController firstnameController = new TextEditingController();
  final TextEditingController lastnameController = new TextEditingController();
  final TextEditingController gstapplyController = new TextEditingController();
  final TextEditingController gstnoController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController gstaddressController =
      new TextEditingController();

  var id = "",
      mobile = "",
      firstname = "",
      lastname = "",
      email = "",
      gstno = "",
      gstaddress = "";
  getidData() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http
        .post(Uri.parse(profileUrl), body: {'mobile': prefs.get('UserMobileNo').toString()});

    var data = jsonDecode(response.body);
    setState(() {
      id = data['data'][0]['id'];
      mobile = data['data'][0]['mobile'];
      firstname = data['data'][0]['first_name'];
      lastname = data['data'][0]['last_name'];
      email = data['data'][0]['email'];
      gstno = data['data'][0]['gst_no'];
      gstaddress = data['data'][0]['gst_address'];
    });
  }

  updateProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(Uri.parse(updateprofileUrl), body: {
      'id': id.toString(),
      'first_name': firstnameController.text,
      'last_name': lastnameController.text,
      'gst_apply': gstapplyController.text,
      'gst_no': gstnoController.text,
      'gst_address': gstaddressController.text,
      'email': gstaddressController.text
    });
    if (response.statusCode != 200) {
      CustomMessage.toast('Internal Server Error');
    } else if (response.body != '') {
      var data = jsonDecode(response.body);

      if (data['status'] == 200) {
        CustomMessage.toast(data['message']);
      } else {
        // CustomMessage.toast(data['message']);
      }
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    getidData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Details',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Form(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mobile Number', style: TextStyle(fontSize: 13)),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(mobile,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Text('cannot be changed', style: TextStyle(fontSize: 13)),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 40, bottom: 50),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    child: TextField(
                        controller: firstnameController..text = firstname,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                        )),
                  ),
                  Container(
                    child: TextFormField(
                        controller: lastnameController..text = lastname,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                        )),
                  ),
                  Container(
                    child: TextField(
                        controller: emailController..text = email,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                        )),
                  ),
                  Container(
                    child: TextFormField(
                        controller: gstapplyController,
                        decoration: InputDecoration(
                          hintText: 'GST Details',
                          border: UnderlineInputBorder(),
                        )),
                  ),
                  Container(
                    child: TextFormField(
                        controller: gstnoController,
                        decoration: InputDecoration(
                          hintText: 'GST Number',
                          border: UnderlineInputBorder(),
                        )),
                  ),
                  Container(
                    child: TextFormField(
                        controller: gstaddressController,
                        decoration: InputDecoration(
                          hintText: 'GST Address',
                          border: UnderlineInputBorder(),
                        )),
                  )
                ]),
              ),
              GestureDetector(
                onTap: () {
                  updateProfileData();
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xff0ED678),
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: FlatButton(
                        onPressed: () {  },
                        child: Text('Save', style: TextStyle(fontSize: 20)),
                      ),
                    )),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
