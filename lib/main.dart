import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'agrivista/theme/app_theme.dart';
import 'agrivista/screens/main_navigation_screen.dart';
import 'agrivista/providers/weather_provider.dart';
import 'agrivista/providers/mandi_provider.dart';
import 'agrivista/providers/language_provider.dart';
import 'agrivista/providers/harvest_provider.dart';
import 'agrivista/providers/market_recommendation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for low-end Android devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AgriVistaApp());
}

class AgriVistaApp extends StatelessWidget {
  const AgriVistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MandiProvider()),
        ChangeNotifierProvider(create: (_) => HarvestProvider()),
        ChangeNotifierProvider(create: (_) => MarketRecommendationProvider()),
      ],
      child: MaterialApp(
        title: 'Agri Vista – Krishi Mitra AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
