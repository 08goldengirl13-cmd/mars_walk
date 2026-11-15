import 'package:flutter_test/flutter_test.dart';
import 'package:mars_walk/data/cards_content.dart';
import 'package:mars_walk/data/objectives_content.dart';
import 'package:mars_walk/data/route_models.dart';
import 'package:mars_walk/data/stops_content.dart';
import 'package:mars_walk/i18n/strings.dart';
import 'package:mars_walk/logic/playback_controller.dart';

void main() {
  group('PlaybackController', () {
    test('full route takes 30 s at 1×, 7.5 s at 4×', () {
      final p = PlaybackController(RouteData.demo());
      p.advanceBy(15);
      expect(p.progress, closeTo(0.5, 1e-9));
      p.advanceBy(15);
      expect(p.progress, 1);
      expect(p.reachedEnd, isTrue);
      expect(p.isPlaying, isFalse);

      p.seek(0);
      p.setSpeed(4);
      p.advanceBy(7.5);
      expect(p.progress, 1);
      p.dispose();
    });

    test('seek clamps and clears reachedEnd', () {
      final p = PlaybackController(RouteData.demo());
      p.seek(-5);
      expect(p.position, 0);
      p.seek(1e9);
      expect(p.position, p.maxIndex);
      p.advanceBy(1);
      expect(p.reachedEnd, isTrue);
      p.seek(3);
      expect(p.reachedEnd, isFalse);
      p.dispose();
    });

    test('jumpToSol uses the first waypoint at or after the sol', () {
      final p = PlaybackController(RouteData.demo());
      p.jumpToSol(55); // demo sols are 0, 10, 20 …
      expect(p.current.sol, 60);
      p.dispose();
    });
  });

  group('strings', () {
    test('every UZ key also exists in EN', () {
      for (final k in S.uzKeys) {
        expect(S.hasKey(k), isTrue, reason: k);
      }
    });

    test('every EN key has a UZ translation', () {
      final uz = S.uzKeys.toSet();
      final missing = S.enKeys.where((k) => !uz.contains(k)).toList();
      expect(missing, isEmpty);
    });

    test('placeholders are filled', () {
      expect(const S(Lang.en).t('chipSol', {'sol': 42}), 'Sol 42');
      expect(const S(Lang.uz).t('chipKm', {'km': '1.5'}), '1.5 km');
    });

    test('content texts have both languages', () {
      for (final s in stops) {
        expect(s.name.uz, isNotEmpty);
        expect(s.short.uz, isNotEmpty);
        expect(s.more.uz, isNotEmpty);
      }
      for (final c in missionCards) {
        expect(c.scenario.uz, isNotEmpty);
        expect(c.nasaDid.uz, isNotEmpty);
        expect(c.takeaway.uz, isNotEmpty);
      }
    });

    test('only official objective codes are used', () {
      for (final s in stops) {
        for (final code in s.objectiveCodes) {
          expect(objectives.containsKey(code), isTrue, reason: '${s.id}: $code');
        }
      }
      for (final c in missionCards) {
        for (final code in c.objectiveCodes) {
          expect(objectives.containsKey(code), isTrue, reason: '${c.stopId}: $code');
        }
      }
    });
  });
}
