
import 'dart:collection';

import 'package:flutter/cupertino.dart';

class DropDownSelector with ChangeNotifier{

  final List<String> optionsString;
  DropDownSelector({
    this.optionsString
  });

  String _selectOption;

  UnmodifiableListView<String> get items {
    return UnmodifiableListView(this.optionsString);
  }

  String get selectedOption {
    return _selectOption;
  }

  set setSelectedOption(final String option){
    _selectOption = option;
    notifyListeners();
  }
}