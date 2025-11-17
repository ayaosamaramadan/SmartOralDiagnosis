import 'package:flutter/material.dart';
import '../components/edit_profile/progress_widget.dart';
import '../components/edit_profile/completed_or.dart';
import '../components/edit_profile/detect_location.dart';
import '../components/edit_profile/langu.dart';

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

  void _onDetectLocation(String location) {
    setState(() {
      _form['location'] = location;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Location detected')));
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved (local demo)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      // ============================
      //        🔥 DRAWER 🔥
      //   (نفس بتاع الهوم بيدج)
      // ============================
      drawer: Drawer(
        child: Container(
          color: isDark ? Colors.black : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.blueGrey.shade900, Colors.black]
                        : [Colors.blue.shade300, Colors.blue.shade700],
                  ),
                ),
                child: const Text(
                  "My App",
                  style: TextStyle(color: Colors.white, fontSize: 26),
                ),
              ),

              ListTile(
                leading: Icon(Icons.home, color: isDark ? Colors.white : Colors.black),
                title: Text("Home", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pushNamed(context, '/'),
              ),

              ListTile(
                leading: Icon(Icons.medical_services,
                    color: isDark ? Colors.white : Colors.black),
                title: Text("Diseases & Conditions",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pushNamed(context, '/Alldiseasea'),
              ),

              ListTile(
                leading: Icon(Icons.info_outline,
                    color: isDark ? Colors.white : Colors.black),
                title: Text("About Us",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {},
              ),

              const Divider(),

              ListTile(
                leading: Icon(Icons.mail_outline,
                    color: isDark ? Colors.white : Colors.black),
                title: Text("Contact Us",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {},
              ),

              ListTile(
                leading: Icon(Icons.login,
                    color: isDark ? Colors.white : Colors.black),
                title: Text("Login",
                    style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),

      // ============================
      //           شاشة Edit Profile
      // ============================
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(onPressed: _onSave, icon: const Icon(Icons.save)),
        ],
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
                    const Text('Profile',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(children: [
                      Langu(onChanged: (c) => debugPrint('lang $c selected')),
                      const SizedBox(width: 8),
                    ])
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
                                  initialValue: _form['firstName'],
                                  decoration:
                                      const InputDecoration(labelText: 'First name'),
                                  onSaved: (v) =>
                                      _form['firstName'] = v ?? '',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _form['lastName'],
                                  decoration:
                                      const InputDecoration(labelText: 'Last name'),
                                  onSaved: (v) =>
                                      _form['lastName'] = v ?? '',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            initialValue: _form['email'],
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (v) => _form['email'] = v ?? '',
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            initialValue: _form['password'],
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            onSaved: (v) => _form['password'] = v ?? '',
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _form['phoneNumber'],
                                  decoration:
                                      const InputDecoration(labelText: 'Phone'),
                                  keyboardType: TextInputType.phone,
                                  onSaved: (v) =>
                                      _form['phoneNumber'] = v ?? '',
                                ),
                              ),
                              const SizedBox(width: 12),
                              DetectLocation(onDetected: _onDetectLocation),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            initialValue: _form['location'],
                            decoration:
                                const InputDecoration(labelText: 'Location'),
                            onSaved: (v) => _form['location'] = v ?? '',
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
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
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
}
