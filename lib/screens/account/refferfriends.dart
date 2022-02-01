import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
class Refferfriends extends StatefulWidget {
  @override
  _RefferfriendsState createState() => _RefferfriendsState();
}

class _RefferfriendsState extends State<Refferfriends> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(children: [
          // Container(
          //   height:190,
          //   width:270,
          //   child:Image.network(
          //     'https://image.freepik.com/free-vector/refer-friend-earn-reward_140185-35.jpg',
          //     fit: BoxFit.fill
          //   ),
          // ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Invite Friends',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('If you like our work,\nPlease spread the word!',
                    style: TextStyle(fontSize: 12))
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
                    await FlutterShare.share(
                      title: 'Heyy, Checkout GoFed Transport!',
                      text:
                          'Heyyy, checkout GoFed Transport. It provides fastest and luxurious travels!',
                      linkUrl: '',
                      chooserTitle: 'Where do you want to share?',
                    );
                  },
                  child: Center(
                    child: Text(
                      'Share',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12)
        ]),
      ),
    );
  }
}
