import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  MapPage({
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng _currentLocation;
  GoogleMapController? _mapController;
  Marker? _currentMarker;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _latController.text = widget.initialLatitude.toString();
    _lngController.text = widget.initialLongitude.toString();
    _currentMarker = Marker(
      markerId: MarkerId('current_location'),
      position: _currentLocation,
      infoWindow: InfoWindow(title: 'Current Location'),
    );
  }

  void _updateLocation() async {
    final double? lat = double.tryParse(_latController.text);
    final double? lng = double.tryParse(_lngController.text);

    if (lat != null && lng != null) {
      setState(() {
        _currentLocation = LatLng(lat, lng);
        _currentMarker = Marker(
          markerId: MarkerId('current_location'),
          position: _currentLocation,
          infoWindow: InfoWindow(title: 'Current Location'),
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      });

      // Launch Google Maps with navigation
      final url = 'google.navigation:q=$lat,$lng';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid latitude or longitude')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _latController,
              decoration: InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _lngController,
              decoration: InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          ElevatedButton(
            onPressed: _updateLocation,
            child: Text('Navigate to Location'),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 13.0,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _currentMarker != null ? {_currentMarker!} : {},
            ),
          ),
        ],
      ),
    );
  }
}
