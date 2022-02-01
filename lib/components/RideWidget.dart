import 'package:flutter/material.dart';
class RideWidget extends StatefulWidget {
  @override
  _RideWidgetState createState() => _RideWidgetState();
}

class _RideWidgetState extends State<RideWidget> {
  Color bgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 200,
      color: bgColor,
      child: ListTile(
        leading: Image.asset('assets/maps/car.png'),
        title: Text("Gofed"),
        subtitle: Text("18:43 drop-off"),
        trailing: Text("₹ 201.08"),
        onTap: () {
          if (this.bgColor == Colors.white) {
            print('grey');
            setState(() {
              this.bgColor = Colors.grey;
            });
          } else {
            print("white");
            setState(() {
              this.bgColor = Colors.white;
            });
          }
        },
      ),
    );
  }
}