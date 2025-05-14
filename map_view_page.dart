import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String name;

  const MapViewPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text('موقع $name'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: position,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('workerLocation'),
            position: position,
            infoWindow: InfoWindow(title: name),
          ),
        },
        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
