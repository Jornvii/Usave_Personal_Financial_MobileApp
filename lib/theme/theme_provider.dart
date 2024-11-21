import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isLightTheme = true;

  void toggleTheme() {
    isLightTheme = !isLightTheme;
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black), // Main text in light theme
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.cyan[700], // Sea blue
      scaffoldBackgroundColor: Colors.cyan[900], // Darker sea blue
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.yellow), // Main text in dark theme
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// class ThemeProvider extends ChangeNotifier {
//   bool isLightTheme = true;

//   void toggleTheme() {
//     isLightTheme = !isLightTheme;
//     notifyListeners();
//   }
// }
