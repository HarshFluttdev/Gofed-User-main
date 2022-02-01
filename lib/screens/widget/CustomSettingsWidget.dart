
import 'package:flutter/material.dart';


class CustomSettingsWidget extends StatefulWidget {
  final controller;
  final label;
  final id;
  final labelText;
  final isEditable;
  final minLines;

  const CustomSettingsWidget(
      {this.controller,
      this.label,
      this.isEditable,
      this.id, this.labelText, this.minLines});

  @override
  _CustomSettingsWidgetState createState() => _CustomSettingsWidgetState();
}

class _CustomSettingsWidgetState extends State<CustomSettingsWidget> {
  var editable = false;
  var onChange = false;
  var userId;
  TextEditingController name = TextEditingController();

 
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
        child: editable
            ? TextFormField(
                cursorColor: Colors.yellow,
                onFieldSubmitted: (String value) {
                  ///
                },
                controller: widget.controller..text = widget.label,
                decoration: InputDecoration(
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          editable = !editable;
                        });
                      },
                      icon: Icon(Icons.cancel),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    labelText: widget.labelText),
                validator: (v) {
                  if (v.trim().isEmpty) return '';
                  return null;
                },
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: width,
                height: height * 0.20,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        widget.label,
                        style: TextStyle(fontSize: 18),
                      )),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              editable = !editable;
                            });
                          },
                          child: (widget.isEditable)
                              ? Icon(
                                  Icons.edit,
                                  color: Colors.yellow,
                                )
                              : Container())
                    ]),
              ));
  }
}
