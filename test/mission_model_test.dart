import 'package:flutter_test/flutter_test.dart';
import 'package:mars_walk/data/route_models.dart';
import 'package:mars_walk/logic/mission_model.dart';

void main() {
  const suit = MissionConstants.suitHours;
  const reserve = MissionConstants.reserveFraction;

  group('verdictFor', () {
    test('thresholds', () {
      expect(MissionModel.verdictFor(0), Verdict.safe);
      expect(MissionModel.verdictFor(suit * (1 - reserve)), Verdict.safe);
      expect(MissionModel.verdictFor(suit * (1 - reserve) + 0.01), Verdict.risky);
      expect(MissionModel.verdictFor(suit), Verdict.risky);
      expect(MissionModel.verdictFor(suit + 0.01), Verdict.tooFar);
    });
  });

  group('Leg', () {
    final points = [
      const RoutePoint(sol: 1, lon: 0, lat: 0, elev: -100, tilt: 0, distM: 0),
      const RoutePoint(sol: 5, lon: 0, lat: 0, elev: -80, tilt: 15, distM: 2000),
      const RoutePoint(sol: 9, lon: 0, lat: 0, elev: -50, tilt: 30, distM: 5000),
    ];

    test('between uses real distance, mean tilt, net elevation gain', () {
      final leg = Leg.between(points, 0, 2);
      expect(leg.km, 5);
      expect(leg.avgTilt, 15);
      expect(leg.elevGain, 50);
      expect(leg.sols, 8);
      expect(leg.effort, 2); // 1 + 15/15
      expect(leg.hoursOneWay, closeTo(5 * 2 / 2.5, 1e-9));
      expect(leg.hoursRoundTrip, closeTo(8, 1e-9));
    });

    test('order of indices does not matter', () {
      expect(Leg.between(points, 2, 0).km, 5);
    });
  });

  group('evaluate', () {
    // effort 1 → hoursOneWay = km / 2.5
    const short = Leg(km: 1, avgTilt: 0, elevGain: 10, sols: 5); // RT 0.8 h
    const medium = Leg(km: 9, avgTilt: 0, elevGain: 50, sols: 50); // RT 7.2 h (risky)
    const long = Leg(km: 25, avgTilt: 0, elevGain: 300, sols: 400); // RT 20 h, half RT 10 h

    test('short go is safe and reaches the stop', () {
      final o = MissionModel.evaluate(short, OptionKind.go, 100);
      expect(o.verdict, Verdict.safe);
      expect(o.reachedStop, isTrue);
      expect(o.hoursUsed, closeTo(0.8, 1e-9));
      expect(o.oxygenLeft, closeTo(7.2, 1e-9));
      expect(o.points, 100 + (7.2 * 5).round());
      expect(o.energyAfter, closeTo(100 - 0.8 * 6, 1e-9));
      expect(o.radiationMsv, closeTo(0.6 * 0.8 / 24, 1e-12));
    });

    test('medium go is risky but reached', () {
      final o = MissionModel.evaluate(medium, OptionKind.go, 100);
      expect(o.verdict, Verdict.risky);
      expect(o.reachedStop, isTrue);
      expect(o.points, 60 + (0.8 * 5).round());
    });

    test('long go is too far: turn back at the reserve, penalty', () {
      final o = MissionModel.evaluate(long, OptionKind.go, 100);
      expect(o.verdict, Verdict.tooFar);
      expect(o.reachedStop, isFalse);
      expect(o.hoursUsed, closeTo(suit * (1 - reserve), 1e-9));
      expect(o.oxygenLeft, closeTo(suit * reserve, 1e-9));
      expect(o.points, MissionConstants.penaltyTooFar);
    });

    test('half of a long leg is still too far; half of medium is safe', () {
      expect(MissionModel.evaluate(long, OptionKind.half, 100).verdict, Verdict.tooFar);
      final h = MissionModel.evaluate(medium, OptionKind.half, 100);
      expect(h.verdict, Verdict.safe);
      expect(h.reachedStop, isFalse);
      expect(h.points, 50 + ((suit - 3.6) * 5).round());
    });

    test('study is always safe', () {
      final o = MissionModel.evaluate(long, OptionKind.study, 100);
      expect(o.verdict, Verdict.safe);
      expect(o.hoursUsed, MissionConstants.studyHours);
      expect(o.points, 30 + ((suit - 2) * 5).round());
    });

    test('ask Earth picks the most ambitious safe option, costs 10 points', () {
      expect(MissionModel.recommend(short), OptionKind.go);
      expect(MissionModel.recommend(medium), OptionKind.half);
      expect(MissionModel.recommend(long), OptionKind.study);
      final o = MissionModel.evaluate(medium, OptionKind.askEarth, 100);
      final direct = MissionModel.evaluate(medium, OptionKind.half, 100);
      expect(o.kind, OptionKind.askEarth);
      expect(o.advised, OptionKind.half);
      expect(o.points, direct.points - 10);
      expect(o.verdict, Verdict.safe);
    });

    test('energy never goes below zero', () {
      expect(MissionModel.evaluate(long, OptionKind.go, 5).energyAfter, 0);
    });

    test('deterministic', () {
      final a = MissionModel.evaluate(medium, OptionKind.go, 80);
      final b = MissionModel.evaluate(medium, OptionKind.go, 80);
      expect(a.points, b.points);
      expect(a.energyAfter, b.energyAfter);
    });
  });

  group('MissionSummary', () {
    const short = Leg(km: 1, avgTilt: 0, elevGain: 0, sols: 1);
    const long = Leg(km: 20, avgTilt: 0, elevGain: 0, sols: 1);

    test('score, stops and achievements', () {
      var e = 100.0;
      final outcomes = <ChoiceOutcome>[];
      for (var i = 0; i < 3; i++) {
        final o = MissionModel.evaluate(short, OptionKind.go, e);
        e = o.energyAfter;
        outcomes.add(o);
      }
      final sum = MissionSummary(outcomes);
      expect(sum.stopsReached, 3);
      expect(sum.achievements, [
        Achievement.safeWalker,
        Achievement.explorer,
        Achievement.oxygenSaver,
      ]);
      final pointSum = outcomes.fold<int>(0, (s, o) => s + o.points);
      expect(sum.score, pointSum + (sum.finalEnergy * 0.2).round());
    });

    test('too far removes the safe walker badge', () {
      final sum = MissionSummary([MissionModel.evaluate(long, OptionKind.go, 100)]);
      expect(sum.achievements.contains(Achievement.safeWalker), isFalse);
      expect(sum.stopsReached, 0);
    });

    test('at most 3 achievements', () {
      final outcomes = [
        for (var i = 0; i < 3; i++) MissionModel.evaluate(short, OptionKind.go, 100),
        MissionModel.evaluate(short, OptionKind.askEarth, 100),
      ];
      expect(MissionSummary(outcomes).achievements.length, 3);
    });
  });
}
