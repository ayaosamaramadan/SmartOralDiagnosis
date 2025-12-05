import 'package:flutter/foundation.dart';

class Api {
  // Choose the backend base URL depending on platform.
  // - On Flutter Web we expect the backend to be reachable at localhost:52552
  // - On mobile/emulator we use Android emulator host mapping 10.0.2.2:5000
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:52552';
    return 'http://10.0.2.2:5000';
  }
}
