import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../components/theme_toggle.dart';

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
      routes: {'/map': (context) => const ClinicMap()},
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
  bool _satelliteView = false;
  Position? _userPosition;

  // Simple in-file sample clinics (replace with your data source if available)
  final List<Map<String, dynamic>> _clinics = [
      { "id": 'c1', "name": 'Al Noor Oral Clinic', "lat": 30.046, "lng": 31.233, "address": 'Downtown' },
    { "id": 'c2', "name": 'Smiles Teeth Center', "lat": 30.042, "lng": 31.240, "address": 'Zamalek' },

    // Cairo
    { "id": 'c3', "name": 'Cairo Dental Care', "lat": 30.0444, "lng": 31.2357, "address": 'Tahrir' },
    { "id": 'c4', "name": 'Zamalek Dental Studio', "lat": 30.0636, "lng": 31.2169, "address": 'Zamalek' },
    { "id": 'c5', "name": 'Maadi Smile Center', "lat": 29.9753, "lng": 31.2809, "address": 'Maadi' },
    { "id": 'c6', "name": 'Heliopolis Dental Clinic', "lat": 30.0822, "lng": 31.3251, "address": 'Heliopolis' },
    { "id": 'c7', "name": 'Nasr City Dental Care', "lat": 30.0459, "lng": 31.2850, "address": 'Nasr City' },

    // Giza & 6th October
    { "id": 'c8', "name": 'Giza Family Dental', "lat": 30.0131, "lng": 31.2089, "address": 'Giza' },
    { "id": 'c9', "name": '6th October Dental Center', "lat": 29.9417, "lng": 30.9175, "address": '6th of October' },

    // Alexandria
    { "id": 'c10', "name": 'Alexandria Dental Hospital', "lat": 31.2001, "lng": 29.9187, "address": 'Alexandria Corniche' },
    { "id": 'c11', "name": 'Sidi Gaber Smile Clinic', "lat": 31.2106, "lng": 29.9154, "address": 'Sidi Gaber' },

    // Delta & Canal cities
    { "id": 'c12', "name": 'Mansoura Dental Center', "lat": 31.0446, "lng": 31.3785, "address": 'Mansoura' },
    { "id": 'c13', "name": 'Tanta Family Dental', "lat": 30.7865, "lng": 31.0004, "address": 'Tanta' },
    { "id": 'c14', "name": 'Zagazig Dental Clinic', "lat": 30.5876, "lng": 31.5029, "address": 'Zagazig' },
    { "id": 'c15', "name": 'Banha Smile Studio', "lat": 30.4680, "lng": 31.1848, "address": 'Banha' },

    // Suez Canal & Port cities
    { "id": 'c16', "name": 'Suez Dental Care', "lat": 29.9668, "lng": 32.5498, "address": 'Suez' },
    { "id": 'c17', "name": 'Port Said Dental Center', "lat": 31.2653, "lng": 32.3019, "address": 'Port Said' },
    { "id": 'c18', "name": 'Ismailia Family Dentistry', "lat": 30.5965, "lng": 32.2715, "address": 'Ismailia' },

    // Red Sea & Sinai
    { "id": 'c19', "name": 'Hurghada Dental Clinic', "lat": 27.2579, "lng": 33.8116, "address": 'Hurghada' },
    { "id": 'c20', "name": 'Sharm El Sheikh Dental', "lat": 27.9158, "lng": 34.3299, "address": 'Sharm El Sheikh' },

    // Upper Egypt
    { "id": 'c21', "name": 'Luxor Dental Center', "lat": 25.6872, "lng": 32.6396, "address": 'Luxor' },
    { "id": 'c22', "name": 'Aswan Smile Clinic', "lat": 24.0889, "lng": 32.8998, "address": 'Aswan' },

    // Other governorates
    { "id": 'c23', "name": 'Fayoum Dental Care', "lat": 29.3104, "lng": 30.8418, "address": 'Fayoum' },
    { "id": 'c24', "name": 'Damanhur Dental Studio', "lat": 31.0364, "lng": 30.4685, "address": 'Damanhur' },
    { "id": 'c25', "name": 'Kafr El Sheikh Dental', "lat": 31.1089, "lng": 30.9390, "address": 'Kafr El Sheikh' },

  ];

  Future<void> _goToMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable them in settings.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission denied. Please grant permission to use this feature.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permission permanently denied. Please enable in app settings.',
            ),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Getting your location...')));

      final Position pos =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          ).catchError((error) {
            debugPrint('Location timeout or error: $error');
            throw 'Unable to get accurate location. Please try again.';
          });

      final latLng = LatLng(pos.latitude, pos.longitude);

      // store user position and move the map to user's location with smooth animation
      setState(() {
        _userPosition = pos;
      });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [ThemeToggle()],
        elevation: 0,
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
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final hasStadia = apiKey != null && apiKey.isNotEmpty;

                  String tileUrl;
                  List<String> tileSubdomains = const [];
                  Map<String, String> additional = {};
                  String attribution = '© OpenStreetMap contributors';

                  if (_satelliteView) {
                    // Satellite view: Stadia satellite when key available, else Esri World Imagery
                    if (hasStadia) {
                      tileUrl =
                          'https://tiles.stadiamaps.com/tiles/alidade_satellite/{z}/{x}/{y}.jpg?api_key={apiKey}';
                      additional = {'apiKey': apiKey};
                      tileSubdomains = const [];
                      attribution = '© Stadia Maps';
                    } else {
                      tileUrl =
                          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
                      tileSubdomains = const [];
                      attribution = 'Tiles © Esri';
                    }
                  }

                  // Prefer a dark basemap when the device/app is in dark mode
                  else if (isDark) {
                    // Dark-mode tiles: CartoDB Dark Matter (no API key required)
                    tileUrl =
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
                    tileSubdomains = const ['a', 'b', 'c', 'd'];
                    attribution = '© CARTO, © OpenStreetMap contributors';
                  }

                  // If not dark and Stadia is available prefer Stadia smooth tiles when API key is present
                  else if (hasStadia) {
                    tileUrl =
                        'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key={apiKey}';
                    additional = {'apiKey': apiKey};
                    tileSubdomains = const [];
                    attribution =
                        '© Stadia Maps, © OpenMapTiles, © OpenStreetMap contributors';
                  } else {
                    // Light: OpenStreetMap standard tiles (no API key)
                    tileUrl =
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
                    tileSubdomains = const ['a', 'b', 'c'];
                    attribution = '© OpenStreetMap contributors';
                  }

                  return TileLayer(
                    urlTemplate: tileUrl,
                    additionalOptions: additional,
                    userAgentPackageName: 'com.example.smart_oral_diagnosis',
                    subdomains: tileSubdomains,
                  );
                },
              ),

              // Attribution adapts to the chosen provider
              Builder(
                builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final hasStadia = apiKey != null && apiKey.isNotEmpty;
                  final attributionText = _satelliteView
                      ? (hasStadia ? '© Stadia Maps' : 'Tiles © Esri')
                      : (hasStadia
                            ? '© Stadia Maps, © OpenMapTiles, © OpenStreetMap contributors'
                            : (isDark
                                  ? '© CARTO, © OpenStreetMap contributors'
                                  : '© OpenStreetMap contributors'));
                  final attributionUrl = _satelliteView
                      ? (hasStadia
                            ? 'https://stadiamaps.com/attributions/'
                            : 'https://www.esri.com')
                      : (hasStadia
                            ? 'https://stadiamaps.com/attributions/'
                            : (isDark
                                  ? 'https://carto.com/attributions/'
                                  : 'https://www.openstreetmap.org/copyright'));

                  return RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        attributionText,
                        onTap: () => launchUrl(Uri.parse(attributionUrl)),
                      ),
                    ],
                  );
                },
              ),

              // Markers for sample clinics (use a contrasting color in dark mode)
              Builder(builder: (ctx) {
                final isDarkMarker = Theme.of(ctx).brightness == Brightness.dark;
                final markerColor = isDarkMarker ? Colors.white : Theme.of(ctx).colorScheme.primary;

                return MarkerLayer(
                  markers: _clinics.map((c) {
                    final lat = c['lat'] as double;
                    final lng = c['lng'] as double;

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _mapController.move(LatLng(lat, lng), 15.0);
                          ScaffoldMessenger.of(
                            ctx,
                          ).showSnackBar(SnackBar(content: Text('${c['name']}')));
                        },
                        child: Icon(
                          Icons.location_on,
                          color: markerColor,
                          size: 36,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              // User location marker (if available)
              if (_userPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _userPosition!.latitude,
                        _userPosition!.longitude,
                      ),
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blueAccent,
                        size: 36,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Left-bottom locate button
          // Left-bottom satellite toggle (above locate)
          Positioned(
            left: 16,
            bottom: 84,
            child: FloatingActionButton(
              heroTag: 'sat_toggle',
              mini: true,
              backgroundColor: _satelliteView ? Colors.indigo : null,
              onPressed: () {
                setState(() => _satelliteView = !_satelliteView);
              },
              child: const Icon(Icons.satellite),
            ),
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
