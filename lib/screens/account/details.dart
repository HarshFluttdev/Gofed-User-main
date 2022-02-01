import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String phone;
  final bool phoneVerify;
  final String name;
  final String email;
  final bool emailVerify;
  const Details({
    Key key,
    this.phone,
    this.email,
    this.emailVerify,
    this.name,
    this.phoneVerify
  }):super(key: key);
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  bool more=false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Container( 
        padding: EdgeInsets.symmetric(horizontal:15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: TextStyle(  
                fontSize: 36,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height:12),
            Row(
              children: [
                Text(
                  widget.phone,
                  style:TextStyle(
                    fontSize: 14,
                  )
                ),
                SizedBox(width:8),
                (widget.phoneVerify)?Icon(Icons.verified, color: Colors.green,):Icon(Icons.verified, color: Colors.red,)
              ]
            ),
            SizedBox(height:9),
            (!more)?InkWell(
              onTap: (){
                setState(() {
                  more = true;
                });
              },
              child: Text('View Details',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              )
            ):moreDetails(widget.email, widget.emailVerify, widget.phone, widget.name)
          ],
        ),
      ),
    );
  }

  Widget moreDetails(String email, bool emailVerify, String phone, String name){
    return Column(  
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style:TextStyle(  
                    fontSize: 14
                  )
                ),
                SizedBox(height:8),
                (emailVerify)?Text(
                  'Verfied',
                  style: TextStyle(  
                    fontSize: 12,
                    color: Colors.green
                  ),
                ):
                Text(
                  'Unverfied',
                  style: TextStyle(  
                    fontSize: 12,
                    color: Colors.red
                  ),
                ),
              ]
            ),
            (!emailVerify)?ElevatedButton(
              onPressed: (){},
              child: Text(
                'Verify',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                primary: Colors.green
              ),
            ):SizedBox()
          ]
        ),
        SizedBox(height:8),
        Divider(),
        Padding(  
          padding: EdgeInsets.symmetric(vertical:4),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    more = false;
                  });
                },
                child: Text('Hide Details',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
              ElevatedButton(
                onPressed: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(
                  //   phone: phone,
                  //   name: name,
                  //   email: email,
                  // )));
                },
                child: Text(
                  'edit',
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)
                  ),
                  elevation: 0
                ),
              )
            ],
          )
        )
      ],
    );
  }
}