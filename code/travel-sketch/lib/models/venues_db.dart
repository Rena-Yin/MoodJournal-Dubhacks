import 'dart:convert';

import 'package:food_finder/models/venue.dart';

class VenuesDB {
  final List<Venue> _venues;

  List<Venue> get all {
    return List<Venue>.from(_venues, growable: false);
  }

  List<Venue> nearestTo({int max = 999, required double latitude, required double longitude}) {
    final sorted = [..._venues]; // copy list
    sorted.sort((a, b) => a.distanceFrom(latitude: latitude, longitude: longitude)
        .compareTo(b.distanceFrom(latitude: latitude, longitude: longitude)));
    return sorted.take(max).toList();
  }

  VenuesDB.initializeFromJson(String jsonString)
      : _venues = _decodeVenueListJson(jsonString);

  static List<Venue> _decodeVenueListJson(String jsonString) {
    final listMap = jsonDecode(jsonString);
    final theList = (listMap as List).map((element) {
      return Venue.fromJson(element);
    }).toList();
    return theList;
  }
}
