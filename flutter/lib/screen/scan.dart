import 'dart:io' show File;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/role_drawer.dart';
import 'package:image_picker/image_picker.dart'
    show ImagePicker, ImageSource, XFile;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/theme_toggle.dart';
import '../data/orals.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isAnalyzing = false;
  String? _diagnosis;
  int? _confidence;
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _analyzeImage();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _analyzeImage();
    }
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(labelText: 'Patient Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Observations',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final name = _patientNameController.text.trim();
                        final notes = _notesController.text.trim();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _diagnosis = null;
      _confidence = null;
    });

    try {
      // Change this to your inference server address if needed.
      // For Android emulator use 10.0.2.2 to access host machine localhost.
      // const String aiBase = 'http://10.0.2.2:8000';
      // For real device on the same Wi-Fi
      const String aiBase = 'http://192.168.1.11:8000';

      final uri = Uri.parse('$aiBase/predict');

      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = json.decode(resp.body);
        setState(() {
          _diagnosis = body['diagnosis']?.toString() ?? 'Unknown';
          final conf = body['confidence'];
          if (conf is int)
            _confidence = conf;
          else if (conf is double)
            _confidence = (conf * 100).round();
          else if (conf is String)
            _confidence = int.tryParse(conf) ?? null;
        });
      } else {
        setState(() {
          _diagnosis = 'Analysis failed (${resp.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _diagnosis = 'Analysis error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
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
                ? [
                    appColors.gradientStart,
                    appColors.gradientMiddle,
                    appColors.gradientEnd,
                  ]
                : const [
                    Color(0xFFB3E5FC),
                    Color(0xFF64B5F6),
                    Color(0xFF1976D2),
                  ],
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
                        style: TextStyle(fontSize: 16, color: cs.onSurface),
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
                            color: cs.outline.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 80,
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Image will appear here",
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _pickFromCamera,
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Camera",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _pickFromGallery,
                              icon: const Icon(
                                Icons.upload_file,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Gallery",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (_imageFile != null) ...[
                        if (_isAnalyzing)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                'Analyzing your image...',
                                style: TextStyle(color: cs.onSurface),
                              ),
                            ],
                          )
                        else
                          ElevatedButton(
                            onPressed: _openForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 32,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Load Form',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),

                        if (_diagnosis != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surface.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Analysis Complete',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    if (_confidence != null)
                                      Text(
                                        '$_confidence% confi`dence',
                                        style: TextStyle(
                                          color: cs.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _diagnosis!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Recommendations',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (_) {
                                    final recs = (_diagnosis != null)
                                        ? recommendationsFor(_diagnosis!)
                                        : defaultRecommendations;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: recs
                                          .map(
                                            (r) => Padding(
                                              padding:
                                                  const EdgeInsets.only(bottom: 8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    size: 18,
                                                    color: cs.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      r,
                                                      style: TextStyle(
                                                        color: cs.onSurface
                                                            .withOpacity(0.85),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

Widget _buildNavBar(BuildContext context, ColorScheme cs) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: cs.onSurface,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 8),
            Text(
              "ORACLE",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ],
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

          _buildDrawerItem(
            context,
            cs,
            "Diseases & Conditions",
            Icons.medical_services,
            () {
              Navigator.pushNamed(context, '/Alldisease');
            },
          ),

          _buildDrawerItem(context, cs, "About Us", Icons.info_outline, () {}),

          const Divider(),

          ListTile(
            leading: Icon(Icons.contact_page, color: cs.primary),
            title: Text("Contact Us", style: TextStyle(color: cs.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/doctors');
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
    BuildContext context,
    ColorScheme cs,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 16)),
      onTap: onTap,
    );
  }
}
