import 'package:flutter/foundation.dart';
import 'user_role.dart';

class User {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final UserRole? role;
  final String? photo;
  final List<String>? roles;

  const User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.role,
    this.photo,
    this.roles,
  });

  String get fullName {
    final parts = <String>[];
    if (firstName != null && firstName!.trim().isNotEmpty) parts.add(firstName!.trim());
    if (lastName != null && lastName!.trim().isNotEmpty) parts.add(lastName!.trim());
    return parts.join(' ');
  }

  String get initials {
    final name = fullName;
    if (name.isEmpty) return 'U';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    String? photo,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      photo: photo ?? this.photo,
      roles: roles ?? this.roles,
    );
  }

  /// Robust factory that accepts nested responses ("user" wrapper, "data", different key names).
  factory User.fromJson(Map<String, dynamic> json) {
    // Depth-first try to find the real user map
    Map<String, dynamic> m = Map<String, dynamic>.from(json);

    // unwrap common wrappers
    if (m.containsKey('data') && m['data'] is Map && (m['data'] as Map).containsKey('user')) {
      m = Map<String, dynamic>.from((m['data'] as Map)['user']);
    }
    if (m.containsKey('user') && m['user'] is Map) {
      m = Map<String, dynamic>.from(m['user']);
    }

    String? id = (m['id'] ?? m['Id'] ?? m['userId'] ?? m['_id'])?.toString();
    String? first = (m['firstName'] ?? m['first_name'] ?? m['name']) as String?;
    String? last = (m['lastName'] ?? m['last_name']) as String?;
    // If only `name` provided and contains spaces, try splitting
    if ((first == null || first.isEmpty) && m['name'] is String) {
      final n = (m['name'] as String).trim();
      final parts = n.split(' ');
      if (parts.isNotEmpty) first = parts.first;
      if (parts.length > 1) last = parts.sublist(1).join(' ');
    }

    final email = (m['email'] ?? m['Email']) as String?;
    final phone = (m['phone'] ?? m['phoneNumber'] ?? m['phone_number']) as String?;
    final photo = (m['photo'] ?? m['avatar'] ?? m['picture']) as String?;

    // roles handling
    String? roleStr;
    final candidates = [m['role'], m['Role'], m['type'], m['userRole'], m['user_type'], m['accountType']];
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) {
        roleStr = c.trim();
        break;
      }
      if (c is Map) {
        final val = (c['role'] ?? c['name'] ?? c['type']);
        if (val is String && val.trim().isNotEmpty) {
          roleStr = val.trim();
          break;
        }
      }
    }

    // array roles
    List<String>? rolesList;
    final r = m['roles'] ?? m['Roles'];
    if (r != null) {
      if (r is String && r.trim().isNotEmpty) {
        rolesList = r.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        if (rolesList.isNotEmpty && roleStr == null) roleStr = rolesList.first;
      } else if (r is List && r.isNotEmpty) {
        rolesList = r.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
        if (rolesList.isNotEmpty && roleStr == null) roleStr = rolesList.first;
      }
    }

    final parsedRole = UserRoleExt.fromString(roleStr);
    final role = parsedRole == UserRole.unknown ? null : parsedRole;

    return User(
      id: id,
      firstName: first,
      lastName: last,
      email: email,
      phoneNumber: phone,
      role: role,
      photo: photo,
      roles: rolesList,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (id != null) m['id'] = id;
    if (firstName != null) m['firstName'] = firstName;
    if (lastName != null) m['lastName'] = lastName;
    if (email != null) m['email'] = email;
    if (phoneNumber != null) m['phone'] = phoneNumber;
    if (photo != null) m['photo'] = photo;
    if (role != null) m['role'] = role!.value;
    if (roles != null) m['roles'] = roles;
    return m;
  }

  @override
  String toString() => 'User(id: $id, name: $fullName, email: $email, role: ${role?.value})';
}
