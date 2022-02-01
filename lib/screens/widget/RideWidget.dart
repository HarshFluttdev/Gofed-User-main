import 'package:flutter/material.dart';
import 'package:transport/screens/home/driverdetails.dart';

class RideWidget extends StatefulWidget {
  final truckPrice,
      truckName,
      id,
      asset,
      pickUpLocation,
      dropUpLocation,
      location;
  RideWidget(
      {Key key,
      this.truckPrice,
      this.truckName,
      this.asset,
      this.pickUpLocation,
      this.dropUpLocation,
      this.location,
      this.id});

  @override
  _RideWidgetState createState() => _RideWidgetState();
}

class _RideWidgetState extends State<RideWidget> {
  Color bgColor = Colors.white;

  int selectedval = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [],
      ),
    );

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          Container(
              height: height * 0.3,
              width: width * 0.26,
              color: bgColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Row(
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DriverDetails(
                                          truckName: widget.truckName,
                                          id: widget.id,
                                          pickUpLocation:
                                              (widget.pickUpLocation == null)
                                                  ? widget.location
                                                  : widget.pickUpLocation,
                                          dropUpLocation: widget.dropUpLocation,
                                        )));
                          },
                          child: Container(
                              height: height * 0.12,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Color(0xff706BF7))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      widget.asset,
                                      height: height * 0.03,
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    Text(widget.truckName),
                                  ],
                                ),
                              )),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Text('5 min'),
                        Text(widget.truckPrice)
                      ],
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
