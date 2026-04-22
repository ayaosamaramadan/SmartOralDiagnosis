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
import '../services/api.dart';

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

  String? _extractSchemeAndHost(String rawUrl) {
    final parsed = Uri.tryParse(rawUrl);
    if (parsed == null || parsed.host.isEmpty) return null;

    final scheme = parsed.scheme.isEmpty ? 'http' : parsed.scheme;
    return '$scheme://${parsed.host}';
  }

  bool _isLoopbackHost(String host) {
    final normalized = host.trim().toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '::1' ||
        normalized == '10.0.2.2';
  }

  bool _isLoopbackUrl(String rawUrl) {
    final normalized = _withDefaultScheme(rawUrl);
    final parsed = Uri.tryParse(normalized);
    if (parsed == null || parsed.host.isEmpty) return false;
    return _isLoopbackHost(parsed.host);
  }

  List<Uri> _resolveAiPredictUris() {
    final candidates = <String>[];
    var hasExplicitRemoteAiEndpoint = false;

    final explicitPredictUrl = _readEnv('AI_PREDICT_URL');
    final explicitAiBaseUrl = _readEnv('AI_BASE_URL');
    final normalizedPredictUrl = _withDefaultScheme(explicitPredictUrl);
    final normalizedAiBaseUrl = _withDefaultScheme(explicitAiBaseUrl);

    if (normalizedPredictUrl.isNotEmpty) {
      candidates.add(normalizedPredictUrl);
      if (!_isLoopbackUrl(normalizedPredictUrl)) {
        hasExplicitRemoteAiEndpoint = true;
      }
    }
    if (normalizedAiBaseUrl.isNotEmpty) {
      final normalizedBase = _normalizeBaseUrl(normalizedAiBaseUrl);
      if (normalizedBase.toLowerCase().endsWith('/predict')) {
        candidates.add(normalizedBase);
      } else {
        candidates.add('$normalizedBase/predict');
      }
      if (!_isLoopbackUrl(normalizedBase)) {
        hasExplicitRemoteAiEndpoint = true;
      }
    }

    final configuredApiUrl = _readEnv('API_URL');
    final backendBase = _withDefaultScheme(
      configuredApiUrl.isNotEmpty ? configuredApiUrl : Api.baseUrl,
    );
    final normalizedBackendBase = _normalizeBaseUrl(backendBase);
    final backendBaseUri = Uri.tryParse(normalizedBackendBase);
    final backendIsLoopback =
        backendBaseUri != null && _isLoopbackHost(backendBaseUri.host);
    if (!(backendIsLoopback && hasExplicitRemoteAiEndpoint)) {
      candidates.add('$normalizedBackendBase/api/ai/predict');
      candidates.add('$normalizedBackendBase/ai/predict');
      candidates.add('$normalizedBackendBase/predict');
    }

    final apiHost = configuredApiUrl.isEmpty
        ? _extractSchemeAndHost(Api.baseUrl)
        : _extractSchemeAndHost(_withDefaultScheme(configuredApiUrl));

    if (apiHost != null) {
      final apiHostUri = Uri.tryParse(apiHost);
      final apiHostIsLoopback =
          apiHostUri != null && _isLoopbackHost(apiHostUri.host);
      if (!(apiHostIsLoopback && hasExplicitRemoteAiEndpoint)) {
        candidates.add('$apiHost:8000/predict');
        candidates.add('$apiHost:8001/predict');
      }
    }

    if (kIsWeb) {
      candidates.add('http://localhost:8000/predict');
      candidates.add('http://localhost:8001/predict');
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Only use Android loopback fallbacks when no explicit LAN/public AI URL is configured.
      if (!hasExplicitRemoteAiEndpoint) {
        candidates.add('http://10.0.2.2:8000/predict');
        candidates.add('http://10.0.2.2:8001/predict');
        candidates.add('http://127.0.0.1:8000/predict');
        candidates.add('http://127.0.0.1:8001/predict');
        candidates.add('http://localhost:8000/predict');
        candidates.add('http://localhost:8001/predict');
      }
    } else {
      candidates.add('http://localhost:8000/predict');
      candidates.add('http://localhost:8001/predict');
    }

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

  String _buildConnectivityErrorMessage(List<String> attempts) {
    final hasExplicitAiUrl =
        _readEnv('AI_PREDICT_URL').isNotEmpty ||
        _readEnv('AI_BASE_URL').isNotEmpty;
    final hasApiUrl = _readEnv('API_URL').isNotEmpty;

    final attemptsSummary = attempts.isEmpty
        ? ''
        : ' Tried ${attempts.length} endpoint(s). Last attempt: ${attempts.last}.';
    final androidHint =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'On a real Android phone, 10.0.2.2 works only for emulator. '
        : '';

    final setupHint = (hasExplicitAiUrl || hasApiUrl)
        ? 'Check that your AI server is running and reachable from this device.'
        : 'Set API_URL and/or AI_BASE_URL in flutter/.env to your PC LAN IP, then start FastAPI with --host 0.0.0.0.';

    return 'Cannot connect to AI service. $androidHint$setupHint$attemptsSummary';
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _diagnosis = null;
      _confidence = null;
    });

    try {
      final candidateUris = _resolveAiPredictUris();
      if (candidateUris.isEmpty) {
        setState(() {
          _diagnosis =
              'No AI endpoint configured. Add AI_BASE_URL in flutter/.env.';
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

      setState(() {
        _diagnosis = _extractDiagnosis(body) ?? 'Unknown diagnosis';
        _confidence = _extractConfidencePercent(body);
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
                                        '$_confidence% confidence',
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
