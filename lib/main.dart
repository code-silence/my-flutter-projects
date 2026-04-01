import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini GF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Jost',   // <-- sets Jost as default font
        brightness: Brightness.dark, // optional: keep dark theme
      ),
      home: HomeScreen(),
    );
  }
}