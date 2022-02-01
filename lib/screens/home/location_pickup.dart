import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:transport/model/google_location.dart';
import 'package:transport/services/geolocator_services.dart';

class LocationReaderScreen extends PlacesAutocompleteWidget {
  final String title;

  LocationReaderScreen({this.title})
      : super(
          apiKey: GeoLocatorService.PLACES_API_KEY,
          language: "en",
          components: [Component(Component.country, "in")],
        );

  @override
  _LocationReaderScreenState createState() => _LocationReaderScreenState();
}

class _LocationReaderScreenState extends PlacesAutocompleteState {
  GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      key: searchScaffoldKey,
      appBar: AppBar(
        backgroundColor: _theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(null);
            }
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
           Text(
              "Select ${(widget as LocationReaderScreen).title}",
              style: TextStyle(fontSize: 16,color: Colors.black),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xff706BF7),
              ),
              borderRadius: BorderRadius.circular(20)
            ),
              child: AppBarPlacesAutoCompleteTextField()),
            SizedBox(
              height: 15.0,
            ),
            Expanded(
              child: PlacesAutocompleteResult(
                logo: Text(""),
                onTap: (p) async {
                  GoogleLocation location =
                      await GeoLocatorService.getAddressFromPlaceId(
                          p.reference);
                  Navigator.of(context).pop(location.address.toString());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }
}
