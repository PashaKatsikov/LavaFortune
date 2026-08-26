import 'package:flutter/material.dart';
import '../models/drill.dart';

/// Renders a drill sprite, applying the tint used by variants that reuse the
/// base drill artwork.
class DrillArt extends StatelessWidget {
  final DrillDef drill;
  final double? height;
  final double? width;

  const DrillArt({super.key, required this.drill, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      drill.art,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );
    if (!drill.tinted) return image;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        drill.tintColor.withValues(alpha: 0.55),
        BlendMode.modulate,
      ),
      child: image,
    );
  }
}
