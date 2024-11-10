import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.pinkAccent,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: Colors.pinkAccent,
        secondary: Colors.pink,
        background: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.pinkAccent,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.2),
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.pink[700],
      scaffoldBackgroundColor: Color(0xFF121212), // Color de fondo oscuro estándar
      colorScheme: ColorScheme.dark(
        primary: Colors.pink[700]!,
        secondary: Colors.pink[500]!,
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink[300]),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[700],
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      cardTheme: CardTheme(
        color: Color(0xFF1E1E1E),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),
    );
  }
}