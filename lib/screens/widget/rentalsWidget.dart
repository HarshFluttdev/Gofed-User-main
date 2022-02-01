import 'package:flutter/material.dart';
import 'package:transport/screens/home/rentalandmovers.dart';

class RentalsWidget extends StatelessWidget {
  const RentalsWidget({
    Key key,
    @required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: width * 0.02),
      height: 50,
      width: width * 0.45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            // showFlexibleBottomSheet(
            //   isExpand: false,
            //   minHeight: 0,
            //   initHeight: 1,
            //   maxHeight: 1,
            //   context: context,
            //   builder: (context, scrollController,
            //       bottomSheetOffset) {
            //     return StatefulBuilder(
            //       builder: (context, setState) {
            //         return _pickupBottomSheet(
            //           context,
            //           scrollController,
            //           bottomSheetOffset,
            //           setState,
            //         );
            //       },
            //     );
            //   },
            //   anchors: [0, 0.5, 1],
            // );
            // if (_pickUp == null) {
            //   _pickUp = loc.getAddress.toString();
            // }
            Navigator.push(context, MaterialPageRoute(builder: (context)=>RentalsandMovers()));
          },
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Image.asset(
                'assets/maps/home.png',
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Rental And Movers',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
