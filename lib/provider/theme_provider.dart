// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool _isDarkTheme = false;

//   bool get isDarkTheme => _isDarkTheme;

//   ThemeData get themeData => _isDarkTheme ? darkTheme : lightTheme;

//   ThemeData get lightTheme => ThemeProvider._lightTheme;
//   ThemeData get darkTheme => ThemeProvider._darkTheme;

//   Future<void> loadTheme() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
//     } catch (e) {
//       _isDarkTheme = false;
//     }
//     notifyListeners();
//   }

//   Future<void> toggleTheme() async {
//     _isDarkTheme = !_isDarkTheme;
//     notifyListeners();
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isDarkTheme', _isDarkTheme);
//     } catch (e) {
//       print(e);
//     }
//   }

//   static const primaryGreen = Color.fromARGB(247, 17, 215, 119);
//   static const lightBackground = Color(0xFFF1F5F2);
//   static const darkBackground = Color.fromARGB(255, 1, 10, 8);

//   static final ThemeData _darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: primaryGreen,
//     scaffoldBackgroundColor: darkBackground,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//       iconTheme: IconThemeData(color: Colors.white),
//     ),
//     textTheme: const TextTheme(
//       bodyLarge: TextStyle(color: Colors.white),
//       bodyMedium: TextStyle(color: Colors.white70),
//       labelMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.white10,
//       hintStyle: const TextStyle(color: Colors.white70),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide.none,
//       ),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Color(0xFF003A2A),
//       selectedItemColor: primaryGreen,
//       unselectedItemColor: Colors.white54,
//     ),
//   );

//   static final ThemeData _lightTheme = ThemeData(
//     brightness: Brightness.light,
//     primaryColor: primaryGreen,
//     scaffoldBackgroundColor: lightBackground,
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//       iconTheme: IconThemeData(color: Colors.black),
//     ),
//     textTheme: const TextTheme(
//       bodyLarge: TextStyle(color: Colors.black),
//       bodyMedium: TextStyle(color: Colors.black54),
//       labelMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: Colors.black12,
//       hintStyle: const TextStyle(color: Colors.black45),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide.none,
//       ),
//     ),
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Color(0xFFE0E0E0),
//       selectedItemColor: primaryGreen,
//       unselectedItemColor: Colors.black54,
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get themeData => _isDarkTheme ? darkTheme : lightTheme;

  ThemeData get lightTheme => ThemeProvider._lightTheme;
  ThemeData get darkTheme => ThemeProvider._darkTheme;

  // Load and toggle theme logic
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    } catch (e) {
      _isDarkTheme = false; // Default to light theme in case of error
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkTheme', _isDarkTheme);
    } catch (e) {
      // Handle error if necessary
    }
  }

  static const primaryGreen = Color(0xFF00B894);
  static const lightBackground = Color(0xFFEAF9F1);
  static const darkBackground = Color.fromARGB(255, 0, 0, 0);
  static const cardLight = Color.fromARGB(255, 180, 246, 190);
  static const cardDark = Color(0xFF1E4633);
  static const accentGreen = Color(0xFF81C784);

  // Updated Themes
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black12,
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    cardTheme: const CardTheme(
      color: cardLight,
      shadowColor: Colors.black12,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.black54),
      labelMedium: TextStyle(
          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Colors.black45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBackground,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.black54,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black38,
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: const CardTheme(
      color: cardDark,
      shadowColor: Colors.black54,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.white70),
      labelMedium: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white10,
      hintStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: accentGreen,
      unselectedItemColor: Colors.white54,
    ),
  );
}












