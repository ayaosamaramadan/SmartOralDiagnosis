import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screen/home.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screen/login.dart';
import 'screen/signup.dart';
import 'screen/scan.dart';
import 'screen/chat.dart';
import 'screen/loading_screen.dart';
import 'screen/disease_detail.dart';
import 'screen/clinic_map.dart';
import 'screen/Alldisease.dart';
import 'screen/edit_profile.dart';
import 'screen/doctors.dart';
import 'screen/doctor_detail.dart';
import 'screen/doctor_chat_page.dart';
import 'screen/appointments_screen.dart';
import 'screen/appointment_details_screen.dart';
import 'screen/book_appointment_screen.dart';
import 'services/role_service.dart';
import 'models/doctor.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('.env file loaded successfully');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }
  
  try {
    await ThemeService.init();
  } catch (e) {
    debugPrint('Theme initialization failed: $e');
  }
  try {
    await RoleService.init();
  } catch (e) {
    debugPrint('RoleService init failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.notifier,
      builder: (context, themeMode, _) {
        final lightTheme = buildLightTheme().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.light(useMaterial3: true).textTheme,
          ),
        );

        final darkTheme = buildDarkTheme().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark(useMaterial3: true).textTheme,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const LoadingScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/scan': (context) => const ScanPage(),
            '/chat': (context) => const ChatScreen(),
            '/loading': (context) => const LoadingScreen(),
            '/Alldisease': (context) => const AlldiseaseScreen(),
            '/map': (context) => const ClinicMap(), 
            '/editProfile': (context) => const EditProfileScreen(),
            '/doctors': (context) => const DoctorsScreen(),
            '/doctorChat': (context) => const DoctorChatPage(),
            '/appointments': (context) => const AppointmentsScreen(),
            '/appointments-details': (context) {
              final appointmentId = ModalRoute.of(context)!.settings.arguments as String;
              return AppointmentDetailsScreen(appointmentId: appointmentId);
            },
            '/book-appointment': (context) {
              final doctor = ModalRoute.of(context)!.settings.arguments as Doctor;
              return BookAppointmentScreen(doctor: doctor);
            },
            '/doctorDetail': (context) {
              final doctor = ModalRoute.of(context)!.settings.arguments as Doctor;
              return DoctorDetailScreen(doctor: doctor);
            },
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