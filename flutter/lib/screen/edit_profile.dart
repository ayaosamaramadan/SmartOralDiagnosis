import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/edit_profile/progress_widget.dart';
import '../components/edit_profile/completed_or.dart';
import '../components/edit_profile/detect_location.dart';
import '../components/edit_profile/langu.dart';
import '../widgets/role_drawer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _form = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'password': '',
    'location': '',
    'phoneNumber': '',
  };
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String apiBase = 'http://10.0.2.2:5000';
  String? _jwt;
  String? _userId;
  bool _loading = false;
  String? _role;

  // controllers to allow updating initial values after async load
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _onDetectLocation(String location) {
    setState(() {
      _form['location'] = location;
      _locationController.text = location; // populate the Location field with detected city
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location detected')),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final raw = await _storage.read(key: 'user');
      final token = await _storage.read(key: 'jwt');
      _jwt = token;
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> user = Map<String, dynamic>.from(
          jsonDecode(raw),
        );
        _userId = user['id']?.toString() ?? user['Id']?.toString();
        _role = (user['role'] ?? user['Role'])?.toString();
        if (!mounted) return;
        setState(() {
          _form['firstName'] = user['firstName'] ?? '';
          _form['lastName'] = user['lastName'] ?? '';
          _form['email'] = user['email'] ?? '';
          _form['phoneNumber'] = user['phoneNumber'] ?? '';
          _form['location'] = user['location'] ?? '';

          _firstNameController.text = _form['firstName'];
          _lastNameController.text = _form['lastName'];
          _emailController.text = _form['email'];
          _phoneController.text = _form['phoneNumber'];
          _locationController.text = _form['location'];
        });
        // If we have jwt and id, attempt to refresh from backend
        if (_jwt != null && _userId != null) {
          try {
            final controller = (_role != null && _role!.toLowerCase().contains('doctor')) ? 'Doctors' : 'Patients';
            final uri = Uri.parse('$apiBase/api/$controller/$_userId');
            final resp = await http.get(uri, headers: {'Authorization': 'Bearer $_jwt'});
            if (resp.statusCode == 200) {
              final Map<String, dynamic> body = jsonDecode(resp.body);
              if (!mounted) return;
              setState(() {
                _form['firstName'] = body['firstName'] ?? _form['firstName'];
                _form['lastName'] = body['lastName'] ?? _form['lastName'];
                _form['email'] = body['email'] ?? _form['email'];
                _form['phoneNumber'] = body['phoneNumber'] ?? _form['phoneNumber'];
                _form['location'] = body['location'] ?? _form['location'];

                _firstNameController.text = _form['firstName'];
                _lastNameController.text = _form['lastName'];
                _emailController.text = _form['email'];
                _phoneController.text = _form['phoneNumber'];
                _locationController.text = _form['location'];
              });
              // After refreshing, try to flush any pending updates saved while offline
              await _flushPendingUpdates();
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    final payload = {
      'firstName': _form['firstName'],
      'lastName': _form['lastName'],
      'phoneNumber': _form['phoneNumber'],
      'location': _form['location'],
    };

    // Try backend update if we have token and id
    if (_jwt != null && _userId != null) {
      try {
        final controller = (_role != null && _role!.toLowerCase().contains('doctor')) ? 'Doctors' : 'Patients';
        final uri = Uri.parse('$apiBase/api/$controller/$_userId');
        final resp = await http.put(uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_jwt'
            },
            body: jsonEncode(payload));

        if (resp.statusCode == 200) {
          // update local cached user if present
          try {
            final existing = await _storage.read(key: 'user');
            if (existing != null) {
              final user = Map<String, dynamic>.from(jsonDecode(existing));
              user['firstName'] = _form['firstName'];
              user['lastName'] = _form['lastName'];
              user['phoneNumber'] = _form['phoneNumber'];
              user['location'] = _form['location'];
              await _storage.write(key: 'user', value: jsonEncode(user));
            }
          } catch (_) {}
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated on server')));
          setState(() => _loading = false);
          return;
        }
      } catch (_) {
        // network error, fallback to local save
      }
    }

    // Fallback: save locally in secure storage
    try {
      final existing = await _storage.read(key: 'user');
      if (existing != null) {
        final user = Map<String, dynamic>.from(jsonDecode(existing));
        user['firstName'] = _form['firstName'];
        user['lastName'] = _form['lastName'];
        user['phoneNumber'] = _form['phoneNumber'];
        user['location'] = _form['location'];
        await _storage.write(key: 'user', value: jsonEncode(user));
      } else {
        final user = {
          'firstName': _form['firstName'],
          'lastName': _form['lastName'],
          'phoneNumber': _form['phoneNumber'],
          'location': _form['location']
        };
        await _storage.write(key: 'user', value: jsonEncode(user));
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved locally — will sync when online')));
    } catch (_) {}

    // enqueue pending sync so it will be pushed to backend (and Mongo) when online
    try {
      await _enqueuePendingUpdate({'userId': _userId, 'role': _role, 'payload': payload});
    } catch (_) {}

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const RoleDrawer(),

      // ============================
      //           شاشة Edit Profile
      // ============================
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [IconButton(onPressed: _loading ? null : _onSave, icon: _loading ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.save))],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Langu(onChanged: (c) => debugPrint('lang $c selected')),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First name',
                                  ),
                                  onSaved: (v) => _form['firstName'] =
                                      _firstNameController.text,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last name',
                                  ),
                                  onSaved: (v) => _form['lastName'] =
                                      _lastNameController.text,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (v) =>
                                _form['email'] = _emailController.text,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _passwordController,
                            initialValue: null,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            onSaved: (v) =>
                                _form['password'] = _passwordController.text,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone',
                                  ),
                                  keyboardType: TextInputType.phone,
                                  onSaved: (v) => _form['phoneNumber'] =
                                      _phoneController.text,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Location',
                                  ),
                                  onSaved: (v) => _form['location'] =
                                      _locationController.text,
                                ),
                              ),
                              const SizedBox(width: 12),
                              DetectLocation(onDetected: _onDetectLocation),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => _showCompletionPrompt(),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Profile completeness'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _loading ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [Icon(Icons.save_outlined), SizedBox(width: 8), Text('Save Profile')],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionPrompt() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              controller: scrollController,
              child: CompletedOr(form: _form),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Persist a pending update to secure storage so it can be flushed later when online.
  Future<void> _enqueuePendingUpdate(Map<String, dynamic> entry) async {
    try {
      final raw = await _storage.read(key: 'pending_profile_updates');
      List<Map<String, dynamic>> list = [];
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw) as List<dynamic>;
          list = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (_) {
          list = [];
        }
      }
      list.add(entry);
      await _storage.write(key: 'pending_profile_updates', value: jsonEncode(list));
    } catch (_) {}
  }

  // Attempt to flush pending updates to the backend. On success, clear them.
  Future<void> _flushPendingUpdates() async {
    try {
      final raw = await _storage.read(key: 'pending_profile_updates');
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      final List<Map<String, dynamic>> list = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final remaining = <Map<String, dynamic>>[];
      for (final item in list) {
        final itemUserId = (item['userId'] ?? _userId)?.toString();
        final role = item['role']?.toString() ?? _role;
        final payload = Map<String, dynamic>.from(item['payload'] ?? {});
        if (itemUserId == null) {
          // cannot flush without user id; keep it
          remaining.add(item);
          continue;
        }
        final controller = (role != null && role.toLowerCase().contains('doctor')) ? 'Doctors' : 'Patients';
        try {
          final uri = Uri.parse('$apiBase/api/$controller/$itemUserId');
          final resp = await http.put(uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${_jwt ?? ''}'
              },
              body: jsonEncode(payload));
          if (resp.statusCode == 200) {
            // success — backend will sync to Mongo; do not re-add
            continue;
          } else {
            remaining.add(item);
          }
        } catch (_) {
          remaining.add(item);
        }
      }

      if (remaining.isEmpty) {
        await _storage.delete(key: 'pending_profile_updates');
      } else {
        await _storage.write(key: 'pending_profile_updates', value: jsonEncode(remaining));
      }
    } catch (_) {}
  }
}
