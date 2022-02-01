import 'package:flutter/material.dart';
import 'package:transport/screens/home/packersnmovers.dart';


class PackersWidget extends StatelessWidget {
  const PackersWidget({
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PackersAndMovers()));
          },
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Image.asset(
                'assets/maps/home.png',
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Packers & Movers',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
