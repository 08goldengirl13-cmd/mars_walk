import 'dart:ui' show Color, lerpDouble;

import 'package:flutter/animation.dart' show Tween;

/// Everything the "Mars of that time" scene needs to draw one era.
/// These are artistic choices, not measurements.
class EraVisualState {
  const EraVisualState({
    required this.skyTop,
    required this.skyBottom,
    required this.ground,
    required this.water,
    required this.streams,
    required this.dust,
    required this.sun,
    required this.wind,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color ground;

  /// Lake level 0 (dry) … 1 (full lake).
  final double water;

  /// How visible flowing streams are, 0…1.
  final double streams;

  /// Amount of drifting dust, 0…1.
  final double dust;

  /// Sun brightness 0…1.
  final double sun;

  /// Wind speed for dust drift 0…1.
  final double wind;

  static EraVisualState lerp(EraVisualState a, EraVisualState b, double t) {
    double d(double x, double y) => lerpDouble(x, y, t)!;
    return EraVisualState(
      skyTop: Color.lerp(a.skyTop, b.skyTop, t)!,
      skyBottom: Color.lerp(a.skyBottom, b.skyBottom, t)!,
      ground: Color.lerp(a.ground, b.ground, t)!,
      water: d(a.water, b.water),
      streams: d(a.streams, b.streams),
      dust: d(a.dust, b.dust),
      sun: d(a.sun, b.sun),
      wind: d(a.wind, b.wind),
    );
  }
}

/// Tween used for the ~1.5 s cross-fade between eras.
class EraVisualTween extends Tween<EraVisualState> {
  EraVisualTween({required EraVisualState begin, required EraVisualState end})
    : super(begin: begin, end: end);

  @override
  EraVisualState lerp(double t) => EraVisualState.lerp(begin!, end!, t);
}
