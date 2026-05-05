import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shared network image widget with resilient loading/error placeholders.
class SpeciesNetworkImage extends StatelessWidget {
  const SpeciesNetworkImage({
    super.key,
    required this.url,
    required this.fit,
    this.height,
    this.width,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    // Normalize accidental whitespace in data URLs before rendering.
    final normalizedUrl = url.trim();
    final imageWidget = Image.network(
      normalizedUrl,
      fit: fit,
      height: height,
      width: width,
      // Some third-party CDNs block default dart/http client user agent.
      headers: kIsWeb
          ? null
          : const {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 KachakApp/1.0',
            },
      webHtmlElementStrategy: kIsWeb
          ? WebHtmlElementStrategy.prefer
          : WebHtmlElementStrategy.never,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.camera_alt_outlined,
          color: Colors.grey.shade500,
          size: 40,
        ),
      ),
    );
    Widget img = imageWidget;
    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}
