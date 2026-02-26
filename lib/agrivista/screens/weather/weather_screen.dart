import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _is12HourFormat = false;

  @override
  void initState() {
    super.initState();
    final wp = context.read<WeatherProvider>();
    _cityController.text = wp.currentCity;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchCity(String city) {
    final query = city.trim();
    if (query.isEmpty) return;
    context.read<WeatherProvider>().fetchWeather(query);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, wp, _) {
        final weather = wp.weatherData;
        final isLoading = wp.isLoading;
        final errorMessage = wp.errorMessage;

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
                          onPressed: () {
                            _cityController.text = 'Nagpur';
                            _searchCity('Nagpur');
                          },
                          icon: const Icon(Icons.my_location_rounded),
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildWeatherCard(weather, isLoading, errorMessage),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        onSubmitted: _searchCity,
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.78),
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
          suffixIcon: IconButton(
            onPressed: () => _searchCity(_cityController.text),
            icon: const Icon(Icons.send_rounded, color: Colors.white),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
    WeatherData? weather,
    bool isLoading,
    String? errorMessage,
  ) {
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
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Text(
                errorMessage,
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
                separatorBuilder: (_, __) => const SizedBox(width: 10),
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
