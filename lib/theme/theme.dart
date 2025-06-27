import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF1A1A16),
  colorScheme: ColorScheme.light(
    primary: Color.fromARGB(26, 255, 255, 255),
    secondary: Colors.white30,
    surface: const Color.fromARGB(255, 161, 161, 161),
    onPrimary: Colors.white70,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFFFAFAFA),
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(31, 0, 0, 0),
    secondary: Colors.black,
    surface: Colors.black38,
    onPrimary: Colors.black38,
  ),
);
