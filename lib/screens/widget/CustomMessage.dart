import 'package:fluttertoast/fluttertoast.dart';

class CustomMessage {
  CustomMessage.toast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }
}
