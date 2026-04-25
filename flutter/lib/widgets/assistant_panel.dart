import 'package:flutter/material.dart';

import '../data/photography_assistant_data.dart';
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
        "Hello! I'm your photography assistant. I can help you with camera settings, shooting tips, and equipment recommendations based on your gear and target wildlife. What would you like to know?",
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitQuestion([String? preset]) {
    final question = (preset ?? _inputController.text).trim();
    if (question.isEmpty) return;

    final reply = _buildAssistantReply(question);
    setState(() {
      _messages.add(_ChatMessage.user(question));
      _messages.add(_ChatMessage.assistant(reply));
      if (preset == null) {
        _inputController.clear();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _buildAssistantReply(String question) {
    final q = question.toLowerCase();
    final isChecklistIntent =
        q.contains('bring') ||
        q.contains('recommend') ||
        q.contains('equipment') ||
        q.contains('trip') ||
        q.contains('checklist') ||
        q.contains('rainforest');

    if (isChecklistIntent) {
      final animal = _extractAnimal(q);
      if (animal == null) {
        return 'Please clarify your target animal first (for example: birds, mammals, insects, or hornbill), then I can provide a checklist.';
      }
      final checklist = buildTripChecklist(
        animalInput: animal,
        weatherInput: _extractWeather(q),
      );
      if (checklist == null) {
        return 'No useful recommendation can be generated yet. Please refine your target animal.';
      }
      return _formatChecklistReply(checklist);
    }

    final equipment = detectEquipment(question);
    if (equipment.isEmpty) {
      return 'Before I suggest camera settings, please share your gear more clearly (camera + lens/accessory). Example: "Sony A6400 with 70-350mm lens and tripod."';
    }

    final scenario = _extractScenario(q);
    if (scenario == ShootingScenario.unsupported) {
      return 'I can currently provide accurate settings for: low light, fast-moving animals, and long-distance shooting.';
    }

    final advice = buildShootingAdvice(
      equipment: equipment,
      scenario: scenario,
    );
    if (advice == null) {
      return 'I cannot generate accurate advice for this request right now. Please refine your gear and scenario.';
    }
    return _formatAdviceReply(advice);
  }

  ShootingScenario _extractScenario(String q) {
    if (q.contains('low light') || q.contains('night') || q.contains('dark')) {
      return ShootingScenario.lowLight;
    }
    if (q.contains('flight') ||
        q.contains('fast') ||
        q.contains('moving') ||
        q.contains('action')) {
      return ShootingScenario.fastMoving;
    }
    if (q.contains('distance') ||
        q.contains('far') ||
        q.contains('telephoto') ||
        q.contains('long')) {
      return ShootingScenario.longDistance;
    }
    return ShootingScenario.unsupported;
  }

  String? _extractAnimal(String q) {
    if (q.contains('bird') || q.contains('hornbill')) return 'birds';
    if (q.contains('mammal') || q.contains('bear') || q.contains('monkey')) {
      return 'mammals';
    }
    if (q.contains('insect') ||
        q.contains('macro') ||
        q.contains('butterfly')) {
      return 'insects';
    }
    if (q.contains('frog') || q.contains('reptile')) return 'frog';
    return null;
  }

  String _extractWeather(String q) {
    if (q.contains('rain')) return 'Rainy';
    if (q.contains('sun') || q.contains('hot')) return 'Sunny';
    if (q.contains('wind')) return 'Windy';
    return 'Unavailable';
  }

  String _formatAdviceReply(ShootingAdvice advice) {
    final settings = advice.settings.map((e) => '- $e').join('\n');
    final tips = advice.tips.map((e) => '- $e').join('\n');
    final terms = advice.terms.entries
        .map((e) => '- ${e.key}: ${e.value}')
        .join('\n');
    return '''
Detected equipment:
${advice.detectedEquipment.join(', ')}

Settings:
$settings

Tips:
$tips

Explanation:
${advice.explanation}

Simple terms:
$terms
''';
  }

  String _formatChecklistReply(TripChecklist checklist) {
    final photo = checklist.photoEquipment.map((e) => '☑ $e').join('\n');
    final outdoor = checklist.outdoorEssentials.map((e) => '☑ $e').join('\n');
    return '''
Preparation checklist

Photography equipment:
$photo

Outdoor essentials:
$outdoor

Weather note:
${checklist.weatherNotice}
''';
  }

  int get _itemCount {
    final base = 2 + _suggestions.length;
    final extra = _messages.length > 1 ? _messages.length - 1 : 0;
    return base + extra;
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
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _suggestionCard(_suggestions[suggestionIndex]),
                );
              }

              final messageIndex = suggestionIndex - _suggestions.length + 1;
              if (messageIndex >= _messages.length) {
                return const SizedBox.shrink();
              }
              return _chatCard(_messages[messageIndex]);
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
                onPressed: _submitQuestion,
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
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _submitQuestion(text),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Text(text, style: const TextStyle(fontSize: 17)),
        ),
      ),
    );
  }

  Widget _chatCard(_ChatMessage message, {bool showTime = false}) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUser
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.green.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: const TextStyle(height: 1.45)),
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
    );
  }
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
