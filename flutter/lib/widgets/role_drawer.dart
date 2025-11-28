import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/theme_toggle.dart';

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
      if (c is String && c.trim().isNotEmpty) return c.toLowerCase();
    }

    // roles could be an array of strings or objects
    final r = user['roles'] ?? user['Roles'];
    if (r != null) {
      if (r is String && r.isNotEmpty) return r.toLowerCase();
      if (r is List && r.isNotEmpty) {
        final first = r.first;
        if (first is String && first.isNotEmpty) return first.toLowerCase();
        if (first is Map && first['name'] != null && first['name'] is String) return (first['name'] as String).toLowerCase();
      }
    }

    // sometimes server returns nested structure like { data: { user: { role: 'Doctor' } } }
    if (user.containsKey('data') && user['data'] is Map) {
      final data = Map<String, dynamic>.from(user['data']);
      final nested = _extractRole(data);
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
            final user = snap.data;
            final role = _extractRole(user);

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
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: cs.onPrimary.withOpacity(0.2),
                        child: Text(initials, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
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
