import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Oral Diagnosis '),
        backgroundColor: const Color.fromARGB(255, 209, 127, 188),
          centerTitle: true),
    );
  }
}
