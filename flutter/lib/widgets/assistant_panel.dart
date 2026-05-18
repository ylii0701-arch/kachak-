import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config/map_keys.dart';
import '../data/species_data.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_controller.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import 'package:provider/provider.dart';

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
  final FocusNode _inputFocusNode = FocusNode();
  final List<_ChatMessage> _messages = [];
  _PendingRequest? _pendingRequest;
  bool _isAssistantTyping = false;
  int? _copiedMessageIndex;
  bool _showCopiedBanner = false;
  Timer? _copiedFeedbackTimer;
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
  void dispose() {
    _copiedFeedbackTimer?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends user message, handles clarification flow, and routes to Gemini.
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
      final l = AppLocalizations.of(context);
      setState(() {
        _messages.add(_ChatMessage.assistant(l?.chatIrrelevant ?? _irrelevantMessage));
      });
      _scrollToBottom();
      return;
    }

    await _replyWithGemini(question);
  }

  /// Handles tap on starter suggestions and asks follow-up clarification.
  void _onSuggestionTap(String suggestion) {
    final l = AppLocalizations.of(context);
    final locSuggestions = _localizedSuggestions(l);
    setState(() {
      _messages.add(_ChatMessage.user(suggestion));
      if (suggestion == locSuggestions.last) {
        _pendingRequest = _PendingRequest(
          originalQuestion: suggestion,
          type: _PendingType.targetAnimal,
        );
        _messages.add(
          _ChatMessage.assistant(
            l?.chatClarifyAnimal ?? 'Please clarify your target animal first so I can prepare the right checklist.',
          ),
        );
      } else {
        _pendingRequest = _PendingRequest(
          originalQuestion: suggestion,
          type: _PendingType.gear,
        );
        _messages.add(
          _ChatMessage.assistant(
            l?.chatClarifyGear ?? 'Please share your camera and lens so I can tailor the settings.',
          ),
        );
      }
    });
    _scrollToBottom();
  }

  /// Calls Gemini and appends assistant response into chat history.
  Future<void> _replyWithGemini(String userPrompt) async {
    setState(() => _isAssistantTyping = true);
    _scrollToBottom();

    final reply = await _fetchGeminiReply(userPrompt);
    if (!mounted) return;

    setState(() {
      _isAssistantTyping = false;
      _messages.add(
        _ChatMessage.assistant(
          reply,
          sourcePrompt: userPrompt,
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// Builds Gemini request with model fallback and concise formatting rules.
  String _langLabel() {
    try {
      final locale = context.read<LocaleController>().locale;
      switch (locale.languageCode) {
        case 'ms':
          return 'Malay (Bahasa Melayu)';
        case 'zh':
          return 'Simplified Chinese (简体中文)';
        default:
          return 'English';
      }
    } catch (_) {
      return 'English';
    }
  }

  Future<String> _fetchGeminiReply(String userPrompt) async {
    if (geminiApiKey.isEmpty) {
      return 'Gemini API key is missing. Please run with --dart-define=GEMINI_API_KEY=...';
    }

    final lang = _langLabel();
    final systemInstruction = '''
You are KaChak assistant for beginner wildlife photographers in Malaysia.
IMPORTANT: Always reply in $lang. All section headers, tips, and explanations must be in $lang.
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
        final finishReason =
            (candidates.first as Map<String, dynamic>)['finishReason']
                as String?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          return 'Gemini returned an empty response. Please try again.';
        }

        final text = parts
            .map(
              (part) => (part as Map<String, dynamic>)['text'] as String? ?? '',
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

  /// Converts API error payloads to user-readable text.
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

  /// Removes malformed markdown artifacts returned by model outputs.
  String _normalizeMarkdownArtifacts(String text) {
    final boldCount = RegExp(r'\*\*').allMatches(text).length;
    if (boldCount.isOdd) {
      // Avoid rendering issues when Gemini returns a dangling markdown marker.
      return text.replaceAll('**', '');
    }
    return text;
  }

  /// Lightweight relevance filter to keep assistant on app scope.
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

  /// Builds richer prompt from prior suggested question + user clarification.
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

  /// Ensures latest message remains visible after dynamic layout updates.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_scrollController.hasClients) return;

      Future<void> scrollOnce() async {
        if (!_scrollController.hasClients) return;
        await _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
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
    if (_messages.isEmpty) {
      return _isAssistantTyping ? 1 : 0;
    }
    return _messages.length + (_isAssistantTyping ? 1 : 0);
  }

  Future<void> _copyMessage(_ChatMessage message, int index) async {
    await Clipboard.setData(ClipboardData(text: message.text));
    if (!mounted) return;
    _copiedFeedbackTimer?.cancel();
    setState(() {
      _copiedMessageIndex = index;
      _showCopiedBanner = true;
    });
    _copiedFeedbackTimer = Timer(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      setState(() {
        _copiedMessageIndex = null;
        _showCopiedBanner = false;
      });
    });
  }

  void _toggleReaction(int index, _MessageReaction reaction) {
    if (_isAssistantTyping || index < 0 || index >= _messages.length) return;
    final msg = _messages[index];
    if (msg.isUser) return;
    final next = msg.reaction == reaction ? _MessageReaction.none : reaction;
    setState(() {
      _messages[index] = msg.copyWith(reaction: next);
    });
  }

  Future<void> _rewriteAnswer(int index) async {
    if (_isAssistantTyping || index < 0 || index >= _messages.length) return;
    final msg = _messages[index];
    final prompt = msg.sourcePrompt;
    if (msg.isUser || prompt == null || prompt.trim().isEmpty) return;

    setState(() => _isAssistantTyping = true);
    final reply = await _fetchGeminiReply(prompt);
    if (!mounted) return;
    setState(() {
      _isAssistantTyping = false;
      _messages[index] = msg.copyWith(
        text: _normalizeMarkdownArtifacts(reply),
        reaction: _MessageReaction.none,
      );
    });
    _scrollToBottom();
  }

  List<String> _localizedSuggestions(AppLocalizations? l) {
    return [
      l?.chatSuggestion1 ?? _suggestions[0],
      l?.chatSuggestion2 ?? _suggestions[1],
      l?.chatSuggestion3 ?? _suggestions[2],
      l?.chatSuggestion4 ?? _suggestions[3],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = Adaptive.scale(context);
    final media = MediaQuery.of(context);
    final isKeyboardVisible = media.viewInsets.bottom > 0;
    final bottomPadding = isKeyboardVisible ? 8 * s : 3 * s;
    final baseFontSize = Adaptive.clamp(context, 13, min: 12, max: 16);

    return Stack(
      children: [
        Column(
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
                      l?.chatTitle ?? 'Photo Assistant',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    Text(
                      l?.chatSubtitle ?? 'Camera settings & tips',
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
          child: _messages.isEmpty
              ? _emptyStateLayout(s)
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    14 * s,
                    10 * s,
                    14 * s,
                    isKeyboardVisible ? 12 * s : 10 * s,
                  ),
                  itemCount: _itemCount,
                  itemBuilder: (context, index) {
                    if (_isAssistantTyping && index == 0) {
                      return _typingCard();
                    }
                    final offset = _isAssistantTyping ? 1 : 0;
                    final messageIndex = _messages.length - 1 - (index - offset);
                    if (messageIndex >= 0 && messageIndex < _messages.length) {
                      return _chatCard(_messages[messageIndex], index: messageIndex);
                    }
                    return const SizedBox.shrink();
                  },
                ),
        ),
        SafeArea(
          top: false,
          minimum: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.fromLTRB(10 * s, 8 * s, 10 * s, bottomPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocusNode,
                        style: TextStyle(fontSize: baseFontSize),
                        textInputAction: TextInputAction.send,
                        onTap: _scrollToBottom,
                        onSubmitted: (_) => _submitQuestion(),
                        decoration: InputDecoration(
                          hintText: l?.chatHint ?? 'Ask anything about wildlife photography...',
                          hintStyle: TextStyle(
                            fontSize: baseFontSize,
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
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
                SizedBox(height: 6 * s),
                Text(
                  l?.chatDisclaimer ?? 'Photography AI chat can make mistakes. Please double check responses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: Adaptive.clamp(context, 11, min: 9, max: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          top: _showCopiedBanner ? (86 * s) : (74 * s),
          left: 16 * s,
          right: 16 * s,
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showCopiedBanner ? 1 : 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Text(
                    l?.chatCopied ?? 'Message copied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyStateLayout(double s) {
    final l = AppLocalizations.of(context);
    final locSuggestions = _localizedSuggestions(l);
    return Padding(
      padding: EdgeInsets.fromLTRB(10 * s, 0, 10 * s, 8 * s),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            l?.chatWelcome ?? 'What can I help with?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Adaptive.clamp(context, 30, min: 22, max: 36),
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.9),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(flex: 1),
          SizedBox(
            height: 76 * s,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: locSuggestions.length,
              padding: EdgeInsets.symmetric(horizontal: 2 * s),
              separatorBuilder: (_, i) => SizedBox(width: 8 * s),
              itemBuilder: (context, index) => _starterChip(locSuggestions[index]),
            ),
          ),
          SizedBox(height: 8 * s),
        ],
      ),
    );
  }

  Widget _starterChip(String text) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isAssistantTyping ? null : () => _onSuggestionTap(text),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.55,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.2,
              fontSize: Adaptive.clamp(context, 13, min: 12, max: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingCard() {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.76;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: _ShimmerLoader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SkeletonLine(widthFactor: 0.9),
                    SizedBox(height: 8),
                    _SkeletonLine(widthFactor: 0.72),
                    SizedBox(height: 8),
                    _SkeletonLine(widthFactor: 0.56),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatCard(_ChatMessage message, {int? index}) {
    final isUser = message.isUser;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.76;
    final iconColor = Colors.grey.shade600;
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
                        const TextStyle(height: 1.45, color: Colors.black87),
                      ),
                    ),
                  ),
                  if (!isUser && index != null && !_isAssistantTyping) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _miniActionIcon(
                          icon: _copiedMessageIndex == index
                              ? Icons.check_rounded
                              : Icons.content_copy_rounded,
                          tooltip: 'Copy',
                          color: _copiedMessageIndex == index
                              ? AppColors.primary
                              : iconColor,
                          onTap: () => _copyMessage(message, index),
                        ),
                        const SizedBox(width: 6),
                        if (message.reaction != _MessageReaction.down) ...[
                          _miniActionIcon(
                            icon: Icons.thumb_up_alt_outlined,
                            tooltip: 'Like',
                            color: message.reaction == _MessageReaction.up
                                ? AppColors.primary
                                : iconColor,
                            onTap: () => _toggleReaction(index, _MessageReaction.up),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (message.reaction != _MessageReaction.up) ...[
                          _miniActionIcon(
                            icon: Icons.thumb_down_alt_outlined,
                            tooltip: 'Dislike',
                            color: message.reaction == _MessageReaction.down
                                ? Colors.red.shade400
                                : iconColor,
                            onTap: () => _toggleReaction(index, _MessageReaction.down),
                          ),
                          const SizedBox(width: 6),
                        ],
                        _miniActionIcon(
                          icon: Icons.refresh_rounded,
                          tooltip: 'Rewrite',
                          color: iconColor,
                          onTap: () => _rewriteAnswer(index),
                        ),
                      ],
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

  Widget _miniActionIcon({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 16, color: color),
        ),
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
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.sourcePrompt,
    this.reaction = _MessageReaction.none,
  });

  final String text;
  final bool isUser;
  final String? sourcePrompt;
  final _MessageReaction reaction;

  factory _ChatMessage.user(String text) {
    return _ChatMessage(text: text, isUser: true);
  }

  factory _ChatMessage.assistant(String text, {String? sourcePrompt}) {
    return _ChatMessage(text: text, isUser: false, sourcePrompt: sourcePrompt);
  }

  _ChatMessage copyWith({
    String? text,
    bool? isUser,
    String? sourcePrompt,
    _MessageReaction? reaction,
  }) {
    return _ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      sourcePrompt: sourcePrompt ?? this.sourcePrompt,
      reaction: reaction ?? this.reaction,
    );
  }
}

enum _MessageReaction { none, up, down }

class _ShimmerLoader extends StatefulWidget {
  const _ShimmerLoader({required this.child});

  final Widget child;

  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width <= 0 ? 1.0 : bounds.width;
            final shift = (_controller.value * 2 - 1) * width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE8EDE8),
                Color(0xFFF7FAF7),
                Color(0xFFE8EDE8),
              ],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlidingGradientTransform(shift),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFFE7ECE7),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slidePercent, 0.0, 0.0);
  }
}
