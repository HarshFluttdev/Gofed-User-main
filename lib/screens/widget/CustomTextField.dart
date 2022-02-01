import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

CustomTextField({
  BuildContext context,
  double heightPadding,
  IconData icon,
  String labelText,
  String hintText,
  TextInputType keyboard,
  Function validate,
  Function onTap,
  Function onChanged,
  Function onTapSuffix,
  bool readOnly = false,
  bool obscureText = false,
  TextEditingController controller,
}) {
  return TextFormField(
    onTap: onTap,
    keyboardType: keyboard,
    validator: validate,
    readOnly: readOnly,
    obscureText: obscureText,
    controller: controller,
    decoration: InputDecoration(
      filled: true,
      fillColor: readOnly ? Colors.grey[200] : Colors.grey[100],
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: icon == null
          ? null
          : GestureDetector(
              onTap: onTapSuffix,
              child: Center(
                child: Icon(
                  icon,
                  size: 16,
                ),
              ),
            ),
      suffixIconConstraints: BoxConstraints(
        maxWidth: 60,
      ),
      labelText: labelText,
      hintText: hintText,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 30,
        vertical: heightPadding ?? 23,
      ),
    ),
    onChanged: onChanged,
  );
}


CustomTextField1({
  BuildContext context,
  double heightPadding,
  IconData icon,
  String labelText,
  String hintText,
  TextInputType keyboard,
  Function validate,
  Function onTap,
  Function onChanged,
  Function onTapSuffix,
  bool readOnly = false,
  bool obscureText = false,
  TextEditingController controller,
}) {
  return TextFormField(
    onTap: onTap,
    keyboardType: keyboard,
    validator: validate,
    readOnly: readOnly,
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      filled: true,
      fillColor: readOnly ? Colors.grey[200] : Colors.grey[100],
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: icon == null
          ? null
          : GestureDetector(
              onTap: onTapSuffix,
              child: Center(
                child: FaIcon(
                  icon,
                  size: 16,
                ),
              ),
            ),
      suffixIconConstraints: BoxConstraints(
        maxWidth: 60,
      ),
      labelText: labelText,
      hintText: hintText,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 30,
        vertical: heightPadding ?? 23,
      ),
    ),
    onChanged: onChanged,
  );
}
