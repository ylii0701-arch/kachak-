import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/map_keys.dart';
import '../data/species_data.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';

class AssistantPanel extends StatefulWidget {
  const AssistantPanel({
    super.key,
    this.showBackButton = false,
    this.onBack,
    this.onClose,
  });

  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  State<AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<AssistantPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  _PendingRequest? _pendingRequest;
  bool _isAssistantTyping = false;
  static const String _irrelevantMessage =
      'This is unrelated to wildlife photography. Please try another question.';
  static const Set<String> _wildlifePhotographyKeywords = {
    'wildlife',
    'species',
    'animal',
    'animals',
    'bird',
    'birds',
    'mammal',
    'mammals',
    'reptile',
    'reptiles',
    'amphibian',
    'amphibians',
    'insect',
    'insects',
    'frog',
    'hornbill',
    'bear',
    'orangutan',
    'monkey',
    'tapir',
    'tiger',
    'elephant',
    'camera',
    'digicam',
    'compact camera',
    'point and shoot',
    'phone',
    'mobile',
    'smartphone',
    'iphone',
    'android',
    'settings',
    'gear',
    'lens',
    'tripod',
    'iso',
    'aperture',
    'shutter',
    'focus',
    'macro',
    'telephoto',
    'composition',
    'shoot',
    'shooting',
    'photo',
    'photography',
    'rainforest',
    'checklist',
    'weather',
    'forecast',
    'temperature',
    'humidity',
    'rain',
    'sunny',
    'cloudy',
    'windy',
    'storm',
    'map',
    'location',
    'region',
    'city',
    'distance',
    'where',
    'nearby',
    'route',
    'travel',
    'outdoor',
  };

