import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../data/strata_content.dart';
import '../i18n/strings.dart';
import '../logic/era_visual.dart';
import '../theme/app_theme.dart';

/// Animated "Mars of that time" scene, drawn entirely with a CustomPainter.
/// When the era changes, the scene cross-fades over ~1.5 s.
/// This is an ARTIST'S CONCEPT — no measured values are shown.
class EraScene extends StatefulWidget {
  const EraScene({super.key, required this.eraIndex, this.height = 150, this.calm = false});

  final int eraIndex;
  final double height;
  final bool calm;

  @override
  State<EraScene> createState() => _EraSceneState();
}

class _EraSceneState extends State<EraScene> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void initState() {
    super.initState();
    if (!widget.calm) _loop.repeat();
  }

  @override
  void didUpdateWidget(covariant EraScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.calm && _loop.isAnimating) _loop.stop();
    if (!widget.calm && !_loop.isAnimating) _loop.repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = eras[widget.eraIndex].visual;
    final s = context.s;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: TweenAnimationBuilder<EraVisualState>(
              tween: EraVisualTween(begin: target, end: target),
              duration: Duration(milliseconds: widget.calm ? 0 : 1500),
              curve: Curves.easeInOut,
              builder: (context, state, _) => RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (context, _) => CustomPaint(
                    painter: EraScenePainter(state, _loop.value),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: target.water, end: target.water),
          duration: const Duration(milliseconds: 1500),
          builder: (context, water, _) =>
              _WetDryBar(water: water, wet: s.t('wet'), dry: s.t('dry')),
        ),
        const SizedBox(height: 4),
        Text(
          s.t('artistNote'),
          style: AppTheme.small.copyWith(fontSize: 11.5, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _WetDryBar extends StatelessWidget {
  const _WetDryBar({required this.water, required this.wet, required this.dry});
  final double water;
  final String wet;
  final String dry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$wet ↔ $dry',
      child: Row(
        children: [
          const Icon(Icons.water_drop, size: 16, color: Color(0xFF6FB7FF)),
          const SizedBox(width: 4),
          Text(wet, style: AppTheme.small),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF3F7FC4), Color(0xFFD9A066)]),
                      ),
                    ),
                    Align(
                      alignment: Alignment(1 - 2 * water.clamp(0.0, 1.0), 0),
                      child: Container(width: 6, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(dry, style: AppTheme.small),
          const SizedBox(width: 4),
          const Icon(Icons.wb_sunny, size: 16, color: AppColors.accentSoft),
        ],
      ),
    );
  }
}

/// Paints one moment of the era scene. [t] is the looping time 0…1.
class EraScenePainter extends CustomPainter {
  EraScenePainter(this.v, this.t);

  final EraVisualState v;
  final double t;

  static double _hash(int i, int salt) {
    final x = math.sin(i * 12.9898 + salt * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Sky.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [v.skyTop, v.skyBottom],
        ).createShader(rect),
    );

