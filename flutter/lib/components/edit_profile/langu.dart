import 'package:flutter/material.dart';

class Langu extends StatefulWidget {
  final void Function(String code)? onChanged;
  final String initial;

  const Langu({super.key, this.onChanged, this.initial = 'en'});

  @override
  State<Langu> createState() => _LanguState();
}

class _LanguState extends State<Langu> {
  String _selected = 'en';

  final languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'fr', 'name': 'Français'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }
  

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Change language',
      onSelected: (val) {
        setState(() => _selected = val);
        widget.onChanged?.call(val);
      },
      itemBuilder: (context) => languages
          .map(
            (l) => PopupMenuItem<String>(
              value: l['code']!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.blue.shade50 : Colors.blue.shade700,
                        child: Text((l['name'] as String)[0], style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l['name']!, style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text(l['code']!, style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  if (_selected == l['code']) Icon(Icons.check, color: Colors.green[600])
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.language),
      ),
    );
  }
}
