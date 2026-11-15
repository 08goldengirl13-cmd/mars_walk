import 'package:flutter/foundation.dart';

enum BaseMap { viking, mola }

/// Map layer choices and comfort options.
class AppSettings extends ChangeNotifier {
  AppSettings({this.networkTiles = true});

  /// False only in widget tests (no network there).
  final bool networkTiles;

  BaseMap _base = BaseMap.viking;
  bool _hirise = true;
  bool _ctx = false;
  double _overlayOpacity = 1.0;
  bool _calm = false;

  BaseMap get base => _base;
  bool get hirise => _hirise;
  bool get ctx => _ctx;
  double get overlayOpacity => _overlayOpacity;

  /// Less motion: no camera easing and a still era scene.
  bool get calm => _calm;

  set base(BaseMap v) => _set(() => _base = v);
  set hirise(bool v) => _set(() => _hirise = v);
  set ctx(bool v) => _set(() => _ctx = v);
  set overlayOpacity(double v) => _set(() => _overlayOpacity = v.clamp(0.0, 1.0));
  set calm(bool v) => _set(() => _calm = v);

  void _set(void Function() change) {
    change();
    notifyListeners();
  }
}

/// Counts failed base-map tiles so the UI can show an "offline" message.
/// The base maps cover the whole planet, so their errors mean a network
/// problem (overlay 404s outside coverage are normal and not counted).
class TileStatus extends ChangeNotifier {
  int _errors = 0;
  bool _dismissed = false;

  bool get looksOffline => _errors >= 4 && !_dismissed;

  void reportError() {
    _errors++;
    if (_errors == 4) notifyListeners();
  }

  void dismiss() {
    _dismissed = true;
    notifyListeners();
  }
}
