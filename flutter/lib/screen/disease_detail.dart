import 'package:flutter/material.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  const DiseaseDetailScreen({super.key, required this.item});

  String _assetPath(String path) => path.startsWith('/') ? path.substring(1) : path;

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(text, style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final title = item['title'] as String? ?? '';
    final description = item['description'] as String? ?? '';
    final overview = item['overview'] as String? ?? '';
    final imgList = item['img'] as List<dynamic>? ?? [];
    final symptoms = item['symptoms'] as Map<String, dynamic>?;
    final causes = item['causes'] as Map<String, dynamic>?;
    final prevention = item['prevention'] as Map<String, dynamic>?;
    final risk = item['riskFactors'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imgList.isNotEmpty) ...[
              SizedBox(
                height: 220,
                child: PageView(
                  children: imgList.map((raw) {
                    final path = _assetPath(raw as String);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, e, st) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54))),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (description.isNotEmpty) Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),

            if (overview.isNotEmpty) ...[
              _sectionTitle('Overview'),
              Text(overview, style: const TextStyle(color: Colors.white70)),
            ],

            if (symptoms != null) ...[
              const SizedBox(height: 12),
              _sectionTitle(symptoms['title'] as String? ?? 'Symptoms'),
              if (symptoms['list'] is List) ...((symptoms['list'] as List).map<Widget>((s) => ListTile(leading: const Icon(Icons.check_circle_outline, color: Colors.blueAccent), title: Text((s is String) ? s : (s['type'] ?? ''), style: const TextStyle(color: Colors.white70)), subtitle: s is Map && s['desc'] != null ? Text(s['desc'], style: const TextStyle(color: Colors.white54)) : null)).toList()),
              if (symptoms['WhenSeeDoctor'] is List) ...((symptoms['WhenSeeDoctor'] as List).map<Widget>((w) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (w['title'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(w['title'], style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))), if (w['list'] is List) ...((w['list'] as List).map<Widget>((li) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• $li', style: const TextStyle(color: Colors.white70)))).toList()), if (w['note'] != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(w['note'], style: const TextStyle(color: Colors.white54))),])).toList()),
            ],

            if (causes != null) ...[
              const SizedBox(height: 12),
              _sectionTitle(causes['title'] as String? ?? 'Causes'),
              if (causes['triggers'] is List) ...((causes['triggers'] as List).map<Widget>((t) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (t['title'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(t['title'], style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))), if (t['list'] is List) ...((t['list'] as List).map<Widget>((li) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• $li', style: const TextStyle(color: Colors.white70)))).toList())])).toList()),
              if (causes['conditions'] != null && causes['conditions']['list'] is List) ...[
                const SizedBox(height: 8),
                Text(causes['conditions']['title'] ?? '', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...((causes['conditions']['list'] as List).map((li) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• $li', style: const TextStyle(color: Colors.white70)))).toList())
              ],
              if (causes['note'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(causes['note'], style: const TextStyle(color: Colors.white54))),
            ],

            if (risk != null) ...[
              const SizedBox(height: 12),
              _sectionTitle('Risk Factors'),
              Text(risk is String ? risk : (risk['title'] ?? ''), style: const TextStyle(color: Colors.white70)),
            ],

            if (prevention != null) ...[
              const SizedBox(height: 12),
              _sectionTitle(prevention['title'] as String? ?? 'Prevention'),
              if (prevention['list'] is List) ...((prevention['list'] as List).map<Widget>((p) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (p['tip'] != null) Text(p['tip'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)), if (p['desc'] != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(p['desc'], style: const TextStyle(color: Colors.white70)))]))).toList()),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}