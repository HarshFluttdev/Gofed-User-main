import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  double latitude;
  double longitude;
  var selectAddress;
  bool _isLoading = true;
  String _getAddress = "Please Select location !";

  get getAddress => _getAddress;
  get isLoading => _isLoading;

  LocationProvider() {
    getCurrentPosition();
  }

  Future<void> getCurrentPosition() async {
    _isLoading = true;
    notifyListeners();
    await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      this.latitude = position.latitude;
      this.longitude = position.longitude;
      notifyListeners();
      _isLoading = false;
      notifyListeners();
    }).onError((error, stackTrace) {
     // print("ERROR: $error");
    });
  }

  void onCameraMove(CameraPosition cameraPosition) async {
    this.latitude = cameraPosition.target.latitude;
    this.longitude = cameraPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    final coordinates = new Coordinates(this.latitude, this.longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    this.selectAddress = addresses.first;
    _getAddress = "${selectAddress.addressLine}";
    notifyListeners();
    print("${selectAddress.featureName} : ${selectAddress.addressLine}");
  }
}