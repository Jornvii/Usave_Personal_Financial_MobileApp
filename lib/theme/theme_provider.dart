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
        bodyMedium: TextStyle(color: Colors.black), 
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.cyan[700],
      scaffoldBackgroundColor: Colors.cyan[900], 
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87), 
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
