import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../models/segment.dart';
import '../../../widgets/lava_button.dart';
import '../../../widgets/lava_panel.dart';

class EventOverlay extends StatelessWidget {
  final EventDef event;
  final void Function(bool accept) onResolve;

  const EventOverlay({super.key, required this.event, required this.onResolve});

  IconData get _icon {
    switch (event.kind) {
      case EventKind.magmaGeyser:
        return Icons.local_fire_department;
      case EventKind.unstableTunnel:
        return Icons.warning_amber;
      case EventKind.ancientCache:
        return Icons.inventory_2;
      case EventKind.coldVent:
        return Icons.ac_unit;
      case EventKind.oreSurge:
        return Icons.diamond;
    }
  }

  @override
  Widget build(BuildContext context) {
    final autoResolveOnly = event.kind == EventKind.coldVent || event.kind == EventKind.oreSurge;
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: LavaPanel(
            borderColor: AppColors.emberGold,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, color: AppColors.emberGold, size: 44),
                const SizedBox(height: 12),
                Text(event.title, style: AppTextStyles.screenTitle, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(event.description, style: AppTextStyles.body, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Reward',
                            style: AppTextStyles.caption.copyWith(color: AppColors.success),
                          ),
                          Text(
                            event.rewardLabel,
                            style: AppTextStyles.bodyStrong,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Risk',
                            style: AppTextStyles.caption.copyWith(color: AppColors.danger),
                          ),
                          Text(
                            event.riskLabel,
                            style: AppTextStyles.bodyStrong,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (autoResolveOnly)
                  LavaButton(
                    label: 'CONTINUE',
                    style: LavaButtonStyle.success,
                    width: double.infinity,
                    onPressed: () => onResolve(true),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: LavaButton(
                          label: 'BYPASS',
                          style: LavaButtonStyle.neutral,
                          onPressed: () => onResolve(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LavaButton(
                          label: 'PUSH ON',
                          style: LavaButtonStyle.primary,
                          onPressed: () => onResolve(true),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
