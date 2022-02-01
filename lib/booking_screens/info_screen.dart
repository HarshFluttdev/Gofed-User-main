import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class TermsAndConditions extends StatefulWidget {
  final String data;
  final String image;
  TermsAndConditions({this.data, this.image});

  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          iconSize: 20,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Terms And Conditions',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1.1,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.image),
            Html(
              data: '${widget.data}',
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            ),
          ],
        ),
      ),
    );
  }
}
