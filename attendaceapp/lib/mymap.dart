import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MyMap({super.key, required this.latitude, required this.longitude});

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late GoogleMapController mapController;

  // Called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 81, 255),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              
              child: const Icon(Icons.arrow_back, color: Colors.white),
            
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("location_marker"),
              position: position,
              infoWindow: const InfoWindow(title: "Selected Location"),
            ),
          },
          myLocationEnabled: true, // Show user's current location
          myLocationButtonEnabled: true, // Show location button
          zoomControlsEnabled: true, // Show zoom buttons
        ),
      ),
    );
  }
}
