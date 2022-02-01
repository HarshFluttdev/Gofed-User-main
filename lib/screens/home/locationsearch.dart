import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  GoogleMapController _mapController;
  final _startPointController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        color: Colors.white,
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Enter Your PickUp Location ",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 20.0,
            ),
            SingleChildScrollView(
              child: CustomTextField(
                hintText: "Select starting point",
                textController: _startPointController,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapBoxAutoCompleteWidget(
                        apiKey:
                            "pk.eyJ1IjoicmFqYXQta3VtYXIiLCJhIjoiY2tjbG16dzJtMXowbzJ0bHBsM3l6dDJvdiJ9.NN4o5bdtODCPPCvpYluKAA",
                        hint: "Select starting point",
                        onSelect: (place) {
                          _startPointController.text = place.placeName;
                        },
                        limit: 10,
                      ),
                    ),
                  );
                },
                enabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
