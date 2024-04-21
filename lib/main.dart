import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:suga/widgets/home_page.dart';

void main() => runApp(NoiseMeterApp());

class NoiseMeterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: AnimatedSplashScreen(
      splash: ClipOval(
        child: Image.asset(
          'assets/images/suga-logo.jpeg',
          fit: BoxFit.cover,
        ),
      ),
      nextScreen: const HomePage(),
    ));
  }
}
