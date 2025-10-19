import 'package:flutter/material.dart';
import 'screen/home.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
import 'screen/scan.dart';
import 'screen/chat.dart';
import 'screen/disease_detail.dart';
import 'screen/Alldisease.dart';
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
        '/chat': (context) => const ChatScreen(),
        '/Alldisease': (context) => const AlldiseaseScreen(),
        '/diseaseDetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DiseaseDetailScreen(item: args);
        },


      },
    );
  }
}

