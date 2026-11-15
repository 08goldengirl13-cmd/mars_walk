import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../data/route_models.dart';
import '../data/strata_content.dart';
import 'geo.dart';

/// Drives the "Time Machine": a fractional position along the route that
/// moves while playing. The whole route takes [journeySeconds] at 1×,
/// no matter how many waypoints there are.
class PlaybackController extends ChangeNotifier {
  PlaybackController(this.route);

  final RouteData route;

  static const double journeySeconds = 45.0;

  /// Speed button cycles through these; the first one is the default.
  /// At 0.5× the whole route takes 90 s (45 s at 1×).
  static const List<double> speeds = [0.5, 1, 2, 4];
  static const double defaultSpeed = 0.5;

  double _position = 0;
  bool _isPlaying = false;
  double _speed = defaultSpeed;
  bool _reachedEnd = false;

  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  double get position => _position;
  bool get isPlaying => _isPlaying;
  double get speed => _speed;

  /// True after playback ran all the way to the end (cleared on seek/restart).
  bool get reachedEnd => _reachedEnd;

  int get maxIndex => route.length - 1;
  double get progress => maxIndex == 0 ? 0 : _position / maxIndex;
  double get pointsPerSecond => maxIndex / journeySeconds;

  RoutePoint get current => pointAt(route.points, _position);
  int get currentIndex => _position.floor();
  int get sol => current.sol;
  double get km => current.km;
  double get elevation => current.elev;
  double get tilt => current.tilt;
  int get eraIndex => eraIndexForSol(sol);
  String get eraId => eras[eraIndex].id;

  void play() {
    if (_isPlaying) return;
    if (_position >= maxIndex) _position = 0;
    _reachedEnd = false;
    _isPlaying = true;
    _ticker ??= Ticker(_onTick, debugLabel: 'playback');
    _lastTick = Duration.zero;
    if (!_ticker!.isActive) _ticker!.start();
    notifyListeners();
  }

  void pause() {
    if (!_isPlaying) return;
    _isPlaying = false;
    _ticker?.stop();
    notifyListeners();
  }

  void toggle() => _isPlaying ? pause() : play();

  void restart() {
    _ticker?.stop();
    _isPlaying = false;
    _position = 0;
    _reachedEnd = false;
    notifyListeners();
    play();
  }

  void setSpeed(double value) {
    _speed = value;
    notifyListeners();
  }

  /// Jump to a fractional index. Does not stop playback.
  void seek(double position) {
    _position = position.clamp(0.0, maxIndex.toDouble());
    _reachedEnd = false;
    notifyListeners();
  }

  void jumpToIndex(int index) {
    pause();
    seek(index.toDouble());
  }

  void jumpToSol(int sol) => jumpToIndex(indexForSol(route.points, sol));

  /// Advances playback by [seconds] of real time. Public for tests.
  void advanceBy(double seconds) {
    if (seconds <= 0) return;
    _position += seconds * pointsPerSecond * _speed;
    if (_position >= maxIndex) {
      _position = maxIndex.toDouble();
      _isPlaying = false;
      _reachedEnd = true;
      _ticker?.stop();
    }
    notifyListeners();
  }

  /// Longest frame gap still counted as playing time. Slow frames (a busy
  /// phone, the map decoding many tiles) keep real-time speed; a longer gap
  /// means the tab was hidden, and that time is skipped.
  static const double maxFrameGapSeconds = 1.0;

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    advanceBy(frameAdvance(dt));
  }

  /// Seconds of playback for a frame that took [dt] seconds. Public for tests.
  static double frameAdvance(double dt) => (dt <= 0 || dt > maxFrameGapSeconds) ? 0 : dt;

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}
