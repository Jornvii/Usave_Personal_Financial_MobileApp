import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkTheme = false; // Default to light theme

  // Light Theme
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.lightBlue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.lightBlue,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.lightBlue,
      secondary: Colors.green,
      error: Colors.red,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      color: Colors.black,
      iconTheme: IconThemeData(color: Colors.lightBlue),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.lightBlue,
      secondary: Colors.green,
      error: Colors.red,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
  );

  ThemeData get themeData => isDarkTheme ? darkTheme : lightTheme;

  // Load theme preference from local storage
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDarkTheme') ?? false; 
    notifyListeners();
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkTheme); // Save preference
  }
}
