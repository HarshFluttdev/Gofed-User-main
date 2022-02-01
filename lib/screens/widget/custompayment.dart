import 'package:flutter/material.dart';

CustomPaymentDropDown({
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
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          icon: Padding(
            padding: const EdgeInsets.only(right: 20),
          ),
          value: value,
          onChanged: func,
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              child: Text(
                items[index]['name'].toString(),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                overflow: TextOverflow.fade,
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
