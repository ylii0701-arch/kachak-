import 'package:flutter/material.dart';

import '../widgets/assistant_panel.dart';
import '../widgets/glass.dart';

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MistBackdrop(backgroundBlurSigma: 9),
          SafeArea(
            child: AssistantPanel(
              showBackButton: true,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
