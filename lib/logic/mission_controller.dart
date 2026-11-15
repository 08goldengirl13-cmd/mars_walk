import 'package:flutter/foundation.dart';

import '../data/cards_content.dart';
import '../data/route_models.dart';
import '../data/stops_content.dart';
import 'mission_model.dart';

enum MissionPhase { intro, card, result, end }

/// Flow of Mission mode. Legs are computed from real NASA waypoints.
class MissionController extends ChangeNotifier {
  MissionController(this.route, {this.onFocusIndex});

  final RouteData route;

  /// Called with a route index when the map should jump to a stop.
  final void Function(int index)? onFocusIndex;

  MissionPhase _phase = MissionPhase.intro;
  int _cardIndex = 0;
  final List<ChoiceOutcome> _outcomes = [];

  MissionPhase get phase => _phase;
  int get cardIndex => _cardIndex;
  int get cardCount => missionCards.length;
  MissionCard get card => missionCards[_cardIndex];
  List<ChoiceOutcome> get outcomes => List.unmodifiable(_outcomes);
  ChoiceOutcome? get lastOutcome => _outcomes.isEmpty ? null : _outcomes.last;
  MissionSummary get summary => MissionSummary(_outcomes, cardCount: cardCount);

  double get energy => _outcomes.isEmpty ? 100.0 : _outcomes.last.energyAfter;
  double get totalRadiation => summary.totalRadiation;

  static Stop stopById(String id) => stops.firstWhere((s) => s.id == id);

  /// Stop the leg of [card] starts from (the stop before it in the list).
  static Stop fromStopFor(MissionCard card) {
    final i = stops.indexWhere((s) => s.id == card.stopId);
    return stops[i <= 0 ? 0 : i - 1];
  }

  Stop get toStop => stopById(card.stopId);
  Stop get fromStop => fromStopFor(card);

  Leg legFor(MissionCard card) {
    final from = fromStopFor(card).indexIn(route.points);
    final to = stopById(card.stopId).indexIn(route.points);
    return Leg.between(route.points, from, to);
  }

  Leg get leg => legFor(card);

  void start() {
    _outcomes.clear();
    _cardIndex = 0;
    _phase = MissionPhase.card;
    _focus(toStop);
    notifyListeners();
  }

  void choose(OptionKind kind) {
    if (_phase != MissionPhase.card) return;
    final outcome = MissionModel.evaluate(leg, kind, energy);
    _outcomes.add(outcome);
    _phase = MissionPhase.result;
    notifyListeners();
  }

  void next() {
    if (_phase != MissionPhase.result) return;
    if (_cardIndex + 1 >= cardCount) {
      _phase = MissionPhase.end;
    } else {
      _cardIndex++;
      _phase = MissionPhase.card;
      _focus(toStop);
    }
    notifyListeners();
  }

  void reset() {
    _outcomes.clear();
    _cardIndex = 0;
    _phase = MissionPhase.intro;
    notifyListeners();
  }

  void _focus(Stop stop) => onFocusIndex?.call(stop.indexIn(route.points));
}
