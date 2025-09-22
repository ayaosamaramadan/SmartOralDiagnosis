import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnalysisArea {
  final double x;
  final double y;
  final double w;
  final double h;
  final String type;
  AnalysisArea({required this.x, required this.y, required this.w, required this.h, required this.type});
}

class AnalysisResult {
  final double confidence;
  final String diagnosis;
  final String severity; // 'low' | 'medium' | 'high'
  final List<String> recommendations;
  final List<AnalysisArea> areas;
  AnalysisResult({
    required this.confidence,
    required this.diagnosis,
    required this.severity,
    required this.recommendations,
    required this.areas,
  });
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  Uint8List? _webImageBytes;
  bool _isAnalyzing = false;
  AnalysisResult? _result;

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null;
          _result = null;
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _webImageBytes = null;
          _result = null;
        });
      }
    }
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null;
          _result = null;
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _webImageBytes = null;
          _result = null;
        });
      }
    }
  }

  Future<void> _analyze() async {
    if (_imageFile == null && _webImageBytes == null) return;
    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    await Future.delayed(const Duration(seconds: 3)); // Simulate API delay

    final random = Random();
    final mockAreas = List.generate(
      2,
      (i) => AnalysisArea(
        x: random.nextDouble() * 200,
        y: random.nextDouble() * 140,
        w: 40 + random.nextDouble() * 30,
        h: 30 + random.nextDouble() * 25,
        type: 'plaque',
      ),
    );

    setState(() {
      _result = AnalysisResult(
        confidence: 0.87,
        diagnosis: 'Mild Dental Plaque Buildup',
        severity: 'low',
        recommendations: [
          'Increase brushing frequency to twice daily',
          'Use fluoride toothpaste',
          'Schedule a professional cleaning',
          'Consider using an electric toothbrush',
        ],
        areas: mockAreas,
      );
      _isAnalyzing = false;
    });
  }

  void _reset() {
    setState(() {
      _imageFile = null;
      _webImageBytes = null;
      _result = null;
      _isAnalyzing = false;
    });
  }

  Color _severityColorBg(String s) {
    switch (s) {
      case 'low':
        return Colors.green.shade50;
      case 'medium':
        return Colors.yellow.shade50;
      case 'high':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _severityColorText(String s) {
    switch (s) {
      case 'low':
        return Colors.green.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'high':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    Color borderColor = const Color(0xFF374151),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          border: Border.all(color: borderColor, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    final imageWidget = _webImageBytes != null
        ? Image.memory(_webImageBytes!, fit: BoxFit.contain)
        : _imageFile != null
            ? Image.file(_imageFile!, fit: BoxFit.contain)
            : const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        const baseWidth = 400.0;
        const baseHeight = 300.0;

        return Center(
          child: AspectRatio(
            aspectRatio: baseWidth / baseHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: baseWidth,
                          height: baseHeight,
                          child: imageWidget,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_result != null)
                  ..._result!.areas.map(
                    (a) => Positioned(
                      left: a.x,
                      top: a.y,
                      width: a.w,
                      height: a.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.redAccent, width: 2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisPanel() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(strokeWidth: 5),
            ),
            SizedBox(height: 16),
            Text('Analyzing your image...',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_result == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _analyze,
          child: const Text(
            'Analyze Image',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      );
    }

    final r = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status
        const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF34D399)),
            SizedBox(width: 8),
            Text('Analysis Complete',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        // Diagnosis card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            border: Border.all(color: const Color(0xFF374151)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Diagnosis',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  r.diagnosis,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _severityColorBg(r.severity),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${r.severity.toUpperCase()} RISK',
                        style: TextStyle(
                          color: _severityColorText(r.severity),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(r.confidence * 100).toStringAsFixed(0)}% confidence',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ]),
        ),
        const SizedBox(height: 16),
        // Recommendations
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.4),
            border: Border.all(color: const Color(0xFF1D4ED8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.info, size: 18, color: Color(0xFF60A5FA)),
                  SizedBox(width: 6),
                  Text('Recommendations',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF93C5FD))),
                ]),
                const SizedBox(height: 10),
                ...r.recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• $rec',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    )),
              ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _reset,
            child: const Text('Scan Another Image'),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Smart Oral Diagnosis',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile == null && _webImageBytes == null) ...[
              Text(
                'Take a photo or upload an image for AI-powered dental analysis',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Flex(
                    direction: constraints.maxWidth < 700
                        ? Axis.vertical
                        : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.photo_camera_outlined,
                          title: 'Take Photo',
                          description: 'Use your camera to capture an image',
                          onTap: _pickFromCamera,
                        ),
                      ),
                      const SizedBox(width: 20, height: 20),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.upload_file_outlined,
                          title: 'Upload Image',
                          description: 'Drag and drop or click to select',
                          onTap: _pickFromGallery,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ] else ...[
              // Header for analysis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    tooltip: 'Start Over',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // IMAGE + ANALYSIS
              LayoutBuilder(
                builder: (context, constraints) {
                  return Flex(
                    direction: constraints.maxWidth < 800
                        ? Axis.vertical
                        : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: constraints.maxWidth < 800 ? 0 : 1,
                        child: _buildImageWithOverlay(),
                      ),
                      const SizedBox(width: 24, height: 24),
                      Expanded(
                        flex: constraints.maxWidth < 800 ? 0 : 1,
                        child: _buildAnalysisPanel(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
