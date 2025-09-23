import 'package:flutter/material.dart';
import 'screen/home.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
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
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/scan': (context) => const ScanPage(),
      },
    );
  }
}

// ...existing code...

