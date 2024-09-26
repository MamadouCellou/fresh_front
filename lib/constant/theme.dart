import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey[900],
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.blueGrey[800],
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
    ),

    iconTheme: const IconThemeData(color: Colors.white),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[200],
    scaffoldBackgroundColor: Colors.grey[100],
    cardColor: Colors.white,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
    ),
   
    iconTheme: const IconThemeData(color: Colors.black),
  );
}
