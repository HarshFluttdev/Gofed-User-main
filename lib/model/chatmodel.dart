import 'package:flutter/cupertino.dart';

class ChatMessage{
  String chat;
  String fromId;

  ChatMessage({
    String chat,
    String fromId,
  }) {
    this.chat = chat;
    this.fromId = fromId;
  }
}

enum ChatModelEvent { add }
enum ChatType { text, image, audio }
enum ChatUserType { own, other }
enum ChatMode { offline, online }