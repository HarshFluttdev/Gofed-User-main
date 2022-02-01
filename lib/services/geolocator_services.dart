
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:transport/model/google_location.dart';
import 'package:transport/model/google_place.dart';

class GeoLocatorService {
  static const String ROOT_URL = "https://maps.googleapis.com/maps/api/";
  static const String PLACES_BASE_URL = ROOT_URL + "place/autocomplete/json";

  static const String PLACES_ID_BASE_URL = ROOT_URL + "place/details/json";

  static const String DISTANCE_API_BASE_URL = ROOT_URL + "distancematrix/json";

  static const String PLACES_API_KEY =
      "AIzaSyDJki66xdJ8dZy72cs0XoGqhCA0LNTfsdo";

  static const String COUNTRY_QUERY = "components=country:in";

  static Future<Position> getCurrentLocation() async {
    return await Geolocator().getCurrentPosition();
  }

  static Future<List<GooglePlace>> getLocationsFromInput(String input) async {
    if (input.isEmpty) {
      return [];
    }
    String request =
        "$PLACES_BASE_URL?input=$input&$COUNTRY_QUERY&key=$PLACES_API_KEY";
    try {
      /// DUE TO PRICING REASON CURRENTLY IT WILL TAKE LOCAL INPUT
      /// UN COMMENT IT WHEN YOU ARE READY TO go;
      Response response = await Dio().get(request);
      final data = response.data;

//      final data = getLocalAddress();

      final predictions = data["predictions"];
      List<GooglePlace> _results = [];

      for (var i = 0; i < predictions.length; i++) {
//     // Message("getLocationsFromAddresses", "${predictions[i]}");

        _results.add(new GooglePlace(
            id: predictions[i]['id'],
            placeId: predictions[i]['place_id'],
            mainText: predictions[i]['structured_formatting']['main_text'] ??
                predictions[i]['description'],
            secondaryText: predictions[i]['structured_formatting']
                    ['secondary_text'] ??
                ''));
      }
      return _results;
    } catch (e) {
      // Message("getLocationsFromAddresses", e.toString());
      return [];
    }
  }

  static Future<GoogleLocation> getAddressFromPlaceId(String placeId) async {
    if (placeId.isEmpty) {
      return null;
    }
    String request =
        "$PLACES_ID_BASE_URL?place_id=$placeId&fields=name,address_component,formatted_address,geometry&key=$PLACES_API_KEY";

    try {
      Response response = await Dio().get(request);
      final data = response.data;
      // print('${data.toString()}');
      // Message("GeoLocatorService ", "getAddressFromPlaceId ${data.toString()}");
      if (data != null && data['result'] != null) {
        final geometry = data['result']['geometry'];
        if (geometry != null) {
          final location = geometry['location'];
          if (location != null) {
            return GoogleLocation(
                placeId: placeId,
                secondaryText: data['result']['formatted_address'] ?? '',
                mainText: data['result']['name'] ?? '',
                position:
                    LatLng(location['lat'] ?? 0.0, location['lng'] ?? 0.0));
          }
        }
      }
    } catch (e) {
      // Message("getAddressFromPlaceId", e.toString());
      return null;
    }
    return null;
  }
}
