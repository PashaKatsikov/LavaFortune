import 'package:flutter/material.dart';

import '../../app/caldera_buttons.dart';

/// Shown whenever the relay pipeline concludes "no network".
///
/// Retry rebuilds the caller-supplied route through
/// `pushReplacement`. The pipeline is idempotent by design — the
/// coordinator's in-flight cache clears on completion, so Retry
/// runs the full boot flow fresh (attribution → probe → verdict).
class OfflineStage extends StatefulWidget {
  const OfflineStage({super.key, required this.onRetryBuild});

  final WidgetBuilder onRetryBuild;

  @override
  State<OfflineStage> createState() => _OfflineStageState();
}

class _OfflineStageState extends State<OfflineStage> {
  bool _spinning = false;

  Future<void> _retry() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    await Future<void>.delayed(const Duration(milliseconds: 620));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: widget.onRetryBuild),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final Size size = MediaQuery.of(context).size;
    // Type scales off the short edge, so rotating the device does not
    // blow the headline up to the width of the screen.
    final double unit = size.shortestSide;

    return MediaQuery(
      data: landscape
          ? MediaQuery.of(context).copyWith(
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            )
          : MediaQuery.of(context),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0B05),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF3B1405),
                Color(0xFF1A0B05),
                Color(0xFF090402),
              ],
              stops: <double>[0, 0.55, 1],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Align(
                alignment: Alignment(0, landscape ? -0.24 : -0.12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * (landscape ? 0.14 : 0.09),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'NO INTERNET CONNECTION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: unit * 0.072,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: 1.2,
                          shadows: const <Shadow>[
                            Shadow(
                              color: Color(0xCC000000),
                              offset: Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: unit * 0.05),
                      Text(
                        'Check your connection and try again',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE8CDBB),
                          fontSize: unit * 0.045,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: size.height * (landscape ? 0.08 : 0.09),
                child: Center(
                  child: _spinning
                      ? const SizedBox(
                          width: 34,
                          height: 34,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6A1A)),
                          ),
                        )
                      : RelayPillButton(
                          label: 'Retry',
                          width:
                              landscape ? size.width * 0.3 : size.width * 0.55,
                          onTap: _retry,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
