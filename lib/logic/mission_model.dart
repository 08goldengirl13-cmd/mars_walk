import 'dart:math' as math;

import '../data/route_models.dart';

/// Educational model constants. These are OUR ASSUMPTIONS, not NASA data
/// (except the radiation rate, which is an approximate published value).
class MissionConstants {
  MissionConstants._();

  /// Walking speed in a pressurised suit on flat ground, km/h (assumption).
  static const double walkSpeedKmh = 2.5;

  /// Oxygen for one walk (EVA), hours (assumption).
  static const double suitHours = 8.0;

  /// Safety reserve you must keep, fraction of [suitHours] (assumption).
  static const double reserveFraction = 0.2;

  /// Slower on steeper ground. Rover body tilt is used as a rough slope proxy.
  static double effortFromTilt(double tiltDeg) => 1 + tiltDeg / 15.0;

  /// Approximate surface dose rate, mSv per day.
  // VERIFY: ~0.6 mSv/day — Curiosity RAD results (Hassler et al. 2014, PDS RAD docs).
  static const double radiationMsvPerDay = 0.6;

  /// Time spent studying rocks near camp, hours (assumption).
  static const double studyHours = 2.0;

  /// Crew energy used per hour of walking, percent (assumption).
  static const double energyPctPerHour = 6.0;

  // Scoring (game design, not science).
  static const int pointsGoSafe = 100;
  static const int pointsGoRisky = 60;
  static const int pointsHalfSafe = 50;
  static const int pointsHalfRisky = 30;
  static const int pointsStudy = 30;
  static const int penaltyTooFar = -30;
  static const int penaltyAskEarth = -10;
  static const double bonusPerOxygenHour = 5;
  static const double bonusPerEnergyPct = 0.2;
}

enum Verdict { safe, risky, tooFar }

enum OptionKind { go, half, study, askEarth }

/// One real leg between two NASA waypoints.
class Leg {
  const Leg({required this.km, required this.avgTilt, required this.elevGain, required this.sols});

  /// Built from waypoint indices [from]..[to] (inclusive) of [points].
  factory Leg.between(List<RoutePoint> points, int from, int to) {
    final a = math.min(from, to);
    final b = math.max(from, to);
    var tiltSum = 0.0;
    for (var i = a; i <= b; i++) {
      tiltSum += points[i].tilt;
    }
    return Leg(
      km: (points[b].distM - points[a].distM) / 1000.0,
      avgTilt: tiltSum / (b - a + 1),
      elevGain: points[b].elev - points[a].elev,
      sols: points[b].sol - points[a].sol,
    );
  }

  final double km;
  final double avgTilt;
  final double elevGain;
  final int sols;

  double get effort => MissionConstants.effortFromTilt(avgTilt);

  /// One-way walking time in hours.
  double get hoursOneWay => km * effort / MissionConstants.walkSpeedKmh;

  double get hoursRoundTrip => 2 * hoursOneWay;

  Leg fraction(double f) =>
      Leg(km: km * f, avgTilt: avgTilt, elevGain: elevGain * f, sols: (sols * f).round());
}

/// What happened after one choice.
class ChoiceOutcome {
  const ChoiceOutcome({
    required this.kind,
    required this.verdict,
    required this.hoursUsed,
    required this.oxygenLeft,
    required this.energyBefore,
    required this.energyAfter,
    required this.radiationMsv,
    required this.points,
    required this.reachedStop,
    this.advised,
  });

  /// The option the player pressed.
  final OptionKind kind;
  final Verdict verdict;

  /// Suit hours actually used.
  final double hoursUsed;
  final double oxygenLeft;
  final double energyBefore;
  final double energyAfter;
  final double radiationMsv;
  final int points;
  final bool reachedStop;

  /// For [OptionKind.askEarth]: the option Earth recommended (and you did).
  final OptionKind? advised;
}

class MissionModel {
  MissionModel._();

  static Verdict verdictFor(
    double roundTripHours, {
    double oxygenHours = MissionConstants.suitHours,
  }) {
    if (roundTripHours <= oxygenHours * (1 - MissionConstants.reserveFraction)) {
      return Verdict.safe;
    }
    if (roundTripHours <= oxygenHours) return Verdict.risky;
    return Verdict.tooFar;
  }

  static double radiationFor(double hours) => MissionConstants.radiationMsvPerDay * hours / 24.0;

