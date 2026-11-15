import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mars_walk/data/route_models.dart';
import 'package:mars_walk/logic/geo.dart';

RoutePoint pt(
  int sol,
  double distM, {
  double lat = -4.6,
  double lon = 137.4,
  double elev = -4500,
}) => RoutePoint(sol: sol, lon: lon, lat: lat, elev: elev, tilt: 5, distM: distM);

void main() {
  group('marsDistanceKm', () {
    test('zero for the same point', () {
      expect(marsDistanceKm(-4.6, 137.4, -4.6, 137.4), 0);
    });

    test('1 degree of longitude on the equator = 2πR/360', () {
      final expected = 2 * math.pi * marsRadiusKm / 360; // ≈ 59.16 km
      expect(marsDistanceKm(0, 0, 0, 1), closeTo(expected, 1e-6));
    });

    test('symmetric', () {
      final a = marsDistanceKm(-4.59, 137.44, -4.83, 137.39);
      final b = marsDistanceKm(-4.83, 137.39, -4.59, 137.44);
      expect(a, closeTo(b, 1e-9));
    });
  });

  group('tileFor (Mars Trek EQ grid)', () {
    test('zoom 0 has 1 row × 2 columns', () {
      expect(tileFor(89.9, -179.9, 0), const TileIndex(0, 0, 0));
      expect(tileFor(-89.9, 179.9, 0), const TileIndex(0, 0, 1));
    });

    test('Bradbury Landing indices follow the formula', () {
      const lat = -4.589467, lon = 137.441633;
      for (final z in [6, 10, 12, 14]) {
        final cols = 1 << (z + 1);
        final rows = 1 << z;
        final expected = TileIndex(
          z,
          ((90 - lat) / 180 * rows).floor(),
          ((lon + 180) / 360 * cols).floor(),
        );
        expect(tileFor(lat, lon, z), expected);
      }
      // These exact tiles returned HTTP 200 from trek.nasa.gov on 2026-11-14.
      expect(tileFor(lat, lon, 6), const TileIndex(6, 33, 112));
      expect(tileFor(lat, lon, 14), const TileIndex(14, 8609, 28894));
    });

    test('matches flutter_map Epsg4326 tile grid (validates Risk R1)', () {
      const crs = Epsg4326();
      final points = [
        const LatLng(-4.589467, 137.441633),
        const LatLng(-4.826023, 137.388886),
        const LatLng(45.0, -100.0),
        const LatLng(-60.0, 10.0),
      ];
      for (final p in points) {
        for (final z in [0, 3, 7, 12, 16]) {
          final px = crs.latLngToOffset(p, z.toDouble());
          final t = tileFor(p.latitude, p.longitude, z);
          expect((px.dx / 256).floor(), t.col, reason: 'col at z$z for $p');
          expect((px.dy / 256).floor(), t.row, reason: 'row at z$z for $p');
        }
      }
    });
  });

  group('interpolation and lookups', () {
    final pts = [pt(3, 0), pt(10, 100), pt(10, 150), pt(20, 300), pt(40, 900)];

    test('lerpPoint halfway', () {
      final m = lerpPoint(pt(0, 0, elev: -100), pt(10, 200, elev: 100), 0.5);
      expect(m.distM, 100);
      expect(m.elev, 0);
      expect(m.sol, 5);
    });

    test('lerpPoint clamps t', () {
      expect(lerpPoint(pts[0], pts[1], -1).distM, 0);
      expect(lerpPoint(pts[0], pts[1], 2).distM, 100);
    });

    test('pointAt fractional index', () {
      expect(pointAt(pts, 0.5).distM, 50);
      expect(pointAt(pts, 99).distM, 900);
      expect(pointAt(pts, -3).distM, 0);
    });

    test('indexForSol = first point with sol >= x', () {
      expect(indexForSol(pts, 0), 0);
      expect(indexForSol(pts, 10), 1);
      expect(indexForSol(pts, 11), 3);
      expect(indexForSol(pts, 999), 4);
    });

    test('indexAtSol = where the rover was on that sol', () {
      expect(indexAtSol(pts, 0), 0);
      expect(indexAtSol(pts, 10), 2);
      expect(indexAtSol(pts, 15), 2);
      expect(indexAtSol(pts, 40), 4);
      expect(indexAtSol(pts, 999), 4);
    });

    test('nearestIndex', () {
      final p2 = [pt(1, 0, lat: 0, lon: 0), pt(2, 1, lat: 1, lon: 1), pt(3, 2, lat: 2, lon: 2)];
      expect(nearestIndex(p2, 1.1, 0.9), 1);
    });
  });
}
