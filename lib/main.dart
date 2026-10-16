import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suga/app/theme.dart';
import 'package:suga/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const SugaApp());
}

class SugaApp extends StatelessWidget {
  const SugaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suga',
      debugShowCheckedModeBanner: false,
      theme: buildSugaTheme(),
      home: const HomeScreen(),
    );
  }
}
