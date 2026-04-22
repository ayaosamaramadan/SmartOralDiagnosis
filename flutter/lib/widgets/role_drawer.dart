import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/theme_toggle.dart';
import 'avatar_uploader.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../services/role_service.dart';

class RoleDrawer extends StatefulWidget {
  const RoleDrawer({super.key});

  @override
  State<RoleDrawer> createState() => _RoleDrawerState();
}

class _RoleDrawerState extends State<RoleDrawer> {
  Future<User?>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _readUser();
    RoleService.notifier.addListener(_onRoleChange);
  }

  void _onRoleChange() {
    // When role changes (e.g., after login), re-read the stored user so the drawer reflects the signed-in user immediately.
    setState(() {
      _userFuture = _readUser();
    });
  }

  @override
  void dispose() {
    RoleService.notifier.removeListener(_onRoleChange);
    super.dispose();
  }

  Future<User?> _readUser() async {
    try {
      const storage = FlutterSecureStorage();
      final raw = await storage.read(key: 'user');
      if (raw == null) return null;
      final m = jsonDecode(raw);
      if (m is Map<String, dynamic>) return User.fromJson(m);
      if (m is Map) return User.fromJson(Map<String, dynamic>.from(m));
    } catch (_) {
      return null;
    }
    return null;
  }

  String? _extractRole(User? user) {
    if (user == null) return null;
    if (user.role != null) return user.role!.value.toLowerCase();
    if (user.roles != null && user.roles!.isNotEmpty) return user.roles!.first.toLowerCase();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: FutureBuilder<User?>(
        future: _userFuture,
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
          }

          String displayName = 'OralScan';
          String initials = 'OS';
          if (user != null) {
            final name = (!user.firstName!.isNotEmpty ? user.fullName : user.firstName)?.trim();
            if (name != null && name.isNotEmpty) {
              displayName = name;
              initials = user.initials;
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

          // Role specific (based on signed-in user role)
          if (role != null && role.contains('doctor')) {
            addItem(Icons.calendar_today, 'Appointments', '/appointments');
            addItem(Icons.camera_alt, 'Scan', '/scan');
            addItem(Icons.folder_shared, 'Medicall Records', '/medicalRecords');
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
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/doctors');
            },
          ));

          items.add(ListTile(
            leading: Icon(Icons.logout, color: cs.primary),
            title: Text('Logout', style: TextStyle(color: cs.onSurface)),
            onTap: () async {
              Navigator.pop(context);
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'jwt');
              await storage.delete(key: 'user');
              // Clear role notifier as well so UI updates immediately
              await RoleService.clear();
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
                          initialUrl: user?.photo,
                          userId: user?.id,
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
                                    // Show role label if available (prefer RoleService notifier)
                                    Builder(builder: (ctx) {
                                      String? notifierRole = RoleService.currentRoleString();
                                      String capitalize(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
                                      String headerRole;
                                      if (notifierRole != null && notifierRole.isNotEmpty) {
                                        headerRole = capitalize(notifierRole);
                                      } else if (role != null) {
                                        if (role.contains('doctor')) headerRole = 'Doctor';
                                        else if (role.contains('admin')) headerRole = 'Admin';
                                        else headerRole = 'Patient';
                                      } else {
                                        headerRole = 'Guest';
                                      }
                                      return Text(headerRole, style: TextStyle(color: cs.onPrimary.withOpacity(0.9), fontSize: 13));
                                    }),
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
