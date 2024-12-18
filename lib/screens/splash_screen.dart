import 'package:flutter/material.dart';
import 'package:flutter_chat_bot/main.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      // MaterialPageRoute(builder: (context) => const MainScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/images/Animation.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                animationFadeText(
                  "iSave",
                  50,
                  const Color.fromARGB(255, 17, 215, 119),
                  FontWeight.bold
                ),
                animationFadeText(
                    "Your Personal Financail Management App", 18, Colors.black,FontWeight.w500)
              ],
            ),
          ],
        ),
      ),
    );
  }

  FadeTransition animationFadeText(
      String animatedtxt, double sizetxt, Color colorstxt,FontWeight weighttxt) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        animatedtxt,
        style: TextStyle(
          fontSize: sizetxt,
          fontWeight: weighttxt,
          color: colorstxt,
          // color:  Color.fromARGB(255, 17, 215, 119),
        ),
      ),
    );
  }
}