  static const List<String> _suggestions = [
    'What camera settings should I use for birds in flight?',
    'Recommend equipment for photographing nocturnal animals',
    'Best settings for macro photography of insects',
    'What should I bring for a rainforest shoot?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage.assistant(
        "Hello! I'm your KaChak assistant. What would you like to know?",
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    final question = _inputController.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage.user(question));
      _inputController.clear();
    });
    _scrollToBottom();

    final pending = _pendingRequest;
    if (pending != null) {
      _pendingRequest = null;
      final prompt = _composePromptWithClarification(
        originalQuestion: pending.originalQuestion,
        clarification: question,
        type: pending.type,
      );
      await _replyWithGemini(prompt);
      return;
    }

    if (!_isWildlifePhotographyRelevant(question)) {
      setState(() {
        _messages.add(_ChatMessage.assistant(_irrelevantMessage));
      });
      _scrollToBottom();
      return;
    }

    await _replyWithGemini(question);
  }

  void _onSuggestionTap(String suggestion) {
    setState(() {
      _messages.add(_ChatMessage.user(suggestion));
      if (suggestion == _suggestions.last) {
        _pendingRequest = _PendingRequest(
          originalQuestion: suggestion,
          type: _PendingType.targetAnimal,
        );
        _messages.add(
          _ChatMessage.assistant(
            'Please clarify your target animal first so I can prepare the right checklist.',
          ),
        );
      } else {
        _pendingRequest = _PendingRequest(
          originalQuestion: suggestion,
          type: _PendingType.gear,
        );
        _messages.add(
          _ChatMessage.assistant(
            'Please share your camera and lens so I can tailor the settings.',
          ),
        );
      }
    });
    _scrollToBottom();
  }

  Future<void> _replyWithGemini(String userPrompt) async {
    setState(() => _isAssistantTyping = true);
    _scrollToBottom();

    final reply = await _fetchGeminiReply(userPrompt);
    if (!mounted) return;

    setState(() {
      _isAssistantTyping = false;
      _messages.add(_ChatMessage.assistant(reply));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<String> _fetchGeminiReply(String userPrompt) async {
    if (geminiApiKey.isEmpty) {
      return 'Gemini API key is missing. Please run with --dart-define=GEMINI_API_KEY=...';
    }

    const systemInstruction = '''
You are KaChak assistant for beginner wildlife photographers in Malaysia.
Give practical, concise advice with clear sections.
Only answer questions relevant to this app context:
- wildlife photography guidance
- target species and shooting preparation
- weather/forecast suitability for shooting
- location/map planning for wildlife photography trips
If the message is unrelated, reply exactly with:
This is unrelated to wildlife photography. Please try another question.

If user asks about settings/tips, use:
Settings:
- ...
Tips:
- ...
Explanation:
...
Simple terms:
- term: simple meaning

If user asks about trip preparation, use:
Preparation checklist
Photography equipment:
- ...
Outdoor essentials:
- ...
Weather note:
...

Keep wording simple and avoid jargon when possible.
Keep replies concise:
- Prefer short answers over long essays.
- Maximum around 140 words unless user explicitly asks for detailed explanation.
- Use only the most useful settings/tips first.
If user mentions phone/digicam/compact camera, give practical advice for that gear.
''';

    final payload = <String, dynamic>{
      'systemInstruction': {
        'parts': [
          {'text': systemInstruction},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userPrompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.4,
        'topP': 0.9,
        'maxOutputTokens': 1100,
      },
    };

    const models = <String>[
      'gemini-3.1-flash-lite-preview',
      'gemini-2.5-flash',
      'gemini-1.5-flash',
    ];

    String? lastError;
    try {
      for (final model in models) {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$geminiApiKey',
        );
        http.Response? response;
        for (var attempt = 0; attempt < 2; attempt++) {
          response = await http
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(payload),
              )
              .timeout(const Duration(seconds: 25));
          // Retry once for temporary overload.
          if (response.statusCode == 503 && attempt == 0) {
            await Future<void>.delayed(const Duration(milliseconds: 800));
            continue;
          }
          break;
        }
        if (response == null) {
          return 'Gemini request did not return a response. Please try again.';
        }

        if (response.statusCode != 200) {
          lastError = _extractGeminiError(response);
          // Try next model if this one is unavailable on the current key/project.
          if (response.statusCode == 404) {
            continue;
          }
          return lastError;
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          return 'Gemini returned an empty response. Please try again.';
        }

        final content = candidates.first['content'] as Map<String, dynamic>?;
        final finishReason = (candidates.first as Map<String, dynamic>)['finishReason']
            as String?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          return 'Gemini returned an empty response. Please try again.';
        }

        final text = parts
            .map(
              (part) =>
                  (part as Map<String, dynamic>)['text'] as String? ?? '',
            )
            .join('\n')
            .trim();
        if (text.isNotEmpty) {
          var normalized = _normalizeMarkdownArtifacts(text);
          if (finishReason == 'MAX_TOKENS') {
            normalized =
                '$normalized\n\nFor more detailed explanation, ask "continue" for remaining tips.';
          }
          return normalized;
        }
        return 'Gemini returned an empty response. Please try again.';
      }
      return lastError ??
          'Gemini model is unavailable for this key/project. Please check model access.';
    } catch (_) {
      return 'I could not reach Gemini right now. Please check your connection and try again.';
    }
  }

  String _extractGeminiError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final err = decoded['error'] as Map<String, dynamic>?;
      final message = (err?['message'] as String?)?.trim();
      if (message != null && message.isNotEmpty) {
        return 'Gemini request failed (${response.statusCode}): $message';
      }
    } catch (_) {
      // Ignore parse errors and use generic status fallback.
    }
    return 'Gemini request failed (${response.statusCode}). Please verify key, quota, and model access.';
  }

  String _normalizeMarkdownArtifacts(String text) {
    final boldCount = RegExp(r'\*\*').allMatches(text).length;
    if (boldCount.isOdd) {
      // Avoid rendering issues when Gemini returns a dangling markdown marker.
      return text.replaceAll('**', '');
    }
    return text;
  }

  bool _isWildlifePhotographyRelevant(String text) {
    final normalized = text.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    for (final keyword in _wildlifePhotographyKeywords) {
      if (normalized.contains(keyword)) return true;
    }

    for (final species in speciesData.take(50)) {
      final commonWords = species.commonName
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((w) => w.length >= 4);
      for (final word in commonWords) {
        if (normalized.contains(word)) return true;
      }
    }
    return false;
  }

  String _composePromptWithClarification({
    required String originalQuestion,
    required String clarification,
    required _PendingType type,
  }) {
    if (type == _PendingType.gear) {
      return '''
User question:
$originalQuestion

User gear:
$clarification

Please answer using the settings/tips template.
''';
    }
    return '''
User question:
$originalQuestion

User target animal:
$clarification

Please answer using the preparation checklist template.
''';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_scrollController.hasClients) return;

      Future<void> scrollOnce() async {
        if (!_scrollController.hasClients) return;
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      }

      // First pass scroll immediately.
      await scrollOnce();
      // Second pass catches late layout growth from multiline responses.
      await Future<void>.delayed(const Duration(milliseconds: 70));
      await scrollOnce();
    });
  }

  int get _itemCount {
    final base = 2 + _suggestions.length;
    final extra = _messages.length > 1 ? _messages.length - 1 : 0;
    return base + extra + (_isAssistantTyping ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = Adaptive.scale(context);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 8 * s, 12 * s),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              if (widget.showBackButton) ...[
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20 * s,
                    ),
                  ),
                ),
                SizedBox(width: 8 * s),
              ],
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.camera_alt_outlined),
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo Assistant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      'Camera settings & tips',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  tooltip: 'Close chat',
                  icon: Icon(
                    Icons.close,
                    size: 20 * s,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(14 * s, 10 * s, 14 * s, 10 * s),
            itemCount: _itemCount,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _chatCard(_messages[0], showTime: true);
              }
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
                  child: Text(
                    'Try asking:',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              final suggestionIndex = index - 2;
              if (suggestionIndex < _suggestions.length) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                  child: _suggestionCard(_suggestions[suggestionIndex]),
                );
              }

              final extraMessageCount = _messages.length - 1;
              final extraIndex = suggestionIndex - _suggestions.length;
              if (extraIndex < extraMessageCount) {
                return _chatCard(_messages[extraIndex + 1]);
              }
              return _typingCard();
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, 10 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitQuestion(),
                  decoration: const InputDecoration(
                    hintText: 'Ask about settings, equipment, or tips...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              FilledButton(
                onPressed: _isAssistantTyping ? null : _submitQuestion,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.send_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _suggestionCard(String text) {
    final s = Adaptive.scale(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(12 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(12 * s),
        onTap: _isAssistantTyping ? null : () => _onSuggestionTap(text),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: Adaptive.clamp(context, 14, min: 12, max: 16),
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingCard() {
    return _chatCard(
      const _ChatMessage(text: 'Thinking...', isUser: false),
    );
  }

  Widget _chatCard(_ChatMessage message, {bool showTime = false}) {
    final isUser = message.isUser;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.76;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.primary.withValues(alpha: 0.42)
                      : Colors.green.shade100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        height: 1.45,
                        color: Colors.black87,
                      ),
                      children: _inlineMarkdownSpans(
                        message.text,
                        const TextStyle(
                          height: 1.45,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  if (showTime) ...[
                    const SizedBox(height: 6),
                    Text(
                      '17:38',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _inlineMarkdownSpans(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
    var start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final boldText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: boldText,
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }
    return spans;
  }
}

enum _PendingType { gear, targetAnimal }

class _PendingRequest {
  const _PendingRequest({required this.originalQuestion, required this.type});

  final String originalQuestion;
  final _PendingType type;
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  factory _ChatMessage.user(String text) {
    return _ChatMessage(text: text, isUser: true);
  }

  factory _ChatMessage.assistant(String text) {
    return _ChatMessage(text: text, isUser: false);
  }
}
