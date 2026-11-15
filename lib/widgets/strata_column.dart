import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../data/route_models.dart';
import '../data/strata_content.dart';
import '../i18n/strings.dart';
import '../logic/geo.dart';
import '../logic/playback_controller.dart';
import '../map/astronaut_marker.dart';
import '../theme/app_theme.dart';

/// Elevation bands of each era. The bottom of a band is the real route
/// elevation at the era's first sol (looked up in the NASA data), so nothing
/// here is hard-coded.
class StrataBands {
  StrataBands(RouteData route)
    : minElev = route.minElev,
      maxElev = route.maxElev,
      bottoms = _bottoms(route);

  final double minElev;
  final double maxElev;

  /// Bottom elevation of each era band (same order as [eras]).
  final List<double> bottoms;

  double topOf(int i) => i + 1 < bottoms.length ? bottoms[i + 1] : maxElev;

  static List<double> _bottoms(RouteData route) {
    final out = <double>[];
    for (var i = 0; i < eras.length; i++) {
      if (i == 0) {
        out.add(route.minElev);
        continue;
      }
      final idx = indexForSol(route.points, eras[i].solStart);
      final e = route.points[idx].elev.clamp(route.minElev, route.maxElev);
      out.add(math.max(out.last, e));
    }
    return out;
  }
}

/// Vertical cross-section of Mount Sharp along the route. The astronaut rises
/// with the real elevation; the current layer is highlighted.
class StrataColumn extends StatelessWidget {
  const StrataColumn({super.key, required this.playback, this.height = 230, this.width = 150});

  final PlaybackController playback;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bands = StrataBands(playback.route);
    final names = [for (final e in eras) context.s.tr(e.name)];
    final youLabel = context.s.t('youAreHere');
    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) => Semantics(
        label: '${context.s.t('strataTitle')}: ${names[playback.eraIndex]}',
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _StrataPainter(
              bands: bands,
              names: names,
              youLabel: youLabel,
              elev: playback.elevation,
              current: playback.eraIndex,
            ),
          ),
        ),
      ),
    );
  }
}

class _StrataPainter extends CustomPainter {
  _StrataPainter({
    required this.bands,
    required this.names,
    required this.youLabel,
    required this.elev,
    required this.current,
  });

  final StrataBands bands;
  final List<String> names;
  final String youLabel;
  final double elev;
  final int current;

  static const double _colW = 40;
  static const double _padTop = 18;
  static const double _padBottom = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(1.0, bands.maxElev - bands.minElev);
    final h = size.height - _padTop - _padBottom;
    double y(double e) => _padTop + h - (e - bands.minElev) / range * h;
    const left = 14.0;

    // Bands with thin "rock strata" stripes.
    for (var i = 0; i < eras.length; i++) {
      final top = y(bands.topOf(i));
      final bottom = y(bands.bottoms[i]);
      if (bottom - top < 0.5) continue;
      final rect = Rect.fromLTRB(left, top, left + _colW, bottom);
      final isCur = i == current;
      final base = eras[i].bandColor;
      canvas.drawRect(
        rect,
        Paint()..color = isCur ? base : Color.lerp(base, AppColors.background, 0.45)!,
      );
      final stripe = Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..strokeWidth = 1;
      for (var sy = top + 4; sy < bottom; sy += 6) {
        final wobble = math.sin(sy * 0.37) * 3;
        canvas.drawLine(Offset(left, sy), Offset(left + _colW, sy + wobble * 0.3), stripe);
      }
      if (isCur) {
        canvas.drawRect(
          rect.inflate(1.5),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = AppColors.accentSoft,
        );
      }
    }

    // Labels on the right, spread out so they never overlap.
    final centers = [
      for (var i = 0; i < eras.length; i++) (y(bands.topOf(i)) + y(bands.bottoms[i])) / 2,
    ];
    const minGap = 15.0;
    final placed = List<double>.of(centers);
    for (var i = 1; i < placed.length; i++) {
      // eras go upwards, so each next label must be at least minGap above.
      if (placed[i - 1] - placed[i] < minGap) placed[i] = placed[i - 1] - minGap;
    }
    final shift = math.max(0.0, _padTop - 6 - placed.last);
    for (var i = 0; i < placed.length; i++) {
      final isCur = i == current;
      final ly = placed[i] + shift;
      canvas.drawLine(
        Offset(left + _colW + 2, centers[i]),
        Offset(left + _colW + 8, ly),
        Paint()
          ..color = AppColors.border
          ..strokeWidth = 1,
      );
      _text(
        canvas,
        names[i],
        Offset(left + _colW + 10, ly - 7),
        maxWidth: size.width - left - _colW - 10,
        color: isCur ? AppColors.accentSoft : AppColors.muted,
        bold: isCur,
      );
    }

    // Elevation scale.
    _text(
      canvas,
      '${bands.maxElev.round()} m'.replaceFirst('-', '−'),
      const Offset(0, 0),
      maxWidth: size.width,
      color: AppColors.muted,
      fontSize: 10,
    );
    _text(
      canvas,
      '${bands.minElev.round()} m'.replaceFirst('-', '−'),
      Offset(0, size.height - 13),
      maxWidth: size.width,
      color: AppColors.muted,
      fontSize: 10,
    );

    // The astronaut at the real elevation.
    final ay = y(elev.clamp(bands.minElev, bands.maxElev));
    canvas.drawLine(
      Offset(left - 6, ay),
      Offset(left + _colW + 6, ay),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5,
    );
    const a = 26.0;
    canvas.save();
    canvas.translate(left + _colW / 2 - a / 2, ay - a / 2);
    AstronautPainter(0, showRing: false).paint(canvas, const Size(a, a));
    canvas.restore();
  }

  void _text(
    Canvas canvas,
    String s,
    Offset at, {
    required double maxWidth,
    required Color color,
    bool bold = false,
    double fontSize = 11.5,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(10, maxWidth));
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _StrataPainter old) =>
      old.elev != elev || old.current != current || old.names != names;
}
