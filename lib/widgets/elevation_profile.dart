import 'package:material_ui/material_ui.dart';

import '../data/route_models.dart';
import '../theme/app_theme.dart';

/// Mini elevation profile (distance on X, elevation on Y) drawn from the real
/// route, with the walked part in amber and a moving cursor.
class ElevationProfile extends StatelessWidget {
  const ElevationProfile({super.key, required this.route, required this.distM, this.height = 56});

  final RouteData route;

  /// Current distance along the route, metres.
  final double distM;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: RepaintBoundary(child: CustomPaint(painter: _ProfilePainter(route, distM))),
    );
  }
}

/// Caches the profile path per size so only cheap clipping happens each frame.
class _PathCache {
  static final Expando<Map<Size, Path>> _cache = Expando();

  static Path pathFor(RouteData route, Size size) {
    final map = _cache[route] ??= {};
    return map.putIfAbsent(size, () {
      final total = route.last.distM <= 0 ? 1.0 : route.last.distM;
      final range = (route.maxElev - route.minElev).abs() < 1 ? 1.0 : route.maxElev - route.minElev;
      final path = Path()..moveTo(0, size.height);
      for (final p in route.points) {
        final x = p.distM / total * size.width;
        final y = size.height - (p.elev - route.minElev) / range * (size.height - 6) - 2;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      if (map.length > 8) map.clear();
      return path;
    });
  }
}

class _ProfilePainter extends CustomPainter {
  _ProfilePainter(this.route, this.distM);

  final RouteData route;
  final double distM;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path = _PathCache.pathFor(route, size);
    final total = route.last.distM <= 0 ? 1.0 : route.last.distM;
    final x = (distM / total).clamp(0.0, 1.0) * size.width;

    canvas.drawPath(path, Paint()..color = AppColors.border);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, x, size.height));
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.accentSoft, AppColors.accent],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();

    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfilePainter old) =>
      old.distM != distM || !identical(old.route, route);
}