  /// Evaluates one option on a real [leg]. Deterministic.
  static ChoiceOutcome evaluate(Leg leg, OptionKind kind, double energyBefore) {
    if (kind == OptionKind.askEarth) {
      final advised = recommend(leg);
      final o = evaluate(leg, advised, energyBefore);
      return ChoiceOutcome(
        kind: OptionKind.askEarth,
        verdict: o.verdict,
        hoursUsed: o.hoursUsed,
        oxygenLeft: o.oxygenLeft,
        energyBefore: o.energyBefore,
        energyAfter: o.energyAfter,
        radiationMsv: o.radiationMsv,
        points: o.points + MissionConstants.penaltyAskEarth,
        reachedStop: o.reachedStop,
        advised: advised,
      );
    }

    final double planned;
    switch (kind) {
      case OptionKind.go:
        planned = leg.hoursRoundTrip;
      case OptionKind.half:
        planned = leg.fraction(0.5).hoursRoundTrip;
      case OptionKind.study:
      case OptionKind.askEarth:
        planned = MissionConstants.studyHours;
    }

    final verdict = verdictFor(planned);
    // Too far: you walk out until only the reserve is left, then turn back.
    final used = verdict == Verdict.tooFar
        ? MissionConstants.suitHours * (1 - MissionConstants.reserveFraction)
        : planned;
    final oxygenLeft = math.max(0.0, MissionConstants.suitHours - used);
    final energyAfter = math.max(0.0, energyBefore - used * MissionConstants.energyPctPerHour);

    int points;
    if (verdict == Verdict.tooFar) {
      points = MissionConstants.penaltyTooFar;
    } else {
      switch (kind) {
        case OptionKind.go:
          points = verdict == Verdict.safe
              ? MissionConstants.pointsGoSafe
              : MissionConstants.pointsGoRisky;
        case OptionKind.half:
          points = verdict == Verdict.safe
              ? MissionConstants.pointsHalfSafe
              : MissionConstants.pointsHalfRisky;
        case OptionKind.study:
        case OptionKind.askEarth:
          points = MissionConstants.pointsStudy;
      }
      points += (oxygenLeft * MissionConstants.bonusPerOxygenHour).round();
    }

    return ChoiceOutcome(
      kind: kind,
      verdict: verdict,
      hoursUsed: used,
      oxygenLeft: oxygenLeft,
      energyBefore: energyBefore,
      energyAfter: energyAfter,
      radiationMsv: radiationFor(used),
      points: points,
      reachedStop: kind == OptionKind.go && verdict != Verdict.tooFar,
    );
  }

  /// Earth's advice: the most ambitious option that is still Safe.
  static OptionKind recommend(Leg leg) {
    if (verdictFor(leg.hoursRoundTrip) == Verdict.safe) return OptionKind.go;
    if (verdictFor(leg.fraction(0.5).hoursRoundTrip) == Verdict.safe) {
      return OptionKind.half;
    }
    return OptionKind.study;
  }
}

enum Achievement { safeWalker, explorer, oxygenSaver, teamPlayer }

/// Final score of a mission.
class MissionSummary {
  MissionSummary(this.outcomes, {this.cardCount = 5});

  final List<ChoiceOutcome> outcomes;
  final int cardCount;

  double get finalEnergy => outcomes.isEmpty ? 100 : outcomes.last.energyAfter;

  int get stopsReached => outcomes.where((o) => o.reachedStop).length;

  double get totalRadiation => outcomes.fold(0.0, (s, o) => s + o.radiationMsv);

  int get score =>
      outcomes.fold<int>(0, (s, o) => s + o.points) +
      (finalEnergy * MissionConstants.bonusPerEnergyPct).round();

  /// At most 3 achievements, in a fixed order.
  List<Achievement> get achievements {
    if (outcomes.isEmpty) return const [];
    final list = <Achievement>[];
    if (outcomes.every((o) => o.verdict != Verdict.tooFar)) list.add(Achievement.safeWalker);
    if (stopsReached >= 3) list.add(Achievement.explorer);
    final avgO2 = outcomes.fold(0.0, (s, o) => s + o.oxygenLeft) / outcomes.length;
    if (avgO2 > 2.0) list.add(Achievement.oxygenSaver);
    if (outcomes.any((o) => o.kind == OptionKind.askEarth)) list.add(Achievement.teamPlayer);
    return list.take(3).toList();
  }
}
