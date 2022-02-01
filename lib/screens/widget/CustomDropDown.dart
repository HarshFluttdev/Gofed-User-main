import 'package:flutter/material.dart';

CustomDropDown({
  BuildContext context,
  var items,
  int value,
  double width,
  Function func,
}) {
  return GestureDetector(
    onTap: (){},
    child: Container(
      width: double.infinity,
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.grey[100],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          icon: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 10,
              color: Colors.black,
            ),
          ),
          value: value,
          onChanged: func,
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  items[index]['name'].toString(),
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  overflow: TextOverflow.fade,
                ),
              ),
              value: index,
            );
          }),
          isExpanded: true,
        ),
      ),
    ),
  );
}
