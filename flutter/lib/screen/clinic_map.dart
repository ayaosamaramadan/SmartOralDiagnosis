import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 
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
      initialRoute: '/home',
      routes: { 
        '/map': (context) => const ClinicMap(),
      },
    );
  }
}

class ClinicMap extends StatelessWidget {
  const ClinicMap({super.key});

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['FLUTTER_PUBLIC_STADIAMAPS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('Warning: StadiaMaps API key is missing from .env');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Map'),
        backgroundColor: const Color.fromARGB(255, 29, 95, 208),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(30.0444, 31.2357),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key={apiKey}",
            additionalOptions: {
              'apiKey': apiKey ?? '',
            },
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