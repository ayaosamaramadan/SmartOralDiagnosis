import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../components/theme_toggle.dart';
import '../data/clinic_places.dart';

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

     setState(() {
        _userPosition = pos;
      });
      _mapController.move(latLng, 16.0);

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

                  else if (isDark) {
                    tileUrl =
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
                    tileSubdomains = const ['a', 'b', 'c', 'd'];
                    attribution = '© CARTO, © OpenStreetMap contributors';
                  }

                  else if (hasStadia) {
                    tileUrl =
                        'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key={apiKey}';
                    additional = {'apiKey': apiKey};
                    tileSubdomains = const [];
                    attribution =
                        '© Stadia Maps, © OpenMapTiles, © OpenStreetMap contributors';
                  } else {
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

               Builder(builder: (ctx) {
                final isDarkMarker = Theme.of(ctx).brightness == Brightness.dark;
                final markerColor = isDarkMarker ? Colors.white : Theme.of(ctx).colorScheme.primary;

                return MarkerLayer(
                  markers: clinicPlaces.map((c) {
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
