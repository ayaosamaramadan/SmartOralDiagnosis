
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Secure storage wrapper for auth tokens used by the app.
final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

Future<void> storeToken(String token) async {
  await _secureStorage.write(key: 'auth_token', value: token);
}

Future<String?> readToken() async {
  // Try auth_token first, then fallback to jwt for backward compatibility
  var token = await _secureStorage.read(key: 'auth_token');
  if (token == null) {
    token = await _secureStorage.read(key: 'jwt');
  }
  return token;
}

Future<void> deleteToken() async {
  await _secureStorage.delete(key: 'auth_token');
}

Future<void> storeAuthHeader(String header) async {
  await _secureStorage.write(key: 'ai_auth_header', value: header);
}

Future<String?> readAuthHeader() async {
  return await _secureStorage.read(key: 'ai_auth_header');
}

Future<void> storeAuthPrefix(String prefix) async {
  await _secureStorage.write(key: 'ai_auth_prefix', value: prefix);
}

Future<String?> readAuthPrefix() async {
  return await _secureStorage.read(key: 'ai_auth_prefix');
}

Future<void> clearAuthSettings() async {
  await _secureStorage.delete(key: 'auth_token');
  await _secureStorage.delete(key: 'jwt'); // For backward compatibility
  await _secureStorage.delete(key: 'ai_auth_header');
  await _secureStorage.delete(key: 'ai_auth_prefix');
}

/// Returns a map with the configured auth header when a token exists, otherwise empty.
/// Preference order: secure storage token -> env AI_API_KEY -> (none).
/// Header/prefix preference: secure storage -> environment variables -> defaults.
Future<Map<String, String>> getAuthHeaders() async {
  // Prefer secure storage token; fall back to .env AI_API_KEY
  final token = await readToken() ?? (dotenv.env['AI_API_KEY']?.trim() ?? '').trim();
  if (token.isEmpty) return {};

  final storedHeader = await readAuthHeader();
  final envHeader = dotenv.env['AI_AUTH_HEADER'] ?? dotenv.env['AI_SERVICE_AUTH_HEADER'];
  final headerName = (storedHeader?.trim().isNotEmpty == true)
      ? storedHeader!.trim()
      : (envHeader?.trim().isNotEmpty == true ? envHeader!.trim() : 'Authorization');

  final storedPrefix = await readAuthPrefix();
  final envPrefix = dotenv.env['AI_AUTH_PREFIX'] ?? dotenv.env['AI_SERVICE_AUTH_PREFIX'];
  final prefix = (storedPrefix?.trim().isNotEmpty == true)
      ? storedPrefix!.trim()
      : (envPrefix?.trim().isNotEmpty == true ? envPrefix!.trim() : 'Bearer');

  final value = prefix.isNotEmpty ? '$prefix $token' : token;
  return {headerName: value};
}
