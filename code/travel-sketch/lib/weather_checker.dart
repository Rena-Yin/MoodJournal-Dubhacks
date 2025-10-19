import 'dart:convert';
import 'package:food_finder/providers/weather_provider.dart';
import 'package:http/http.dart' as http;
import 'package:food_finder/weather_conditions.dart';

/// A service that fetches and processes weather data for a given location.
/// Features:
/// - Fetches current weather data from the National Weather Service API
/// - Converts weather forecasts to simplified conditions
/// - Updates weather information through a provider
class WeatherChecker {
  // Provider that manages and exposes weather state
  final WeatherProvider weatherProvider;

  // Current latitude of the location to check weather for
  double? _latitude;

  // Current longitude of the location to check weather for
  double? _longitude;

  // HTTP client for making API requests
  http.Client? client;

  /// Creates a new WeatherChecker instance.
  /// Parameters:
  ///   - weatherProvider: The provider to update with weather information
  ///   - client: Optional HTTP client for making API requests
  WeatherChecker(this.weatherProvider, {this.client});

  /// Fetches current weather data for the set location and updates the weather provider.
  /// This method:
  /// - Gets the forecast grid for the location
  /// - Retrieves the current weather forecast
  /// - Updates the weather provider with temperature and conditions
  /// - Handles errors by setting weather to unknown
  Future<void> fetchAndUpdateCurrentSeattleWeather() async {
    try {
      final http.Client client = this.client ?? http.Client();
      final gridResponse = await client.get(
          Uri.parse('https://api.weather.gov/points/$_latitude,$_longitude'));
      final gridParsed = (jsonDecode(gridResponse.body));
      final String? forecastURL = gridParsed['properties']?['forecast'];
      if (forecastURL == null) {
        // do nothing
      } else {
        final weatherResponse = await client.get(Uri.parse(forecastURL));
        final weatherParsed = jsonDecode(weatherResponse.body);
        final currentPeriod = weatherParsed['properties']?['periods']?[0];
        if (currentPeriod != null) {
          final temperature = currentPeriod['temperature'];
          final shortForecast = currentPeriod['shortForecast'];
          // ignore: avoid_print
          print(
              'Got the weather at ${DateTime.now()}. $temperature F and $shortForecast');
          if (temperature != null && shortForecast != null) {
            final condition = _shortForecastToCondition(shortForecast);
            weatherProvider.updateWeather(temperature, condition);
          }
        }
      }
    } catch (_) {
      // ignore: avoid_print
      print('Unable to fetch weather');
      weatherProvider.updateWeather(0, WeatherCondition.unknown);
    } finally {
      client?.close();
      client = null;
    }
  }

  /// Converts a short forecast string to a WeatherCondition enum.
  /// Parameters:
  ///   - shortForecast: The weather forecast string from the API
  /// Returns: A WeatherCondition enum value based on the forecast
  WeatherCondition _shortForecastToCondition(String shortForecast) {
    final lowercased = shortForecast.toLowerCase();
    if (lowercased.startsWith('rain')) return WeatherCondition.rainy;
    if (lowercased.startsWith('sun') || lowercased.startsWith('partly')) {
      return WeatherCondition.sunny;
    }
    return WeatherCondition.gloomy;
  }

  /// Updates the location coordinates for weather checking.
  /// Parameters:
  ///   - latitude: The new latitude coordinate
  ///   - longitude: The new longitude coordinate
  void updateLocation({required double latitude, required double longitude}) {
    _latitude = latitude;
    _longitude = longitude;
  }
}
