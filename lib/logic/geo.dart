import 'dart:math' as math;

import '../data/route_models.dart';

/// Mean radius of Mars used for distance maths (km).
const double marsRadiusKm = 3389.5;

double _rad(double deg) => deg * math.pi / 180.0;

/// Great-circle (haversine) distance on Mars in kilometres.
double marsDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * marsRadiusKm * math.asin(math.min(1.0, math.sqrt(a)));
}

/// Index of one NASA Mars Trek equirectangular tile.
class TileIndex {
  const TileIndex(this.z, this.row, this.col);
  final int z;
  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is TileIndex && other.z == z && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(z, row, col);

  @override
  String toString() => 'TileIndex(z $z, row $row, col $col)';
}

/// Mars Trek "EQ" grid: zoom 0 has 1 row × 2 columns; columns count east from
/// −180°, rows count down from +90°.
TileIndex tileFor(double lat, double lon, int z) {
  final cols = 1 << (z + 1);
  final rows = 1 << z;
  final col = ((lon + 180.0) / 360.0 * cols).floor();
  final row = ((90.0 - lat) / 180.0 * rows).floor();
  return TileIndex(z, row, col);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Linear interpolation between two waypoints. `sol` is rounded.
RoutePoint lerpPoint(RoutePoint a, RoutePoint b, double t) {
  final c = t.clamp(0.0, 1.0);
  return RoutePoint(
    sol: _lerp(a.sol.toDouble(), b.sol.toDouble(), c).round(),
    lon: _lerp(a.lon, b.lon, c),
    lat: _lerp(a.lat, b.lat, c),
    elev: _lerp(a.elev, b.elev, c),
    tilt: _lerp(a.tilt, b.tilt, c),
    distM: _lerp(a.distM, b.distM, c),
  );
}

/// Point at a fractional index (e.g. 12.4 = 40 % of the way from 12 to 13).
RoutePoint pointAt(List<RoutePoint> points, double position) {
  if (points.isEmpty) throw ArgumentError('empty route');
  final p = position.clamp(0.0, (points.length - 1).toDouble());
  final i = p.floor();
  if (i >= points.length - 1) return points.last;
  return lerpPoint(points[i], points[i + 1], p - i);
}

/// First index whose sol is ≥ [sol] (last index if none).
int indexForSol(List<RoutePoint> points, int sol) {
  var lo = 0;
  var hi = points.length - 1;
  if (points.last.sol < sol) return points.length - 1;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (points[mid].sol >= sol) {
      hi = mid;
    } else {
      lo = mid + 1;
    }
  }
  return lo;
}

/// Where the rover was on [sol]: the last waypoint with sol ≤ [sol]
/// (index 0 if [sol] is before the first waypoint).
int indexAtSol(List<RoutePoint> points, int sol) {
  final i = indexForSol(points, sol);
  if (points[i].sol == sol) {
    var j = i;
    while (j + 1 < points.length && points[j + 1].sol == sol) {
      j++;
    }
    return j;
  }
  return points[i].sol > sol ? math.max(0, i - 1) : i;
}

/// Index of the waypoint nearest to a position.
int nearestIndex(List<RoutePoint> points, double lat, double lon) {
  var best = 0;
  var bestD = double.infinity;
  for (var i = 0; i < points.length; i++) {
    final d = marsDistanceKm(lat, lon, points[i].lat, points[i].lon);
    if (d < bestD) {
      bestD = d;
      best = i;
    }
  }
  return best;
}
