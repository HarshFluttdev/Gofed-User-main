import 'package:flutter/material.dart';
import 'package:transport/screens/home/homescreen.dart';

class RideCancelScreen extends StatelessWidget {
  const RideCancelScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/maps/movertruck.png',
              width: 180,
            ),
            SizedBox(height: 50),
            Text(
              'Your ride is cancelled as we are not able to find driver for your ride..!! Sorry for inconvenience..!!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 80),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                      (route) => false);
                },
                child: Text('Go to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
