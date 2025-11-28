import 'dart:io' show File;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/role_drawer.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import '../components/theme_toggle.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const RoleDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: cs.primary,
        tooltip: 'Chat',
        child: Icon(Icons.chat_bubble, color: cs.onPrimary),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [appColors.gradientStart, appColors.gradientMiddle, appColors.gradientEnd]
                : const [Color(0xFFB3E5FC), Color(0xFF64B5F6), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNavBar(context, cs),
                const SizedBox(height: 70),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Take a photo or upload an image for AI-powered dental analysis",
                        style: TextStyle(
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 50),

                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          color: cs.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: cs.outline.withOpacity(0.3), width: 2),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 80,
                                      color: cs.onSurface.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Image will appear here",
                                    style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.7),
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _pickFromCamera,
                              icon: const Icon(Icons.camera_alt_outlined,
                                  color: Colors.white),
                              label: const Text(
                                "Camera",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.upload_file,
                                  color: Colors.white),
                              label: const Text(
                                "Gallery",
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- NAVBAR (نفس الهوم بالظبط) ----------------
  Widget _buildNavBar(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "OralScan",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: cs.onSurface, size: 32),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Drawer (نسخة طبق الأصل من الهوم) ----------------
  Drawer _buildSideMenu(BuildContext context, ColorScheme cs) {
    return Drawer(
      backgroundColor: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [cs.primary, cs.secondary]
                    : [cs.primary.withOpacity(0.8), cs.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "OralScan",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const ThemeToggle(),
              ],
            ),
          ),

          _buildDrawerItem(context, cs, "Home", Icons.home, () {
            Navigator.pushNamed(context, '/');
          }),

          _buildDrawerItem(context, cs, "Diseases & Conditions",
              Icons.medical_services, () {
            Navigator.pushNamed(context, '/Alldisease');
          }),

          _buildDrawerItem(context, cs, "About Us", Icons.info_outline, () {}),

          const Divider(),

          ListTile(
            leading: Icon(Icons.contact_page, color: cs.primary),
            title: Text("Contact Us", style: TextStyle(color: cs.onSurface)),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.login, color: cs.primary),
            title: Text("Login", style: TextStyle(color: cs.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, ColorScheme cs, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title,
          style: TextStyle(color: cs.onSurface, fontSize: 16)),
      onTap: onTap,
    );
  }
}
