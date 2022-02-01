import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String text;
  const SearchBar({
    this.text
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 28, right: 68),
      height: 56,
      width: 370,
      decoration:BoxDecoration(  
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.blue
        )
      ),
      child: Row( 
        children: [
          Icon(Icons.search, size: 28,),
          SizedBox(width:12),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),)
        ],
      )
    );
  }
}