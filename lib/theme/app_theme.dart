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
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pinkAccent), // headline1
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87), // bodyText1
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.pinkAccent,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent, // Cambié primary a backgroundColor
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
}
