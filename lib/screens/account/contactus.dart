import 'package:flutter/material.dart';
import 'package:transport/screens/home/chatbox.dart';
import 'package:transport/screens/login/login.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/services/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(children: [
          SizedBox(height: height*0.01,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Contact Us',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('For any queries or help', style: TextStyle(fontSize: 12))
              ]),
              Container(
                margin: EdgeInsets.only(left: 10),
                height: height * 0.04,
                width: width * 0.25,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      begin: Alignment(-1.0, -2.0),
                      end: Alignment(1.0, 2.0),
                      colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
                ),
                child: FlatButton(
                  onPressed: () async {
                      const url = "tel:9999530797";
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  child: Center(
                    child: Text(
                      'Call Us',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider(),
          InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatBox()));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  'Mail us at support@gofedtransport.in',
                  style: TextStyle(
                    color: Color(0xff6E66F6),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              margin: EdgeInsets.only(top:height*0.09),
              height: height*0.05,
            
              width: width*0.4,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                        begin: Alignment(-1.0, -2.0),
                        end: Alignment(1.0, 2.0),
                        colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
              ),
              child: TextButton(
                onPressed: () async {
                  if (await SharedData().logout()) {
                    CustomMessage.toast('Successfully Logout...!!!!');
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                        (route) => false);
                  } else {
                    CustomMessage.toast(
                      'Error while logout..!! Please try again..!!',
                    );
                  }
                },
                child: Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
