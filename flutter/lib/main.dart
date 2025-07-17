import 'package:flutter/material.dart';
import 'screen/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Flutter(),
    );
  }
}

class Flutter extends StatefulWidget {
  const Flutter({super.key});

  @override
  _FlutterState createState() => _FlutterState();
}

class _FlutterState extends State<Flutter> {
  // Reusable button style

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
    );
  }
}
