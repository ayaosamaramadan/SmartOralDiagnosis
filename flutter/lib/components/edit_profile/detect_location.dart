import 'package:flutter/material.dart';

class DetectLocation extends StatefulWidget {
  final void Function(String location)? onDetected;

  const DetectLocation({super.key, this.onDetected});

  @override
  State<DetectLocation> createState() => _DetectLocationState();
}

class _DetectLocationState extends State<DetectLocation> {
  bool _loading = false;

  // Placeholder: replace with geolocator or map service if desired
  Future<void> _detect() async {
    setState(() => _loading = true);
    await Future.delayed(Duration(seconds: 1));
    final detected = 'Detected Location (lat: 24.7136, lon: 46.6753)';
    widget.onDetected?.call(detected);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _detect,
      icon: Icon(Icons.my_location),
      label: Text(_loading ? 'Locating...' : 'Detect'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
