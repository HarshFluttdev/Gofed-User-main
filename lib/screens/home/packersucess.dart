import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transport/screens/home/homescreen.dart';
import 'package:transport/screens/widget/customColor.dart';

class PackerSuccess extends StatefulWidget {
  final String title;
  const PackerSuccess({Key key, this.title}) : super(key: key);
  @override
  _PackerSuccessState createState() => _PackerSuccessState();
}

class _PackerSuccessState extends State<PackerSuccess> {
  static const String id = '/Packersuccess';
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${(widget as PackerSuccess).title}',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            Center(
              child: Image.asset(
                'assets/maps/movertruck.png',
                height: height * 0.25,
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Text(
              'Thank you',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Text(
              'We have received your details',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Text(
                  'We will reach out to you within 24 hours for the price estimates',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )),
                SizedBox(height: height*0.2,),
            Container(
              margin: EdgeInsets.only(left: 10),
              height: height * 0.06,
              width: width * 0.7,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: primaryColor),
              child: FlatButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                },
                child: Center(
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
