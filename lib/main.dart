import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:madarsago/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

const Color appPrimaryColor = Color(0xFF297373);
const Color appSecondaryColor = Color(0xFFCA895F);
const Color appAccentColor = Color(0xFFA491D3);
const Color appDarkColor = Color(0xFF121212);
const Color appLightColor = Color(0xFFD0DDD7);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MadarsaGo',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: createMaterialColor(appPrimaryColor),
        primaryColor: appPrimaryColor,
        fontFamily: 'Regular',
        textTheme: TextTheme(
          headlineLarge: const TextStyle(
            color: appDarkColor,
            fontFamily: 'Bold',
          ),
          headlineMedium: const TextStyle(
            color: appDarkColor,
            fontFamily: 'Bold',
          ),
          bodyMedium: TextStyle(
            color: appDarkColor.withAlpha((255 * 0.8).round()),
            fontFamily: 'Regular',
          ),
          bodySmall: TextStyle(
            color: appDarkColor.withAlpha((255 * 0.6).round()),
            fontFamily: 'Regular',
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: appPrimaryColor,
          secondary: appSecondaryColor,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: appDarkColor,
        primarySwatch: createMaterialColor(appPrimaryColor),
        primaryColor: appPrimaryColor,
        fontFamily: 'Regular',
        textTheme: TextTheme(
          headlineLarge: const TextStyle(
            color: appLightColor,
            fontFamily: 'Bold',
          ),
          headlineMedium: const TextStyle(
            color: appLightColor,
            fontFamily: 'Bold',
          ),
          bodyMedium: TextStyle(
            color: appLightColor.withAlpha((255 * 0.8).round()),
            fontFamily: 'Regular',
          ),
          bodySmall: TextStyle(
            color: appLightColor.withAlpha((255 * 0.6).round()),
            fontFamily: 'Regular',
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: appPrimaryColor,
          secondary: appSecondaryColor,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = (color.toARGB32() >> 16) & 0xFF;
  final int g = (color.toARGB32() >> 8) & 0xFF;
  final int b = color.toARGB32() & 0xFF;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.toARGB32(), swatch);
}
