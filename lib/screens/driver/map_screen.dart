import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(2.0469, 45.3182),
          zoom: 14,
        ),
      ),
    );
  }
}