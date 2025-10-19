import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
// For HTTP requests:
import 'package:http/http.dart' as http; // ignore: unused_import
import 'dart:convert'; // ignore: unused_import

// This class creates a map that users can use to find landmarks
// near them to sketch at/find inspiration.
// Uses Google Maps for iOS API and Google Maps Places API.
class MapScreen extends StatefulWidget {
  // Constructs the map screen with key from stateful widget:
  const MapScreen({super.key});
  // Creating the state:
  @override
  MapScreenState createState() => MapScreenState();
}

// This class builds the map and controls the state of the map
// State = where the map starts, how zoomed in it is, and the ability for
// users to scroll through
class MapScreenState extends State<MapScreen> {
  // To update map:
  GoogleMapController? mapController;
  // To get user's current location:
  Location location = Location();
  // For the landmark pins:
  Set<Marker> markers = {};
  // This method is used to start the process of getting the user location
  // and updating the map accordingly
  // Parameters: controller, which allows us to zoom in/out of map, click on pins
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    await _getUserLocation();
  }

  // This method gets the user's location (similar to food finder)
  Future<void> _getUserLocation() async {
    // Request permission to access user location:
    // Test if location services are enabled (from flutter docs):
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    final userLocation = await location.getLocation();
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position: LatLng(userLocation.latitude!, userLocation.longitude!),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
      mapController?.animateCamera(
        // Adjust camera to user position:
        CameraUpdate.newLatLng(
          LatLng(userLocation.latitude!, userLocation.longitude!),
        ),
      );
    });
    // Will fetch landmarks near the user's location
    // (potential places they can draw):
    // _fetchLandmarks(userLocation.latitude!, userLocation.longitude!);
  }

  // This method fetches the landmarks near the user
  // Parameters: the user's location in latitude and longitude
   Future<void> _fetchLandmarks(double lat, double long) async {
    // Fetching landmarks (tourist attractions):
    // This url calls the backend server in server.js, which in turn
    // uses the API key to fetch the landmarks
    // MUST REPLACE WHEN BUILDING:
    final url = 'http://10.18.161.94:8080/landmarks?lat=$lat&lng=$long';
    final response = await http.get(Uri.parse(url));
    // If able to fetch:
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      setState(() {
        // Loop through the results to add markers:
        for (int i = 0; i < results.length; i++) {
          final place = results[i];
          final name = place['name'];
          // Getting the landmark's coordinates:
          final placeLat = place['geometry']['location']['lat'];
          final placeLong = place['geometry']['location']['lng'];
          // Displaying them as pins:
          markers.add(
            Marker(
              markerId: MarkerId('place_$i'),
              position: LatLng(placeLat, placeLong),
              infoWindow: InfoWindow(title: name),
            ),
          );
        }
      });
    } else {
      throw "Can't access user location";
    }
  } 

  // This method builds the widget with text describing the map's purpose and the
  // map itself. Before getting the user's location, the map starts at San
  // Francisco's coordinates.
  // Parameters: context from the widget tree
  // Returns: a widget as described above
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find landmarks near you for inspo:',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: Semantics(
        label: 'A Google Map that displays users location and landmarks nearby',
        child: GoogleMap(
          onMapCreated: _onMapCreated, // for getting user location
          markers: markers,
          initialCameraPosition: CameraPosition(
            target: LatLng(37.7749, -122.4194),
            zoom: 12,
          ),
        ),
      ),
    );
  }
}
