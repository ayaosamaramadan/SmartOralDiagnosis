import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static String _readEnv(String key) {
    final raw = dotenv.env[key]?.trim() ?? '';
    if (raw.length >= 2) {
      final first = raw[0];
      final last = raw[raw.length - 1];
      if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
        return raw.substring(1, raw.length - 1).trim();
      }
    }
    return raw;
  }

  static String _withDefaultScheme(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'http://$value';
  }

  // Choose the backend base URL depending on platform.
  // - On Flutter Web we expect the backend to be reachable at localhost:52552
  // - On mobile/emulator we use Android emulator host mapping 10.0.2.2:5000
  static String get baseUrl {
    final configured = _withDefaultScheme(_readEnv('API_URL'));
    if (configured.isNotEmpty) {
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }

    if (kIsWeb) return 'http://localhost:52552';
    return 'http://10.0.2.2:5000';
  }
}
