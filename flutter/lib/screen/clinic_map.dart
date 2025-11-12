import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // تحميل ملف .env قبل التشغيل
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Oral Diagnosis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), 
      darkTheme: ThemeData.dark(), 
      themeMode: ThemeMode.system,   
      initialRoute: '/map',
      routes: {
        '/home': (context) => const HomePage(),
        '/map': (context) => const ClinicMap(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/map');
          },
          child: const Text('Open Clinic Map'),
        ),
      ),
    );
  }
}

class ClinicMap extends StatelessWidget {
  const ClinicMap({super.key});

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['FLUTTER_PUBLIC_STADIAMAPS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('⚠️ Warning: StadiaMaps API key is missing from .env');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        backgroundColor: Colors.green,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(30.0444, 31.2357),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key=$apiKey",
            userAgentPackageName: 'com.example.smart_oral_diagnosis',
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '© Stadia Maps, © OpenMapTiles, © OpenStreetMap contributors',
                onTap: () => launchUrl(
                  Uri.parse('https://stadiamaps.com/attributions/'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
