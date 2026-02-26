import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final String countryCode;
  final DateTime date;
  final double temperature;
  final int humidity;
  final double windKmh;
  final double high;
  final double low;
  final String description;
  final int weatherCode;
  final List<HourlyForecast> hourly;

  const WeatherData({
    required this.city,
    required this.countryCode,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.windKmh,
    required this.high,
    required this.low,
    required this.description,
    required this.weatherCode,
    required this.hourly,
  });

  String get iconEmoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode >= 1 && weatherCode <= 3) return '⛅';
    if (weatherCode == 45 || weatherCode == 48) return '🌫️';
    if (weatherCode >= 51 && weatherCode <= 57) return '🌦️';
    if (weatherCode >= 61 && weatherCode <= 67) return '🌧️';
    if (weatherCode >= 71 && weatherCode <= 77) return '❄️';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧️';
    if (weatherCode >= 95) return '⛈️';
    return '🌤️';
  }

  String get rainForecast {
    if (weatherCode >= 51 && weatherCode <= 67) return '🌧 Rain today';
    if (weatherCode >= 80 && weatherCode <= 82) return '🌧 Showers expected';
    if (weatherCode >= 95) return '⛈ Thunderstorm alert';
    return '☀️ No rain expected soon';
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;

  const HourlyForecast({required this.time, required this.temperature});
}

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCity = 'Nagpur';

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;

  WeatherProvider() {
    fetchWeather('Nagpur');
  }

  Future<void> fetchWeather(String city) async {
    final query = city.trim();
    if (query.isEmpty) return;

    _currentCity = query;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Geocoding
      final geoUri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
        'name': query,
        'count': '1',
        'language': 'en',
        'format': 'json',
      });

      final geoResponse = await http.get(geoUri);
      if (geoResponse.statusCode != 200) {
        throw Exception('City lookup failed');
      }

      final geoJson = jsonDecode(geoResponse.body) as Map<String, dynamic>;
      final results = (geoJson['results'] as List<dynamic>?) ?? [];
      if (results.isEmpty) {
        throw Exception('City not found');
      }

      final first = results.first as Map<String, dynamic>;
      final lat = (first['latitude'] as num).toDouble();
      final lon = (first['longitude'] as num).toDouble();
      final cityName = (first['name'] as String?) ?? query;
      final countryCode = (first['country_code'] as String?) ?? '';

      // Weather
      final weatherUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '$lat',
        'longitude': '$lon',
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code',
        'daily': 'temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '2',
      });

      final weatherResponse = await http.get(weatherUri);
      if (weatherResponse.statusCode != 200) {
        throw Exception('Weather API error');
      }

      final weatherJson =
          jsonDecode(weatherResponse.body) as Map<String, dynamic>;
      final current = weatherJson['current'] as Map<String, dynamic>;
      final daily = weatherJson['daily'] as Map<String, dynamic>;
      final hourly = weatherJson['hourly'] as Map<String, dynamic>;

      final hourlyTimes = (hourly['time'] as List<dynamic>).cast<String>();
      final hourlyTemps = (hourly['temperature_2m'] as List<dynamic>)
          .cast<num>();

      final now = DateTime.now();
      var startIndex = hourlyTimes.indexWhere((time) {
        final t = DateTime.tryParse(time);
        return t != null && !t.isBefore(now);
      });
      if (startIndex < 0) startIndex = 0;

      final hourlyForecast = <HourlyForecast>[];
      for (
        var i = startIndex;
        i < hourlyTimes.length && hourlyForecast.length < 8;
        i++
      ) {
        final parsedTime = DateTime.tryParse(hourlyTimes[i]);
        if (parsedTime == null) continue;
        hourlyForecast.add(
          HourlyForecast(
            time: parsedTime,
            temperature: hourlyTemps[i].toDouble(),
          ),
        );
      }

      final wCode = (current['weather_code'] as num?)?.toInt() ?? 0;

      _weatherData = WeatherData(
        city: cityName,
        countryCode: countryCode,
        date: DateTime.now(),
        temperature: (current['temperature_2m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windKmh: (current['wind_speed_10m'] as num).toDouble(),
        high: ((daily['temperature_2m_max'] as List<dynamic>).first as num)
            .toDouble(),
        low: ((daily['temperature_2m_min'] as List<dynamic>).first as num)
            .toDouble(),
        description: _mapWeatherCode(wCode),
        weatherCode: wCode,
        hourly: hourlyForecast,
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Unable to fetch weather';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _mapWeatherCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1 || code == 2 || code == 3) return 'Partly Cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if (code >= 61 && code <= 67) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain Showers';
    if (code >= 95) return 'Thunderstorm';
    return 'Weather Update';
  }
}
