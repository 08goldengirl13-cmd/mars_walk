import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mars_walk/data/cards_content.dart';
import 'package:mars_walk/data/route_repository.dart';
import 'package:mars_walk/data/stops_content.dart';
import 'package:mars_walk/data/strata_content.dart';
import 'package:mars_walk/logic/mission_controller.dart';

void main() {
  final file = File('assets/data/route.json');
  final route = RouteRepository.parse(file.readAsStringSync());

  test('route asset is not empty', () {
    expect(route.length, greaterThan(1));
  });

  test('real data has at least 800 points (or is the labelled demo)', () {
    if (!route.isDemo) expect(route.length, greaterThanOrEqualTo(800));
  });

  test('distance is non-decreasing', () {
    for (var i = 1; i < route.length; i++) {
      expect(
        route.points[i].distM,
        greaterThanOrEqualTo(route.points[i - 1].distM),
        reason: 'index $i',
      );
    }
  });

  test('sol is non-decreasing', () {
    for (var i = 1; i < route.length; i++) {
      expect(route.points[i].sol, greaterThanOrEqualTo(route.points[i - 1].sol));
    }
  });

  test('all points lie inside the Gale Crater area', () {
    // Gale centre ≈ (−5.4°, 137.8°), ~154 km wide (≈ ±1.3°).
    for (final p in route.points) {
      expect(p.lat, inInclusiveRange(-6.8, -4.0));
      expect(p.lon, inInclusiveRange(136.4, 139.2));
      expect(p.elev, inInclusiveRange(-5500, -2000));
    }
  });

  test('route_meta.json matches route.json', () {
    if (route.isDemo) return;
    final meta = jsonDecode(File('assets/data/route_meta.json').readAsStringSync()) as Map;
    expect(meta['pointCount'], route.length);
    expect(meta['firstSol'], route.first.sol);
    expect(meta['lastSol'], route.last.sol);
    expect((meta['minElevM'] as num).toDouble(), closeTo(route.minElev, 0.01));
    expect((meta['maxElevM'] as num).toDouble(), closeTo(route.maxElev, 0.01));
    expect((meta['totalKm'] as num).toDouble(), closeTo(route.totalKm, 0.001));
  });

  test('stops resolve to increasing route indices', () {
    final idx = [for (final s in stops) s.indexIn(route.points)];
    expect(idx.first, 0);
    expect(idx.last, route.length - 1);
    for (var i = 1; i < idx.length; i++) {
      expect(idx[i], greaterThan(idx[i - 1]), reason: stops[i].id);
    }
  });

  test('eras are ordered by sol', () {
    for (var i = 1; i < eras.length; i++) {
      expect(eras[i].solStart, greaterThan(eras[i - 1].solStart));
    }
    expect(eraIndexForSol(route.first.sol), 0);
    expect(eraIndexForSol(route.last.sol), eras.length - 1);
  });

  test('every mission card leg is real and positive', () {
    final mission = MissionController(route);
    for (final c in missionCards) {
      final leg = mission.legFor(c);
      expect(leg.km, greaterThan(0), reason: c.stopId);
      expect(leg.sols, greaterThanOrEqualTo(0));
    }
  });
}
