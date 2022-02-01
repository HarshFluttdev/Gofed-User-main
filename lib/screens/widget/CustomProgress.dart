import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

CustomProgress(bool visible) {
  return Visibility(
    visible: visible,
    maintainState: true,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Container(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    ),
  );
}
