import 'package:flutter/material.dart';

class AppTheme {
  // Definicja kolorów
  static const Color DeepNavy = Color(0xFF05367B);
  static const Color TurquoiseLagoon = Color(0xFF40A4D5);
  static const Color SunnySand = Color(0xFFE1B07E);
  static const Color CaramelGlow = Color(0xFFE5BE9E);
  static const Color DesertBeige = Color(0xFFCBC0AD);
  static const Color ErrorRed = Color(0xFFD32F2F);
  //new one
  static const Color main = Color(0xff05367b);
  static const Color secondary = Color(0xff1F2224);
  static const Color onSecondary = Color.fromRGBO(0, 110, 255, 1);
  static const Color accent = Color(0xff035353);

  // Metoda, która tworzy ThemeData dla aplikacji
  static ThemeData get theme {
    return ThemeData(
      primaryColor: Colors.white,
      colorScheme: ColorScheme(
        primary: const Color.fromARGB(255, 255, 255, 255),
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: main,
        onSurface: Colors.white,
        error: ErrorRed,
        onError: const Color.fromARGB(255, 0, 0, 0),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: DesertBeige,
      appBarTheme: AppBarTheme(
        color: DeepNavy,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: CaramelGlow,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        titleSmall: TextStyle(color: DeepNavy),
        titleMedium: TextStyle(color: DeepNavy),
        titleLarge: TextStyle(color: DeepNavy, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TurquoiseLagoon),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: DeepNavy),
        ),
        labelStyle: TextStyle(color: DeepNavy),
      ),
    );
  }
}
