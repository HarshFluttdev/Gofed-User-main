
import 'package:flutter/cupertino.dart';

class EnabledProvider with ChangeNotifier{
  bool isEnabled = false;
  EnabledProvider({ this.isEnabled});
  set enable(bool en){
    isEnabled = en;
    notifyListeners();
  }
}