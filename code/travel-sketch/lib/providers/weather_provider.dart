import 'package:flutter/material.dart';
import 'package:food_finder/weather_checker.dart';
import 'package:food_finder/weather_conditions.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// A ChangeNotifier that manages and updates the current weather state.
///
/// Purpose: This provider tracks the temperature and weather condition,
/// fetches new data regularly, and notifies listeners (e.g., UI) when
/// new data is available.
class WeatherProvider extends ChangeNotifier {
  /// Current temperature in Fahrenheit
  int tempInFahrenheit = 0;

  /// Current weather condition
  WeatherCondition condition = WeatherCondition.unknown;

  /// A WeatherChecker instance to fetch and update weather data
  late final WeatherChecker _checker;

  /// Indicates whether the weather data has been loaded
  bool hasLoadedWeather = false;

  /// Constructor for WeatherProvider
  WeatherProvider() {
    _checker = WeatherChecker(this); // or whatever WeatherChecker expects
    _init(); // Fetch location and start updates

    // Set up a periodic timer to fetch weather data every 60 seconds
    // This is a simple way to keep the weather data fresh
    // ignore: unused_local_variable
    final timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _checker.fetchAndUpdateCurrentSeattleWeather();
    });
  }

  Future<void> _init() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      updateLocation(
          latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      // fallback to Seattle coordinates
      updateLocation(latitude: 47.6062, longitude: -122.3321);
    }
  }

  /// Updates the weather data and notifies listeners.
  void updateWeather(int newTempFahrenheit, WeatherCondition newCondition) {
    tempInFahrenheit = newTempFahrenheit;
    condition = newCondition;
    hasLoadedWeather = true;
    notifyListeners();
  }

  void updateLocation({required double latitude, required double longitude}) {
    _checker.updateLocation(latitude: latitude, longitude: longitude);
    _checker.fetchAndUpdateCurrentSeattleWeather();
  }
}
