import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double logoSize = 100; // Start small
  double opacity = 0; // Start invisible

  @override
  void initState() {
    super.initState();

    // Animate logo size
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        logoSize = 200; // Expand
        opacity = 1; // Fade-in text
      });
    });

    // Navigate after splash
    Future.delayed(Duration(milliseconds: 3000), () {
      Navigator.of(context).pushReplacementNamed('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(seconds: 1),
              curve: Curves.easeOutBack, // Smooth elastic effect
              height: logoSize,
              width: logoSize,
              child: Image.asset("asset/logo/logo.png", fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            AnimatedOpacity(
              duration: Duration(seconds: 1),
              opacity: opacity,
              child: Column(
                children: [
                  Text(
                    "Potato Disease Detector",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Text(
                      "Ziad Henedy Graduation Project",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}