import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_role.dart';

class RoleService {
  static const _key = 'role';
  static const _storage = FlutterSecureStorage();

  // Notifier so UI can react to role changes immediately.
  static final ValueNotifier<UserRole?> notifier = ValueNotifier<UserRole?>(null);

  /// Initialize the notifier from storage. Call once at app startup.
  static Future<void> init() async {
    final r = await readRole();
    if (r != null) {
      notifier.value = r;
      return;
    }

    // If no explicit stored role, try to seed role from stored `user` object first.
    try {
      await seedRoleFromStoredUser();
      if (notifier.value != null) return;
    } catch (_) {}

    // If still no stored role, try to decode the JWT (if present) and extract role claim.
    try {
      final jwt = await _storage.read(key: 'jwt');
      if (jwt != null && jwt.trim().isNotEmpty) {
        final payload = _parseJwtPayload(jwt);
        if (payload != null) {
          final roleClaim = (payload['role'] ?? payload['roles'] ?? payload['Role'])?.toString();
          final parsed = UserRoleExt.fromString(roleClaim);
          if (parsed != UserRole.unknown) {
            await saveRole(parsed);
            return;
          }
        }
      }
    } catch (_) {}

    notifier.value = null;
  }

  /// Returns the current role as a lowercase string (e.g. 'doctor'), or null.
  static String? currentRoleString() => notifier.value?.value;

  /// Try to read the stored `user` object and seed the role from it if present.
  static Future<void> seedRoleFromStoredUser() async {
    try {
      final raw = await _storage.read(key: 'user');
      if (raw == null || raw.trim().isEmpty) return;
      final Map<String, dynamic> map = json.decode(raw);
      // try to extract role-like fields
      final candidates = [map['role'], map['Role'], map['type'], map['roles'], map['userRole'], map['user_type']];
      String? roleStr;
      for (final c in candidates) {
        if (c is String && c.trim().isNotEmpty) {
          roleStr = c.trim();
          break;
        }
        if (c is List && c.isNotEmpty) {
          final first = c.firstWhere((e) => e is String, orElse: () => null);
          if (first is String && first.trim().isNotEmpty) {
            roleStr = first.trim();
            break;
          }
        }
        if (c is Map && c.isNotEmpty) {
          final val = c['role'] ?? c['name'] ?? c['type'];
          if (val is String && val.trim().isNotEmpty) {
            roleStr = val.trim();
            break;
          }
        }
      }

      if (roleStr != null) {
        final parsed = UserRoleExt.fromString(roleStr);
        if (parsed != UserRole.unknown) await saveRole(parsed);
      }
    } catch (_) {}
  }

  static Map<String, dynamic>? _parseJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      // Normalize base64
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 0:
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
        default:
          return null;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> map = json.decode(decoded);
      return map;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveRole(UserRole role) async {
    await _storage.write(key: _key, value: role.value);
    notifier.value = role == UserRole.unknown ? null : role;
  }

  /// Parse the provided JWT and save its role claim (if any) into storage and notifier.
  static Future<void> saveRoleFromJwt(String jwt) async {
    try {
      final payload = _parseJwtPayload(jwt);
      if (payload == null) return;
      dynamic roleClaim = payload['role'] ?? payload['roles'] ?? payload['Role'];
      if (roleClaim is List && roleClaim.isNotEmpty) roleClaim = roleClaim.first;
      if (roleClaim is Map) roleClaim = roleClaim['role'] ?? roleClaim['name'] ?? roleClaim['type'];
      final parsed = UserRoleExt.fromString(roleClaim?.toString());
      if (parsed != UserRole.unknown) await saveRole(parsed);
    } catch (_) {}
  }

  /// Returns the raw stored role string, or null if not present.
  static Future<String?> readRoleValue() async {
    return await _storage.read(key: _key);
  }

  /// Returns a nullable UserRole. Null if no stored value or unknown.
  static Future<UserRole?> readRole() async {
    final raw = await readRoleValue();
    if (raw == null) return null;
    final parsed = UserRoleExt.fromString(raw);
    return parsed == UserRole.unknown ? null : parsed;
  }

  static Future<void> clear() async {
    await _storage.delete(key: _key);
    notifier.value = null;
  }
}
