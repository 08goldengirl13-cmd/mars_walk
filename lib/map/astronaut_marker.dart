import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// The astronaut: a drawn helmet with a visor highlight and a soft pulsing
/// ring. No image assets.
class AstronautMarker extends StatefulWidget {
  const AstronautMarker({super.key, this.size = 56, this.pulse = true});

  final double size;
  final bool pulse;

  @override
  State<AstronautMarker> createState() => _AstronautMarkerState();
}

class _AstronautMarkerState extends State<AstronautMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant AstronautMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_c.isAnimating) _c.repeat();
    if (!widget.pulse && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Astronaut',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: AstronautPainter(widget.pulse ? _c.value : 0.0, showRing: widget.pulse),
          ),
        ),
      ),
    );
  }
}

class AstronautPainter extends CustomPainter {
  AstronautPainter(this.t, {this.showRing = true});

  /// Pulse phase 0…1.
  final double t;
  final bool showRing;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.24;

    if (showRing) {
      final ringR = r + (size.shortestSide / 2 - r) * t;
      canvas.drawCircle(
        c,
        ringR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = AppColors.accentSoft.withValues(alpha: (1 - t) * 0.8),
      );
    }

    // Shadow + helmet.
    canvas.drawCircle(c.translate(0, r * 0.12), r * 1.05, Paint()..color = const Color(0x66000000));
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF4F5FA));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, r * 0.18)
        ..color = AppColors.accent,
    );

    // Visor.
    final visor = Rect.fromCenter(
      center: c.translate(0, -r * 0.05),
      width: r * 1.25,
      height: r * 0.8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(visor, Radius.circular(r * 0.4)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B5A9A), Color(0xFF101830)],
        ).createShader(visor),
    );
    // Visor highlight.
    canvas.drawOval(
      Rect.fromCenter(
        center: visor.topLeft.translate(r * 0.38, r * 0.22),
        width: r * 0.42,
        height: r * 0.2,
      ),
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant AstronautPainter old) => old.t != t || old.showRing != showRing;
}
