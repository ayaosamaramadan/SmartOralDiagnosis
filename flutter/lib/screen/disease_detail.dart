import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const DiseaseDetailScreen({super.key, required this.item});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  String _assetPath(String path) => path.startsWith('/') ? path.substring(1) : path;

  Color get _bg => const Color(0xFF07101A);
  Color get _surface => const Color(0xFF0E1720);
  Color get _muted => const Color(0xFF9AA6B2);
  Color get _accent => const Color(0xFF60A5FA);

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6, right: 8), decoration: BoxDecoration(color: _accent, shape: BoxShape.circle)),
            Expanded(child: Text(text, style: GoogleFonts.poppins(color: _muted, fontSize: 14))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final title = item['title'] as String? ?? '';
    final description = item['description'] as String? ?? '';
    final overview = item['overview'] as String? ?? '';
    final imgList = item['img'] as List<dynamic>? ?? [];
    final symptoms = item['symptoms'] as Map<String, dynamic>?;
    final causes = item['causes'] as Map<String, dynamic>?;
    final prevention = item['prevention'] as Map<String, dynamic>?;
    final risk = item['riskFactors'];

    Widget? symptomsSection;
    Widget? causesSection;
    Widget? preventionSection;
    Widget? riskSection;

    if (symptoms != null) {
      final List<Widget> symptomChildren = [];
      symptomChildren.add(Text(symptoms['title'] as String? ?? 'Symptoms', style: GoogleFonts.poppins(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)));
      symptomChildren.add(const SizedBox(height: 8));
      if (symptoms['list'] is List) {
        for (var s in (symptoms['list'] as List)) {
          if (s is String) {
            symptomChildren.add(_bullet(s));
          } else {
            final List<Widget> entry = [];
            entry.add(Text(s['type'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)));
            if (s['desc'] != null && s['desc'].toString().isNotEmpty) entry.add(Padding(padding: const EdgeInsets.only(top: 6), child: Text(s['desc'], style: GoogleFonts.poppins(color: _muted))));
            if (s['dots'] is List) for (var d in (s['dots'] as List)) entry.add(_bullet(d.toString()));
            entry.add(const SizedBox(height: 8));
            symptomChildren.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: entry));
          }
        }
      }
      if (symptoms['WhenSeeDoctor'] is List) {
        for (var w in (symptoms['WhenSeeDoctor'] as List)) {
          final List<Widget> whenChildren = [];
          if (w['title'] != null) whenChildren.add(Padding(padding: const EdgeInsets.only(top: 8), child: Text(w['title'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600))));
          if (w['list'] is List) for (var li in (w['list'] as List)) whenChildren.add(_bullet(li.toString()));
          if (w['note'] != null) whenChildren.add(Padding(padding: const EdgeInsets.only(top: 6), child: Text(w['note'], style: GoogleFonts.poppins(color: _muted))));
          symptomChildren.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: whenChildren));
        }
      }
      symptomsSection = _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: symptomChildren));
    }

    if (causes != null) {
      final List<Widget> causeChildren = [];
      causeChildren.add(Text(causes['title'] as String? ?? 'Causes', style: GoogleFonts.poppins(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)));
      causeChildren.add(const SizedBox(height: 8));
      if (causes['triggers'] is List) {
        for (var t in (causes['triggers'] as List)) {
          final List<Widget> tChildren = [];
          if (t['title'] != null) tChildren.add(Padding(padding: const EdgeInsets.only(top: 6), child: Text(t['title'], style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600))));
          if (t['list'] is List) for (var li in (t['list'] as List)) tChildren.add(_bullet(li.toString()));
          causeChildren.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: tChildren));
        }
      }
      if (causes['conditions'] != null && causes['conditions']['list'] is List) {
        causeChildren.add(const SizedBox(height: 8));
        causeChildren.add(Text(causes['conditions']['title'] ?? '', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600)));
        causeChildren.add(const SizedBox(height: 6));
        for (var li in (causes['conditions']['list'] as List)) causeChildren.add(_bullet(li.toString()));
      }
      if (causes['note'] != null) causeChildren.add(Padding(padding: const EdgeInsets.only(top: 8), child: Text(causes['note'], style: GoogleFonts.poppins(color: _muted))));
      causesSection = _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: causeChildren));
    }

    if (risk != null) {
      riskSection = _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Risk Factors', style: GoogleFonts.poppins(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text(risk is String ? risk : (risk['title'] ?? ''), style: GoogleFonts.poppins(color: _muted))]));
    }

    if (prevention != null) {
      final List<Widget> prevChildren = [];
      prevChildren.add(Text(prevention['title'] as String? ?? 'Prevention', style: GoogleFonts.poppins(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)));
      prevChildren.add(const SizedBox(height: 8));
      if (prevention['list'] is List) for (var p in (prevention['list'] as List)) prevChildren.add(Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (p['tip'] != null) Text(p['tip'], style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)), if (p['desc'] != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(p['desc'], style: GoogleFonts.poppins(color: _muted)))])));
      preventionSection = _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: prevChildren));
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: GoogleFonts.poppins(color: const Color.fromARGB(205, 255, 255, 255),  fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imgList.isNotEmpty) ...[
                SizedBox(
                  height: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: imgList.length,
                          onPageChanged: (i) => setState(() => _pageIndex = i),
                          itemBuilder: (context, i) {
                            final raw = imgList[i] as String;
                            final path = _assetPath(raw);
                            return Image.asset(path, fit: BoxFit.cover, errorBuilder: (ctx, e, st) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54)));
                          },
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                            child: Text('${_pageIndex + 1} / ${imgList.length}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Row(
                            children: List.generate(
                              imgList.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _pageIndex == i ? 18 : 8,
                                height: 8,
                                decoration: BoxDecoration(color: _pageIndex == i ? _accent : Colors.white12, borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

               Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (description.isNotEmpty) Text(description, style: GoogleFonts.poppins(color: _muted, fontSize: 14)),

             
              if (overview.isNotEmpty) _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Overview', style: GoogleFonts.poppins(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text(overview, style: GoogleFonts.poppins(color: _muted))])),

              
              if (symptomsSection != null) symptomsSection,

             
              if (causesSection != null) causesSection,

            
              if (risk != null) _sectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Risk Factors', style: GoogleFonts.poppins(color: _accent, fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Text(risk is String ? risk : (risk['title'] ?? ''), style: GoogleFonts.poppins(color: _muted))])),

              if (riskSection != null) riskSection,
              if (preventionSection != null) preventionSection,

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}