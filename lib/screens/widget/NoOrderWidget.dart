import 'package:flutter/material.dart';
import 'package:transport/screens/home/homescreen.dart';

class NoOrderWidget extends StatelessWidget {
  const NoOrderWidget({
    Key key,
    @required this.height,
    @required this.width,
  }) : super(key: key);

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            margin:
                EdgeInsets.only(top: 100,),
            child: Image.asset(
              'assets/maps/noOrder.png',
              height: 162,
            ),
          ),
          Container(
              margin:
                  EdgeInsets.only( top: 50),
              child: Text(
                'No Orders Found',
                style: TextStyle(
                    color: Color(0xffC7C7C7),
                    fontSize: 25),
              )),
          Container(
            margin:
                EdgeInsets.only( top: 50),
            height: height * 0.07,
            width: width * 0.76,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10),
                color: Color(0xffC7C7C7)),
            child: FlatButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen()));
              },
              child: Center(
                child: Text(
                  'Book Now',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25),
                ),
              ),
            ),
          ),
        ],
      );
  }
}
