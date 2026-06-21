import 'dart:async';
import 'dart:io' show File, SocketException;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/role_drawer.dart';
import '../components/app_nav.dart';
import 'package:image_picker/image_picker.dart'
    show ImagePicker, ImageSource, XFile;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/theme_toggle.dart';
import '../data/orals.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  static const String _defaultApiUrl =
      'https://oralbackend-production-dcfa.up.railway.app';
  static const String _defaultAiUrl =
      'https://web-production-f3c3b.up.railway.app';

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isAnalyzing = false;
  String? _diagnosis;
  List<String>? _symptoms;
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

  String _readEnv(String key) {
    final raw = dotenv.env[key]?.trim() ?? '';
    if (raw.length >= 2) {
      final first = raw[0];
      final last = raw[raw.length - 1];
      if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
        return raw.substring(1, raw.length - 1).trim();
      }
    }
    return raw;
  }

  String _normalizeBaseUrl(String rawBaseUrl) {
    var baseUrl = rawBaseUrl.trim();
    while (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  String _withDefaultScheme(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'http://$value';
  }

  String _backendPredictUrl(String rawBaseUrl) {
    final baseUrl = _normalizeBaseUrl(_withDefaultScheme(rawBaseUrl));
    final lowerBaseUrl = baseUrl.toLowerCase();

    if (lowerBaseUrl.endsWith('/api/ai/predict')) return baseUrl;
    if (lowerBaseUrl.endsWith('/api')) return '$baseUrl/ai/predict';
    return '$baseUrl/api/ai/predict';
  }

  String _directAiPredictUrl(String rawBaseUrl) {
    final baseUrl = _normalizeBaseUrl(_withDefaultScheme(rawBaseUrl));
    final lowerBaseUrl = baseUrl.toLowerCase();

    if (lowerBaseUrl.endsWith('/predict') ||
        lowerBaseUrl.endsWith('/api/ai/predict')) {
      return baseUrl;
    }

    return '$baseUrl/predict';
  }

  List<Uri> _resolveAiPredictUris() {
    final apiUrl = _readEnv('NEXT_PUBLIC_API_URL');
    final aiUrl = _readEnv('NEXT_PUBLIC_AI_URL');
    final candidates = <String>[
      _backendPredictUrl(apiUrl.isNotEmpty ? apiUrl : _defaultApiUrl),
      _directAiPredictUrl(aiUrl.isNotEmpty ? aiUrl : _defaultAiUrl),
    ];

    final seen = <String>{};
    final uris = <Uri>[];

    for (final raw in candidates) {
      final value = raw.trim();
      if (value.isEmpty || seen.contains(value)) continue;

      final uri = Uri.tryParse(value);
      if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) continue;

      seen.add(value);
      uris.add(uri);
    }

    return uris;
  }

  String? _extractDiagnosis(Map<String, dynamic>? body) {
    if (body == null) return null;

    final direct = body['diagnosis'] ?? body['label'] ?? body['prediction'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    final predictions = body['predictions'];
    if (predictions is List && predictions.isNotEmpty) {
      final first = predictions.first;
      if (first is Map) {
        final label = first['diagnosis'] ?? first['label'] ?? first['class'];
        if (label is String && label.trim().isNotEmpty) {
          return label.trim();
        }
      } else if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
    }

    return null;
  }

  int? _extractConfidencePercent(Map<String, dynamic>? body) {
    if (body == null) return null;

    dynamic raw = body['confidence'] ?? body['score'] ?? body['probability'];
    if (raw == null) {
      final predictions = body['predictions'];
      if (predictions is List && predictions.isNotEmpty) {
        final first = predictions.first;
        if (first is Map) {
          raw = first['confidence'] ?? first['score'] ?? first['probability'];
        }
      }
    }

    if (raw is int) {
      return raw.clamp(0, 100).toInt();
    }

    if (raw is double) {
      final normalized = raw <= 1 ? raw * 100 : raw;
      return normalized.round().clamp(0, 100).toInt();
    }

    if (raw is String) {
      final parsed = double.tryParse(raw.trim());
      if (parsed != null) {
        final normalized = parsed <= 1 ? parsed * 100 : parsed;
        return normalized.round().clamp(0, 100).toInt();
      }
    }

    return null;
  }

  List<String> _extractSymptoms(Map<String, dynamic>? body) {
    if (body == null) return [];

    final symptoms = <String>[];

    // Check for direct symptoms array
    final symptomsArray =
        body['symptoms'] ?? body['symptom_list'] ?? body['symptomList'];
    if (symptomsArray is List) {
      for (final s in symptomsArray) {
        if (s is String && s.trim().isNotEmpty) {
          symptoms.add(s.trim());
        } else if (s is Map && s['name'] is String) {
          symptoms.add(s['name'].toString().trim());
        }
      }
    }

    // Check for symptoms in the first prediction
    final predictions = body['predictions'];
    if (predictions is List && predictions.isNotEmpty) {
      final first = predictions.first;
      if (first is Map) {
        final predSymptoms = first['symptoms'] ?? first['symptom_list'];
        if (predSymptoms is List) {
          for (final s in predSymptoms) {
            if (s is String && s.trim().isNotEmpty) {
              symptoms.add(s.trim());
            }
          }
        }
      }
    }

    return symptoms;
  }

  String _buildConnectivityErrorMessage(List<String> attempts) {
    final attemptsSummary = attempts.isEmpty
        ? ''
        : ' Tried ${attempts.length} endpoint(s). Last attempt: ${attempts.last}.';

    return 'Cannot connect to AI service. Check NEXT_PUBLIC_API_URL and NEXT_PUBLIC_AI_URL in flutter/.env.$attemptsSummary';
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _diagnosis = null;
      _symptoms = null;
      _confidence = null;
    });

    try {
      final candidateUris = _resolveAiPredictUris();
      if (candidateUris.isEmpty) {
        setState(() {
          _diagnosis =
              'No AI endpoint configured. Add NEXT_PUBLIC_API_URL and NEXT_PUBLIC_AI_URL in flutter/.env.';
        });
        return;
      }

      final attempts = <String>[];
      http.Response? successResponse;

      for (final uri in candidateUris) {
        try {
          final request = http.MultipartRequest('POST', uri);
          request.files.add(
            await http.MultipartFile.fromPath('image', _imageFile!.path),
          );
          request.files.add(
            await http.MultipartFile.fromPath('file', _imageFile!.path),
          );

          final streamed = await request.send().timeout(
            const Duration(seconds: 25),
          );
          final response = await http.Response.fromStream(streamed);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            successResponse = response;
            break;
          }

          attempts.add('${uri.toString()} -> HTTP ${response.statusCode}');
        } on TimeoutException {
          attempts.add('${uri.toString()} -> timed out');
        } on SocketException catch (e) {
          attempts.add('${uri.toString()} -> ${e.message}');
        } catch (e) {
          attempts.add('${uri.toString()} -> $e');
        }
      }

      if (successResponse == null) {
        setState(() {
          _diagnosis = _buildConnectivityErrorMessage(attempts);
        });
        return;
      }

      final decoded = json.decode(successResponse.body);
      final body = decoded is Map<String, dynamic> ? decoded : null;

      // Debug: print API response structure
      if (kDebugMode) {
        print('DEBUG API Response Body: $body');
        print('DEBUG Response Keys: ${body?.keys.toList()}');
      }

      setState(() {
        _diagnosis = _extractDiagnosis(body) ?? 'Unknown diagnosis';
        _symptoms = _extractSymptoms(body);
        _confidence = _extractConfidencePercent(body);
        if (kDebugMode) {
          print('DEBUG Extracted Confidence: $_confidence');
        }
      });
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
                                Text(
                                  'Analysis Results',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Disease Name
                                Text(
                                  'Disease Name',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _diagnosis!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Symptoms
                                if (_symptoms != null &&
                                    _symptoms!.isNotEmpty) ...[
                                  Text(
                                    'Symptoms',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _symptoms!
                                        .map(
                                          (symptom) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4.0,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '• ',
                                                  style: TextStyle(
                                                    color: cs.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    symptom,
                                                    style: TextStyle(
                                                      color: cs.onSurface,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                // Confidence
                                Text(
                                  'Confidence',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (_confidence != null)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: _confidence! / 100,
                                            minHeight: 8,
                                            backgroundColor: cs.outline
                                                .withOpacity(0.2),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  _confidence! >= 75
                                                      ? Colors.green
                                                      : _confidence! >= 50
                                                      ? Colors.orange
                                                      : Colors.red,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_confidence%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'N/A',
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                const SizedBox(height: 14),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: recs
                                          .map(
                                            (r) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                              ),
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
                icon: Icon(Icons.arrow_back, color: cs.onSurface, size: 28),
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
