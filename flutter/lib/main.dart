import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/home.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
import 'screen/scan.dart';
import 'screen/chat.dart';
import 'screen/disease_detail.dart';
import 'screen/Alldisease.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, themeMode, _) {
        // Use centralized theme builders which include AppColors extension.
        final lightTheme = buildLightTheme().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
          useMaterial3: true,
        );

        final darkTheme = buildDarkTheme().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
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
      },
    );
  }
}