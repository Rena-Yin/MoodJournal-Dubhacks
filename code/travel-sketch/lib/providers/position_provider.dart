import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PositionProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  bool _knownPosition = false;
  Timer? _timer;

  PositionProvider() {
    _startTracking();
  }

  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Changed getter name to hasLocation to match usage in food_finder.dart
  bool get hasLocation => _knownPosition;

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final Position position = await _determinePosition();
        _latitude = position.latitude;
        _longitude = position.longitude;
        _knownPosition = true;
        notifyListeners();
      } catch (_) {
        _knownPosition = false;
        notifyListeners();
      }
    });
  }

  Future<Position> _determinePosition() async {
    // From geolocator docs:
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
