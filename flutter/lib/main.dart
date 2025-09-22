import 'package:flutter/material.dart';
import 'screen/home.dart';
import 'screen/login.dart';
import 'screen/scan.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/scan': (context) => const ScanPage(),
      },
    );
  }
}

// ...existing code...
