import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleLocation{
  String placeId;
  LatLng position;
  String mainText;
  String secondaryText;
  String address;
  int time;

  GoogleLocation({
    this.placeId,
    this.position,
    this.mainText,
    this.secondaryText,
    this.address,
    this.time = 0,
  }) {
    if (this.address == null || this.address.isEmpty) {
      this.address = this.mainText + ', ' + this.secondaryText;
    }
  }
  factory GoogleLocation.fromJson(String str) =>
      GoogleLocation.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GoogleLocation.fromMap(Map<String, dynamic> json) => GoogleLocation(
        placeId: json["placeId"],
        position: LatLng.fromJson(json["position"]),
        mainText: json["mainText"],
        secondaryText: json["secondaryText"],
        address: json["address"],
        time: json["time"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "placeId": placeId,
        "position": LatLng(position.latitude, position.longitude).toJson(),
        "mainText": mainText,
        "secondaryText": secondaryText,
        "address": address,
        "time": time ?? 0,
      };
   
}