    // Sun with glow.
    final sun = Offset(w * 0.8, h * 0.22);
    final sr = math.min(w, h) * 0.07;
    canvas.drawCircle(
      sun,
      sr * 3.2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.45 * v.sun),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: sr * 3.2)),
    );
    canvas.drawCircle(
      sun,
      sr,
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFE9B0),
          Colors.white,
          v.sun,
        )!.withValues(alpha: 0.4 + 0.6 * v.sun),
    );

    // Mount Sharp in the distance (hazy).
    final haze = Color.lerp(v.ground, v.skyBottom, 0.55)!;
    final mountain = Path()
      ..moveTo(0, h * 0.62)
      ..lineTo(w * 0.18, h * 0.55)
      ..quadraticBezierTo(w * 0.42, h * 0.22, w * 0.6, h * 0.3)
      ..quadraticBezierTo(w * 0.78, h * 0.4, w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(mountain, Paint()..color = haze);
    // Layer lines on the mountain.
    final layerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var k = 1; k <= 4; k++) {
      final yy = h * (0.36 + k * 0.06);
      canvas.drawLine(
        Offset(w * (0.38 - k * 0.04), yy),
        Offset(w * (0.72 + k * 0.04), yy + 2),
        layerPaint,
      );
    }

    // Streams from the mountain to the lake.
    if (v.streams > 0.02) {
      final sp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF7FB6E6).withValues(alpha: 0.85 * v.streams);
      for (var k = 0; k < 2; k++) {
        final x0 = w * (0.46 + k * 0.14);
        final p = Path()..moveTo(x0, h * 0.5);
        p.cubicTo(
          x0 - 18 + k * 30,
          h * 0.6,
          x0 + 10 - k * 20,
          h * 0.66,
          w * (0.5 + k * 0.05),
          h * 0.74,
        );
        canvas.drawPath(p, sp);
        // Flow sparkle.
        final f = (t * 3 + k * 0.5) % 1.0;
        final m = p.computeMetrics().first;
        final pos = m.getTangentForOffset(m.length * f)?.position;
        if (pos != null) {
          canvas.drawCircle(
            pos,
            1.6,
            Paint()..color = Colors.white.withValues(alpha: 0.8 * v.streams),
          );
        }
      }
    }

    // Foreground ground.
    final ground = Path()..moveTo(0, h * 0.74);
    for (var x = 0.0; x <= w; x += w / 12) {
      ground.lineTo(x, h * 0.74 + math.sin(x / w * math.pi * 3) * 4);
    }
    ground
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ground, Paint()..color = v.ground);

    // Lake.
    if (v.water > 0.02) {
      final lw = w * (0.25 + 0.55 * v.water);
      final lh = h * (0.05 + 0.1 * v.water);
      final lake = Rect.fromCenter(center: Offset(w * 0.5, h * 0.8), width: lw, height: lh);
      final water = Color.lerp(const Color(0xFF2E5E8C), v.skyTop, 0.3)!;
      canvas.drawOval(lake, Paint()..color = water.withValues(alpha: math.min(1.0, v.water * 1.3)));
      final shimmer = Paint()
        ..color = Colors.white.withValues(alpha: 0.55 * v.water)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      for (var k = 0; k < 5; k++) {
        final phase = (t * 2 + k * 0.21) % 1.0;
        final cx = lake.left + lake.width * (0.15 + 0.7 * _hash(k, 3));
        final cy = lake.top + lake.height * (0.3 + 0.4 * _hash(k, 7));
        final len = 6 + 8 * math.sin(phase * math.pi);
        canvas.drawLine(Offset(cx - len / 2, cy), Offset(cx + len / 2, cy), shimmer);
      }
    }

    // Rocks in the foreground.
    final rock = Paint()..color = Color.lerp(v.ground, Colors.black, 0.35)!;
    for (var k = 0; k < 7; k++) {
      final rx = w * _hash(k, 11);
      final ry = h * (0.86 + 0.1 * _hash(k, 13));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rx, ry),
          width: 6 + 10 * _hash(k, 17),
          height: 4 + 4 * _hash(k, 19),
        ),
        rock,
      );
    }

    // Drifting dust.
    final count = (v.dust * 70).round();
    for (var i = 0; i < count; i++) {
      final speed = 0.3 + _hash(i, 1);
      final x = (w * _hash(i, 2) + t * w * (0.2 + v.wind) * speed * 2) % w;
      final y = h * 0.9 * _hash(i, 3) + math.sin((t * 6 + i) * math.pi) * 2;
      canvas.drawCircle(
        Offset(x, y),
        0.8 + 1.4 * _hash(i, 4),
        Paint()..color = const Color(0xFFF1C796).withValues(alpha: 0.25 + 0.45 * _hash(i, 5)),
      );
    }
    // Dusty haze.
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFFD9A066).withValues(alpha: 0.16 * v.dust),
    );
  }

  @override
  bool shouldRepaint(covariant EraScenePainter old) => old.t != t || old.v != v;
}
