import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

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

class ClinicMap extends StatefulWidget {
  const ClinicMap({super.key});

  @override
  State<ClinicMap> createState() => _ClinicMapState();
}

class _ClinicMapState extends State<ClinicMap> {
  final MapController _mapController = MapController();

  Future<void> _goToMyLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them in settings.'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please grant permission to use this feature.'),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission permanently denied. Please enable in app settings.'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Getting your location...')),
      );

      // Get current position with timeout
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ).catchError((error) {
        debugPrint('Location timeout or error: $error');
        throw 'Unable to get accurate location. Please try again.';
      });

      final latLng = LatLng(pos.latitude, pos.longitude);

      // Move the map to user's location with smooth animation
      _mapController.move(latLng, 16.0);

      // Hide loading and show success
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location found!'),
          duration: Duration(seconds: 2),
        ),
      );

    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to get current location: ${e.toString()}'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
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

          // Left-bottom locate button
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'locate_me',
              mini: true,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}