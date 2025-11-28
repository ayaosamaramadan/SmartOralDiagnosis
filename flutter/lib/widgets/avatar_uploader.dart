import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AvatarUploader extends StatefulWidget {
  final String initials;
  final String? initialUrl;
  final String? userId;
  final ValueChanged<String>? onUploaded;

  const AvatarUploader({super.key, required this.initials, this.initialUrl, this.userId, this.onUploaded});

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  File? _file;
  String? _photoUrl;
  bool _uploading = false;

  static const String apiBase = 'http://10.0.2.2:5000';

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.initialUrl;
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _file = File(picked.path);
      _uploading = true;
    });

    try {
      final storage = const FlutterSecureStorage();
      final jwt = await storage.read(key: 'jwt');
      final uri = Uri.parse('$apiBase/api/Uploads/profile-photo');
      final req = http.MultipartRequest('POST', uri);
      req.files.add(await http.MultipartFile.fromPath('file', _file!.path));
      if (widget.userId != null) req.fields['userId'] = widget.userId!;
      if (jwt != null) req.headers['Authorization'] = 'Bearer $jwt';

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final url = body['photoUrl'] ?? body['filePath'] ?? body['photoId'];
        String photoUrl = url is String ? url : url.toString();
        // If backend returned a relative path, prefix with base
        if (photoUrl.startsWith('/') ) photoUrl = '$apiBase$photoUrl';

        // Update stored user object
        try {
          final raw = await storage.read(key: 'user');
          if (raw != null) {
            final Map<String, dynamic> user = Map<String, dynamic>.from(jsonDecode(raw));
            user['photo'] = photoUrl;
            await storage.write(key: 'user', value: jsonEncode(user));
          }
        } catch (_) {}

        setState(() {
          _photoUrl = photoUrl;
          _uploading = false;
        });

        widget.onUploaded?.call(photoUrl);
      } else {
        setState(() => _uploading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${resp.statusCode}')));
      }
    } catch (e) {
      setState(() => _uploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayImage = _photoUrl;

    return InkWell(
      onTap: _uploading ? null : _pickAndUpload,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.onPrimary.withOpacity(0.16),
            backgroundImage: displayImage != null ? NetworkImage(displayImage) as ImageProvider : null,
            child: displayImage == null
                ? Text(widget.initials, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold))
                : null,
          ),
          if (_uploading)
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle, boxShadow: [BoxShadow(color: cs.shadow.withOpacity(0.12), blurRadius: 4)]),
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.camera_alt, size: 16, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}
