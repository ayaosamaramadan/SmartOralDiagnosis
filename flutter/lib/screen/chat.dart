import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const List<String> _discoveryPrompts = [
    'What are early signs of gum disease?',
    'How can I reduce tooth sensitivity at home?',
    'When is a toothache considered urgent?',
  ];

  static const _systemPrompt =
      'You are SmartOralDiagnosis assistant. Help users with oral-health information in clear language. '
      'Do not claim certainty for diagnosis and advise seeing a licensed dentist for urgent or severe symptoms.';
  static const _geminiApiRoot = 'https://generativelanguage.googleapis.com/v1';
  static const _defaultGeminiModel = 'gemini-2.0-flash';
  static const List<String> _fallbackGeminiModels = <String>[
    'gemini-2.0-flash-lite',
    _defaultGeminiModel,
  ];

  static const _starterMessage = _UiMessage(
    id: 'starter',
    role: _ChatRole.assistant,
    content:
        'Hi, I am your oral-health assistant. Describe your symptoms and I will help with guidance.',
  );

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  List<_UiMessage> _messages = const [_starterMessage];
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _canSend => _inputController.text.trim().isNotEmpty && !_sending;

  String get _geminiApiKey => dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

  String get _configuredGeminiModel {
    final configured = dotenv.env['GEMINI_MODEL']?.trim() ?? '';
    return configured.isEmpty ? _defaultGeminiModel : _normalizeModelName(configured);
  }

  String? get _configuredChatApiUrl {
    final explicit = dotenv.env['CHATBOT_API_URL']?.trim() ?? '';
    if (explicit.isNotEmpty) return explicit;

    final base = dotenv.env['CHATBOT_BASE_URL']?.trim() ?? '';
    if (base.isNotEmpty) {
      final normalized = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      return '$normalized/api/chatbot';
    }

    return null;
  }

  String get _defaultChatApiUrl {
    if (kIsWeb) return 'http://localhost:3000/api/chatbot';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/chatbot';
    }
    return 'http://localhost:3000/api/chatbot';
  }

  String _normalizeModelName(String modelName) {
    return modelName.replaceFirst(RegExp(r'^models/', caseSensitive: false), '').trim();
  }

  bool _isModelError(String errorMessage) {
    return RegExp(
      r'model|does not exist|not found|is not a valid|not supported.*generatecontent',
      caseSensitive: false,
    ).hasMatch(errorMessage);
  }

  List<String> _uniqueModelNames(Iterable<String> modelNames) {
    final seen = <String>{};
    final result = <String>[];

    for (final modelName in modelNames) {
      final normalized = _normalizeModelName(modelName);
      if (normalized.isEmpty || seen.contains(normalized)) continue;
      seen.add(normalized);
      result.add(normalized);
    }

    return result;
  }

  Map<String, dynamic>? _tryParseJsonObject(String rawText) {
    if (rawText.trim().isEmpty) return null;
    try {
      final parsed = jsonDecode(rawText);
      if (parsed is Map<String, dynamic>) return parsed;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(Map<String, dynamic>? data, String fallback) {
    final error = data?['error'];
    if (error is Map && error['message'] is String) {
      final msg = (error['message'] as String).trim();
      if (msg.isNotEmpty) return msg;
    }

    final message = data?['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    return fallback;
  }

  String? _extractGeminiReply(Map<String, dynamic>? data) {
    final candidates = data?['candidates'];
    if (candidates is! List) return null;

    for (final candidate in candidates) {
      if (candidate is! Map) continue;
      final content = candidate['content'];
      if (content is! Map) continue;
      final parts = content['parts'];
      if (parts is! List) continue;

      for (final part in parts) {
        if (part is! Map) continue;
        final text = part['text'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
      }
    }

    return null;
  }

  Future<List<String>> _listGenerateContentModels(String geminiKey) async {
    final listUrl = '$_geminiApiRoot/models?key=${Uri.encodeQueryComponent(geminiKey)}';
    final listRes = await http
        .get(
          Uri.parse(listUrl),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));

    if (listRes.statusCode < 200 || listRes.statusCode >= 300) {
      return const [];
    }

    final listData = _tryParseJsonObject(listRes.body);
    final allModels = listData?['models'];
    if (allModels is! List) {
      return const [];
    }

    final supportedModels = <String>[];
    for (final model in allModels) {
      if (model is! Map) continue;
      final name = model['name'];
      final methods = model['supportedGenerationMethods'];
      if (name is String && methods is List && methods.contains('generateContent')) {
        supportedModels.add(name);
      }
    }

    return _uniqueModelNames(supportedModels);
  }

  Future<_GeminiCallResult> _callGemini({
    required String geminiKey,
    required String modelName,
    required List<_UiMessage> messages,
  }) async {
    final normalizedModelName = _normalizeModelName(modelName);
    final url =
        '$_geminiApiRoot/models/$normalizedModelName:generateContent?key=${Uri.encodeQueryComponent(geminiKey)}';

    final sanitizedMessages = messages
        .where((m) => m.content.trim().isNotEmpty)
        .map(
          (m) => {
            'role': m.role == _ChatRole.assistant ? 'model' : 'user',
            'parts': [
              {'text': m.content.trim()},
            ],
          },
        )
        .toList(growable: false);

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': _systemPrompt},
                ],
              },
              ...sanitizedMessages,
            ],
            'generationConfig': {'temperature': 0.4},
          }),
        )
        .timeout(const Duration(seconds: 45));

    return _GeminiCallResult(
      statusCode: response.statusCode,
      data: _tryParseJsonObject(response.body),
      modelName: normalizedModelName,
    );
  }

  Future<String> _requestChatbotProxyReply({
    required String apiUrl,
    required List<_UiMessage> messages,
  }) async {
    final response = await http
        .post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'messages': messages
                .map(
                  (m) => {
                    'role': m.role == _ChatRole.user ? 'user' : 'assistant',
                    'content': m.content,
                  },
                )
                .toList(),
          }),
        )
        .timeout(const Duration(seconds: 45));

    final rawText = response.body;
    Map<String, dynamic>? data;

    if (rawText.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(rawText);
        if (parsed is Map<String, dynamic>) {
          data = parsed;
        } else {
          throw const FormatException('Invalid JSON object');
        }
      } on FormatException {
        final snippet = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
        final clipped = snippet.length > 120 ? snippet.substring(0, 120) : snippet;
        if (snippet.startsWith('<!DOCTYPE') || snippet.startsWith('<html')) {
          throw Exception(
            'Chat API returned HTML instead of JSON. Check that Next frontend is running and /api/chatbot is reachable.',
          );
        }
        throw Exception('Chat API returned non-JSON response: $clipped');
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data?['message']?.toString() ?? 'Failed to get AI response');
    }

    final reply = data?['reply']?.toString().trim() ?? '';
    if (reply.isEmpty) {
      throw Exception('AI returned an empty response');
    }
    return reply;
  }

  Future<String> _requestDirectGeminiReply({required List<_UiMessage> messages}) async {
    final geminiKey = _geminiApiKey;
    if (geminiKey.isEmpty) {
      throw Exception('Missing GEMINI_API_KEY in flutter/.env');
    }

    final initialCandidates = _uniqueModelNames([
      _configuredGeminiModel,
      ..._fallbackGeminiModels,
    ]);

    if (initialCandidates.isEmpty) {
      throw Exception('No valid Gemini model configured');
    }

    List<String> availableModels = const [];
    var result = await _callGemini(
      geminiKey: geminiKey,
      modelName: initialCandidates.first,
      messages: messages,
    );

    if (!result.isOk) {
      final errMsg = _extractErrorMessage(result.data, 'Gemini request failed');
      if (_isModelError(errMsg)) {
        availableModels = await _listGenerateContentModels(geminiKey);
        final retryCandidates = _uniqueModelNames([
          ...initialCandidates.skip(1),
          ...availableModels,
        ]).where((name) => name != result.modelName);

        for (final candidate in retryCandidates) {
          result = await _callGemini(
            geminiKey: geminiKey,
            modelName: candidate,
            messages: messages,
          );

          if (result.isOk) break;
          final nextErrMsg = _extractErrorMessage(result.data, 'Gemini request failed');
          if (!_isModelError(nextErrMsg)) break;
        }
      }
    }

    if (!result.isOk) {
      final errorMessage = _extractErrorMessage(result.data, 'Gemini request failed');
      if (_isModelError(errorMessage) && availableModels.isNotEmpty) {
        final suggestedModels = availableModels.take(5).join(', ');
        throw Exception('$errorMessage Try one of: $suggestedModels');
      }
      throw Exception(errorMessage);
    }

    final reply = _extractGeminiReply(result.data);
    if (reply == null || reply.isEmpty) {
      throw Exception('Gemini returned an empty response');
    }

    return reply;
  }

  Future<String> _requestAssistantReply(List<_UiMessage> conversation) async {
    final configuredChatApiUrl = _configuredChatApiUrl;
    if (configuredChatApiUrl != null) {
      try {
        return await _requestChatbotProxyReply(
          apiUrl: configuredChatApiUrl,
          messages: conversation,
        );
      } catch (_) {
        if (_geminiApiKey.isNotEmpty) {
          return _requestDirectGeminiReply(messages: conversation);
        }
        rethrow;
      }
    }

    if (_geminiApiKey.isNotEmpty) {
      return _requestDirectGeminiReply(messages: conversation);
    }

    return _requestChatbotProxyReply(
      apiUrl: _defaultChatApiUrl,
      messages: conversation,
    );
  }

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _resetChat() {
    setState(() {
      _messages = const [_starterMessage];
      _inputController.clear();
      _error = null;
    });
    _scrollToBottom();
  }

  void _applyDiscoverPrompt() {
    final prompt = _discoveryPrompts[_random.nextInt(_discoveryPrompts.length)];
    _inputController
      ..text = prompt
      ..selection = TextSelection.collapsed(offset: prompt.length);
  }

  Future<void> _sendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty || _sending) return;

    final userMessage = _UiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}-u',
      role: _ChatRole.user,
      content: content,
    );

    setState(() {
      _messages = [..._messages, userMessage];
      _inputController.clear();
      _sending = true;
      _error = null;
    });
    _scrollToBottom();

    try {
      final reply = await _requestAssistantReply(_messages);

      setState(() {
        _messages = [
          ..._messages,
          _UiMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}-a',
            role: _ChatRole.assistant,
            content: reply,
          ),
        ];
      });
    } on TimeoutException {
      setState(() {
        _error = 'Request timed out. Please try again.';
      });
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      setState(() {
        _error = msg.isEmpty ? 'Something went wrong' : msg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFF9FAFB);
    final headerColor = isDark ? const Color(0xFF0F1724) : Colors.white;
    final headerBorder = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final headerText = isDark ? const Color(0xFFE6EEFB) : const Color(0xFF111827);
    final actionBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    final actionText = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
    final containerColor = isDark ? const Color(0xFF0B1220) : Colors.white;
    final containerBorder = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final containerShadow = isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.04);
    final surfaceFade = isDark ? const Color(0xFF111827) : const Color(0xFFEFF6FF);

    final width = MediaQuery.of(context).size.width;
    final compact = width < 480;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: bgColor,
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: headerColor,
                    border: Border(
                      bottom: BorderSide(color: headerBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chat',
                        style: TextStyle(
                          color: headerText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          if (compact) ...[
                            IconButton(
                              onPressed: _applyDiscoverPrompt,
                              icon: Icon(Icons.explore, color: actionText, size: 20),
                              tooltip: 'Discover',
                              style: IconButton.styleFrom(
                                backgroundColor: actionBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: _resetChat,
                              icon: Icon(Icons.edit, color: actionText, size: 20),
                              tooltip: 'New Chat',
                              style: IconButton.styleFrom(
                                backgroundColor: actionBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ] else ...[
                            _ActionButton(
                              icon: Icons.explore,
                              label: 'Discover',
                              onPressed: _applyDiscoverPrompt,
                            ),
                            const SizedBox(width: 8),
                            _ActionButton(
                              icon: Icons.edit,
                              label: 'New Chat',
                              onPressed: _resetChat,
                            ),
                          ],
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: actionText, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: actionBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    constraints: const BoxConstraints(minWidth: 200),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: containerBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: containerShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [containerColor, surfaceFade],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(14),
                              itemCount: _messages.length + (_sending ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (_sending && index == _messages.length) {
                                  return const _TypingBubble();
                                }

                                final msg = _messages[index];
                                return _MessageBubble(message: msg);
                              },
                            ),
                          ),
                        ),
                        if (_error != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFFECACA) : const Color(0xFFB91C1C),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: containerBorder),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _sendMessage(),
                                  decoration: InputDecoration(
                                    hintText: 'Ask about oral symptoms, care, or prevention...',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                                    ),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF111827) : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: containerBorder),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: containerBorder),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton(
                                onPressed: _canSend ? _sendMessage : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      isDark ? const Color(0xFF1F2937) : const Color(0xFFD1D5DB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                child: _sending
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Send'),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Text(
                            'This assistant gives general information and does not replace professional medical care.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeminiCallResult {
  final int statusCode;
  final Map<String, dynamic>? data;
  final String modelName;

  const _GeminiCallResult({
    required this.statusCode,
    required this.data,
    required this.modelName,
  });

  bool get isOk => statusCode >= 200 && statusCode < 300;
}

enum _ChatRole { user, assistant }

class _UiMessage {
  final String id;
  final _ChatRole role;
  final String content;

  const _UiMessage({
    required this.id,
    required this.role,
    required this.content,
  });
}

class _MessageBubble extends StatelessWidget {
  final _UiMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.role == _ChatRole.user;

    final userBg = const Color(0xFF2563EB);
    final assistantBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    final assistantText = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF111827);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? userBg : assistantBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 14),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : assistantText,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Text(
          'Typing...',
          style: TextStyle(
            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    final fg = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

