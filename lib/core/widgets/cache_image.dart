import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Alignment alignment;
  final ImageRepeat repeat;
  final FilterQuality filterQuality;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.borderRadius,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.filterQuality = FilterQuality.medium,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        key: ValueKey<String>(imageUrl),
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: filterQuality,
        fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 500),
        fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 1000),
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        repeat: repeat,
        placeholder:
            (context, url) => placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget:
            (context, url, error) => Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: fit,
              filterQuality: filterQuality,
              color: color,
              colorBlendMode: colorBlendMode,
              alignment: alignment,
              repeat: repeat,
            ),
      ),
    );
  }
}
