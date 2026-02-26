import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../theme/app_colors.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  bool _isLoading = false;
  bool _is12HourFormat = false;
  String? _errorMessage;
  _WeatherData? _weatherData;

  @override
  void initState() {
    super.initState();
    _cityController.text = 'Nagpur';
    _fetchWeather('Nagpur');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String city) async {
    final query = city.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

      final weatherJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
      final current = weatherJson['current'] as Map<String, dynamic>;
      final daily = weatherJson['daily'] as Map<String, dynamic>;
      final hourly = weatherJson['hourly'] as Map<String, dynamic>;

      final hourlyTimes = (hourly['time'] as List<dynamic>).cast<String>();
      final hourlyTemps = (hourly['temperature_2m'] as List<dynamic>).cast<num>();

      final now = DateTime.now();
      var startIndex = hourlyTimes.indexWhere((time) {
        final t = DateTime.tryParse(time);
        return t != null && !t.isBefore(now);
      });
      if (startIndex < 0) startIndex = 0;

      final hourlyForecast = <_HourlyForecast>[];
      for (var i = startIndex;
          i < hourlyTimes.length && hourlyForecast.length < 8;
          i++) {
        final parsedTime = DateTime.tryParse(hourlyTimes[i]);
        if (parsedTime == null) continue;
        hourlyForecast.add(
          _HourlyForecast(
            time: parsedTime,
            temperature: hourlyTemps[i].toDouble(),
          ),
        );
      }

      final data = _WeatherData(
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
        description: _mapWeatherCode(
          (current['weather_code'] as num?)?.toInt() ?? 0,
        ),
        hourly: hourlyForecast,
      );

      if (!mounted) return;
      setState(() {
        _weatherData = data;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Unable to fetch weather';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weatherData;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        'Akash Weather',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _fetchWeather('Nagpur'),
                      icon: const Icon(Icons.my_location_rounded),
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSearchBar(),
                const SizedBox(height: 14),
                _buildWeatherCard(weather),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _cityController,
        style: GoogleFonts.poppins(color: Colors.white),
        textInputAction: TextInputAction.search,
        onSubmitted: _fetchWeather,
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.78),
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
          suffixIcon: IconButton(
            onPressed: () => _fetchWeather(_cityController.text),
            icon: const Icon(Icons.send_rounded, color: Colors.white),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(_WeatherData? weather) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (weather != null) ...[
            Text(
              '${weather.city}, ${weather.countryCode}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(weather.date),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${weather.temperature.round()}°c',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 60,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                height: 1,
              ),
            ),
            Text(
              weather.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MetricCard(
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: '${weather.windKmh.round()} km/h',
                ),
                _MetricCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
                _MetricCard(
                  icon: Icons.thermostat_rounded,
                  label: 'High',
                  value: '${weather.high.round()}°c',
                ),
                _MetricCard(
                  icon: Icons.compress_rounded,
                  label: 'Low',
                  value: '${weather.low.round()}°c',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Hourly Forecast',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() => _is12HourFormat = !_is12HourFormat);
                  },
                  child: Text(
                    _is12HourFormat ? '12h' : '24h',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weather.hourly.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final h = weather.hourly[index];
                  return Container(
                    width: 84,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatHour(h.time),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${h.temperature.round()}°',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekday = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dayName = weekday[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName ${date.day} $monthName ${date.year}';
  }

  String _formatHour(DateTime date) {
    if (_is12HourFormat) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final suffix = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour $suffix';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    return '$hour:00';
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mintGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherData {
  final String city;
  final String countryCode;
  final DateTime date;
  final double temperature;
  final int humidity;
  final double windKmh;
  final double high;
  final double low;
  final String description;
  final List<_HourlyForecast> hourly;

  const _WeatherData({
    required this.city,
    required this.countryCode,
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.windKmh,
    required this.high,
    required this.low,
    required this.description,
    required this.hourly,
  });
}

class _HourlyForecast {
  final DateTime time;
  final double temperature;

  const _HourlyForecast({required this.time, required this.temperature});
}

String _mapWeatherCode(int code) {
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
