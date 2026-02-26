import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'agrivista/theme/app_theme.dart';
import 'agrivista/screens/main_navigation_screen.dart';
import 'agrivista/providers/weather_provider.dart';

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
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: MaterialApp(
        title: 'Agri Vista – Krishi Mitra AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
