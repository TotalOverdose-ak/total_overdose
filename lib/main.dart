import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'agrivista/theme/app_theme.dart';
import 'agrivista/screens/main_navigation_screen.dart';
import 'agrivista/screens/language_selection_screen.dart';
import 'agrivista/screens/login_screen.dart';
import 'agrivista/providers/weather_provider.dart';
import 'agrivista/providers/mandi_provider.dart';
import 'agrivista/providers/language_provider.dart';
import 'agrivista/providers/harvest_provider.dart';
import 'agrivista/providers/market_recommendation_provider.dart';
import 'agrivista/providers/auth_provider.dart';
import 'agrivista/providers/history_provider.dart';

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

  // Initialize auth, language, and history state before app starts
  final authProvider = AuthProvider();
  final langProvider = LanguageProvider();
  final historyProvider = HistoryProvider();
  await Future.wait([
    authProvider.initialize(),
    langProvider.initialize(),
    historyProvider.initialize(),
  ]);

  runApp(
    AgriVistaApp(
      authProvider: authProvider,
      langProvider: langProvider,
      historyProvider: historyProvider,
    ),
  );
}

class AgriVistaApp extends StatelessWidget {
  final AuthProvider authProvider;
  final LanguageProvider langProvider;
  final HistoryProvider historyProvider;

  const AgriVistaApp({
    super.key,
    required this.authProvider,
    required this.langProvider,
    required this.historyProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: langProvider),
        ChangeNotifierProvider.value(value: historyProvider),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => MandiProvider()),
        ChangeNotifierProvider(create: (_) => HarvestProvider()),
        ChangeNotifierProvider(create: (_) => MarketRecommendationProvider()),
      ],
      child: MaterialApp(
        title: 'Agri Vista – Krishi Mitra AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isFirstLaunch) {
              return const LanguageSelectionScreen();
            }
            if (!auth.isLoggedIn) {
              return const LoginScreen();
            }
            return const MainNavigationScreen();
          },
        ),
      ),
    );
  }
}
