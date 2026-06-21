import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tokenController = TextEditingController();
  final _headerController = TextEditingController();
  final _prefixController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final token = await readToken() ?? '';
    final header = await readAuthHeader() ?? dotenv.env['AI_AUTH_HEADER'] ?? 'Authorization';
    final prefix = await readAuthPrefix() ?? dotenv.env['AI_AUTH_PREFIX'] ?? 'Bearer';

    setState(() {
      _tokenController.text = token;
      _headerController.text = header;
      _prefixController.text = prefix;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final token = _tokenController.text.trim();
    final header = _headerController.text.trim();
    final prefix = _prefixController.text.trim();
    if (token.isNotEmpty) await storeToken(token);
    await storeAuthHeader(header);
    await storeAuthPrefix(prefix);
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved authentication settings.')));
  }

  Future<void> _clear() async {
    setState(() => _loading = true);
    await clearAuthSettings();
    _tokenController.clear();
    _headerController.text = dotenv.env['AI_AUTH_HEADER'] ?? 'Authorization';
    _prefixController.text = dotenv.env['AI_AUTH_PREFIX'] ?? 'Bearer';
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cleared authentication settings.')));
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _headerController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final aiBase = dotenv.env['AI_BASE_URL'] ?? dotenv.env['AI_BASEURL'] ?? '';
    final aiPredict = dotenv.env['AI_PREDICT_URL'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI service base URL', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                    const SizedBox(height: 6),
                    Text(aiBase.isEmpty ? '(not configured in .env)' : aiBase),
                    const SizedBox(height: 12),
                    Text('AI predict URL', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                    const SizedBox(height: 6),
                    Text(aiPredict.isEmpty ? '(not configured in .env)' : aiPredict),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(labelText: 'AI Token', hintText: 'Paste your token here'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _headerController,
                      decoration: const InputDecoration(labelText: 'Auth Header', hintText: 'Authorization or x-api-key'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _prefixController,
                      decoration: const InputDecoration(labelText: 'Auth Prefix', hintText: 'Bearer (leave empty for raw key)'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clear,
                            child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Tips:'),
                    const SizedBox(height: 6),
                    const Text('- Paste the token you get from your backend Railway link.'),
                    const Text('- Use header = Authorization and prefix = Bearer for JWT tokens.'),
                    const Text('- Use header = x-api-key and empty prefix for simple API keys.'),
                  ],
                ),
              ),
            ),
    );
  }
}
