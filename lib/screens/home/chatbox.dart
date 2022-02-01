
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transport/model/chatmodel.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:http/http.dart' as http;

class ChatBox extends StatefulWidget {

  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  bool _progressVisible = false;
  final TextEditingController chatController = new TextEditingController();
  List<ChatMessage> messages = [];
  Timer timer;


  chatSupportList() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();

      var response = await http.post(Uri.parse(chatSupportListURL), body: {
        'id': user.toString(),
      });
      if (response.statusCode != 200) {
        print('yor Internal Server Error');
      } else if (response.body != '') { 
        var data = jsonDecode(response.body);
        var d = data['data'];
        if (data['status'] == 200) {
          for(var i=0; i< d.length; i++){
             messages.insert(0, 
            ChatMessage(chat: d[i]['chat_message'].toString(),fromId: d[i]['from_id'].toString()),
            );
          }

        } else {
        }
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  chatSupportSend() async {
    try {
      setState(() {
        _progressVisible = true;
      });

      var user = await SharedData().getUser();

      var response = await http.post(Uri.parse(chatSupportSendURL), body: {
        'id': user.toString(),
        'chat': chatController.text,
      });
      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);
        print(data);
        if (data['status'] == 200) {
          chatController.clear();
          setState(() {
            chatSupportList();
          });
        } else {
           CustomMessage.toast(data['message']);
        }
      }

      setState(() {
        _progressVisible = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
     chatSupportList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff6D5EF6),
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.white,),
                ),
                SizedBox(width: 2,),
                CircleAvatar(
                  backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/5.jpg"),
                  maxRadius: 20,
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Chat Support",style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600,color: Colors.white),),
                      SizedBox(height: 6,),
                      Text("Online",style: TextStyle(color: Colors.white, fontSize: 13),),
                    ],
                  ),
                ),
                Icon(Icons.more_vert_rounded,color: Colors.white,)
              ],
            ),
          ),
        ),
      ),
      body:Stack(
        children: <Widget>[
           ListView.builder(
             reverse: true,
             scrollDirection: Axis.vertical,
            itemCount: messages.length,
           shrinkWrap: true,
           padding: EdgeInsets.only(top: 10,bottom: 60),
           physics: NeverScrollableScrollPhysics(),
           itemBuilder: (context, index){
           return Container(
             padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
             child: Align(
               alignment: (messages[index].fromId == "0"?Alignment.topLeft:Alignment.topRight),
               child: Container(
                 decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (messages[index].fromId == "0"
            ? Colors.white
            : Color(0xff6D5EF6)),
                 ),
                 padding: EdgeInsets.all(16),
                 child:  (messages[index].fromId == "0" )
                ? Text(messages[index].chat, style: TextStyle(fontSize: 15,color: Colors.black),)
                 : Text(messages[index].chat, style: TextStyle(fontSize: 15,color: Colors.white),),
               ),
             ),
           );
           },
           ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              // padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.laughWink,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: chatController,
                        decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none
                        ),
                      ),
                  ),
                 
                  Container(
                    width: 55,
                    height: 55,
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: RaisedButton(
                      color: Color(0xff6D5EF6),
                      onPressed: () {
                              chatSupportSend();
                            },
                      child: FaIcon(
                             FontAwesomeIcons.play,
                        color: Colors.white,
                        size: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(150),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }
}