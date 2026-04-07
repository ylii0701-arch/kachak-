import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    Widget img = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      height: height,
      width: width,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade500, size: 40),
      ),
    );
    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}
