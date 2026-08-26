import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../core/segment_visuals.dart';
import '../../../models/enemy.dart';
import '../../../models/segment.dart';

/// Visualizes the three upcoming tunnel routes using a simple pseudo-3D
/// perspective: routes converge toward the drill at the bottom, mimicking
/// the 2.5D dynamic-camera tunnel described in the game design.
class LaneView extends StatelessWidget {
  final List<LaneOption> options;
  final void Function(int index) onChoose;

  const LaneView({
    super.key,
    required this.options,
    required this.onChoose,
  });

  Color _riskColor(RiskTier tier) {
    switch (tier) {
      case RiskTier.safe:
        return AppColors.success;
      case RiskTier.medium:
        return AppColors.warning;
      case RiskTier.risky:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final laneWidth = constraints.maxWidth / 3;
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _TunnelPainter(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(options.length, (index) {
                final option = options[index];
                final isBoss = option.enemy?.category == EnemyCategory.boss;
                final visual = isBoss
                    ? const SegmentVisual(
                        Icons.whatshot,
                        AppColors.lavaRed,
                        'Colossal presence',
                      )
                    : segmentVisual(option.type);
                final risk = _riskColor(option.risk);
                return SizedBox(
                  width: laneWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    child: GestureDetector(
                      onTap: () => onChoose(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: risk.withValues(alpha: 0.85), width: 1.6),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              risk.withValues(alpha: 0.22),
                              AppColors.obsidian.withValues(alpha: 0.9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(color: risk.withValues(alpha: 0.35), blurRadius: 12),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(visual.icon, color: visual.color, size: 34),
                            const SizedBox(height: 8),
                            Text(
                              visual.hint,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _TunnelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bottomCenter = Offset(size.width / 2, size.height);
    final topLeft = Offset(size.width * 0.08, 0);
    final topRight = Offset(size.width * 0.92, 0);
    final topCenter = Offset(size.width / 2, 0);

    canvas.drawLine(bottomCenter, topLeft, paint);
    canvas.drawLine(bottomCenter, topRight, paint);
    canvas.drawLine(bottomCenter, topCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
