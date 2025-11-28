import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/theme_toggle.dart';
import 'avatar_uploader.dart';

class RoleDrawer extends StatelessWidget {
  const RoleDrawer({super.key});

  Future<Map<String, dynamic>?> _readUser() async {
    try {
      const storage = FlutterSecureStorage();
      final raw = await storage.read(key: 'user');
      if (raw == null) return null;
      final m = jsonDecode(raw);
      // If the stored value is already the inner `user` wrapper (e.g. {"user": {...}})
      if (m is Map && m.containsKey('user') && m['user'] is Map) {
        return Map<String, dynamic>.from(m['user']);
      }
      if (m is Map) return Map<String, dynamic>.from(m);
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractRole(Map<String, dynamic>? user) {
    if (user == null) return null;
    // common keys
    final candidates = <dynamic>[user['role'], user['Role'], user['type'], user['userType'], user['accountType']];
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim().toLowerCase();
      if (c is Map) {
        // handle cases like { role: 'Doctor' } or { name: 'Doctor' }
        final val = (c['role'] ?? c['name'] ?? c['type']) as dynamic;
        if (val is String && val.trim().isNotEmpty) return val.trim().toLowerCase();
      }
    }

    // roles could be an array of strings or objects
    final r = user['roles'] ?? user['Roles'];
    if (r != null) {
      if (r is String && r.trim().isNotEmpty) return r.trim().toLowerCase();
      if (r is List && r.isNotEmpty) {
        // prefer a string entry or map entry with common keys
        for (final entry in r) {
          if (entry is String && entry.trim().isNotEmpty) return entry.trim().toLowerCase();
          if (entry is Map) {
            final val = (entry['name'] ?? entry['role'] ?? entry['roleName'] ?? entry['role_name']) as dynamic;
            if (val is String && val.trim().isNotEmpty) return val.trim().toLowerCase();
          }
        }
      }
    }

    // sometimes server returns nested structure like { data: { user: { role: 'Doctor' } } }
    if (user.containsKey('data') && user['data'] is Map) {
      final data = Map<String, dynamic>.from(user['data']);
      final nested = _extractRole(data);
      if (nested != null) return nested;
    }

    // sometimes the user object itself may contain another `user` wrapper
    if (user.containsKey('user') && user['user'] is Map) {
      final inner = Map<String, dynamic>.from(user['user']);
      final nested = _extractRole(inner);
      if (nested != null) return nested;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _readUser(),
        builder: (context, snap) {
          // If still loading, show a simple loading drawer to avoid
          // rendering default (patient) items briefly before we know the role.
          if (snap.connectionState == ConnectionState.waiting || snap.connectionState == ConnectionState.active) {
            final cs = Theme.of(context).colorScheme;
            return Container(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? [cs.primary, cs.secondary]
                            : [cs.primary.withOpacity(0.85), cs.primary],
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 28, backgroundColor: cs.onPrimary.withOpacity(0.2)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: 120, height: 16, color: cs.onPrimary.withOpacity(0.15)),
                          const SizedBox(height: 8),
                          const ThemeToggle(),
                        ])),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          }

          // If future completed (done) - proceed to read the data / error
          final user = snap.data;
          final role = _extractRole(user);
          if (snap.hasError) {
            // Don't crash drawer rendering on unexpected read errors; fall back to guest behavior.
            // Optionally you can log the error during development.
            // debugPrint('RoleDrawer read error: ${snap.error}');
          }

          String displayName = 'OralScan';
          String initials = 'OS';
          if (user != null) {
            final name = (user['firstName'] ?? user['first_name'] ?? user['name'] ?? '') as String?;
            if (name != null && name.isNotEmpty) {
              displayName = name;
              initials = name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join();
            }
          }

          List<Widget> items = [];

          void addItem(IconData icon, String text, String? route) {
            items.add(ListTile(
              leading: Icon(icon, color: cs.primary),
              title: Text(text, style: TextStyle(color: cs.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                if (route != null) Navigator.pushNamed(context, route);
              },
            ));
          }

          // Common items
          addItem(Icons.home, 'Home', '/');
          addItem(Icons.medical_services, 'Diseases & Conditions', '/Alldisease');

          // Role specific
          if (role != null && role.contains('doctor')) {
            addItem(Icons.calendar_today, 'Appointments', '/appointments');
            addItem(Icons.camera_alt, 'Scan', '/scan');
            addItem(Icons.folder_shared, 'Medical Records', '/medicalRecords');
            addItem(Icons.bar_chart, 'Reports', '/reports');
            addItem(Icons.settings, 'Settings', '/settings');
          } else if (role != null && role.contains('admin')) {
            addItem(Icons.group, 'Users', '/users');
            addItem(Icons.bar_chart, 'Reports', '/reports');
            addItem(Icons.settings, 'Settings', '/settings');
          } else {
            // default -> patient / guest
            addItem(Icons.calendar_today, 'Appointments', '/appointments');
            addItem(Icons.camera_alt, 'Scan', '/scan');
            addItem(Icons.medical_services, 'Doctors', '/doctors');
            addItem(Icons.folder_shared, 'Medical Records', '/medicalRecords');
            addItem(Icons.settings, 'Settings', '/settings');
          }

          items.add(const Divider());

          items.add(ListTile(
            leading: Icon(Icons.contact_page, color: cs.primary),
            title: Text('Contact Us', style: TextStyle(color: cs.onSurface)),
            onTap: () => Navigator.pop(context),
          ));

          items.add(ListTile(
            leading: Icon(Icons.logout, color: cs.primary),
            title: Text('Logout', style: TextStyle(color: cs.onSurface)),
            onTap: () async {
              Navigator.pop(context);
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'jwt');
              await storage.delete(key: 'user');
              Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
            },
          ));

          // If not logged in, show Login
          if (user == null) {
            items.add(ListTile(
              leading: Icon(Icons.login, color: cs.primary),
              title: Text('Login', style: TextStyle(color: cs.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ));
          }

          return Container(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? [cs.primary, cs.secondary]
                          : [cs.primary.withOpacity(0.85), cs.primary],
                    ),
                  ),
                  child: Row(
                    children: [
                      // avatar uploader shows initials and allows picking/uploading
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: AvatarUploader(
                          initials: initials,
                          initialUrl: user != null ? (user['photo'] as String?) : null,
                          userId: user != null ? (user['id']?.toString() ?? user['Id']?.toString()) : null,
                          onUploaded: (url) {
                            // no-op here; AvatarUploader already persists to storage
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(displayName, style: TextStyle(color: cs.onPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const ThemeToggle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ...items,
              ],
            ),
          );
        },
      ),
    );
  }
}
