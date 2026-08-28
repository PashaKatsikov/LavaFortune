import 'package:flutter/material.dart';

/// Shared button styling for the relay (gray) screens. Lava-gold
/// gradient matching the white-part brand, with a press-scale reaction.
class RelayPillButton extends StatefulWidget {
  const RelayPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.compact = false,
    this.width,
    this.heightFactor = 1.0,
  });

  final String label;
  final VoidCallback onTap;
  final bool compact;
  final double? width;

  /// Scales the vertical box only — glyph size stays put so the label
  /// keeps its weight on a shorter pill.
  final double heightFactor;

  @override
  State<RelayPillButton> createState() => _RelayPillButtonState();
}

class _RelayPillButtonState extends State<RelayPillButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        child: Container(
          width: widget.width,
          constraints: BoxConstraints(minHeight: 44 * widget.heightFactor),
          padding: EdgeInsets.symmetric(
            horizontal: 28,
            vertical: (widget.compact ? 12 : 17) * widget.heightFactor,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFFFA24C), Color(0xFFE85A1A), Color(0xFFC03D10)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF7A2208).withValues(alpha: 0.55),
                offset: const Offset(0, 5),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.compact ? 16 : 19,
                fontWeight: FontWeight.w800,
                height: 1.0,
                letterSpacing: 0.4,
                shadows: const <Shadow>[
                  Shadow(color: Color(0x66000000), offset: Offset(0, 2), blurRadius: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
