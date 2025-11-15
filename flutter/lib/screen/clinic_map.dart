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

  void _openClinicsMenu() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.25,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: clinicPlaces.length,
                    itemBuilder: (cctx, idx) {
                      final clinic = clinicPlaces[idx];
                      return ListTile(
                        title: Text(clinic['name'] ?? ''),
                        subtitle: clinic['address'] != null ? Text(clinic['address']) : null,
                        leading: const Icon(Icons.location_on),
                        onTap: () {
                          Navigator.of(sheetCtx).pop();
                          final lat = clinic['lat'] as double;
                          final lng = clinic['lng'] as double;
                          _mapController.move(LatLng(lat, lng), 15.0);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['FLUTTER_PUBLIC_STADIAMAPS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('Warning: StadiaMaps API key is missing from .env');
    }

    return Scaffold(
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
          // Top-left back button (overlay, not AppBar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                ),
              ),
            ),
          ),

          // Top-right theme toggle (overlay, not AppBar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ThemeToggle(),
              ),
            ),
          ),
  Positioned(
    left: 16,
    bottom: 16,
    child: Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Satellite toggle (top)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _satelliteView
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
                  : Theme.of(context).cardColor.withOpacity(0.96),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Tooltip(
              message: _satelliteView ? 'Satellite view (on)' : 'Satellite view (off)',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _satelliteView = !_satelliteView),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.satellite,
                        size: 20,
                        color: _satelliteView
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Satellite',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Locate me (bottom)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.96),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Tooltip(
              message: 'Go to my location',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _goToMyLocation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Locate',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
          // Centered 'CLINICS' pill button (opens clinics modal)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _openClinicsMenu,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('CLINICS', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
