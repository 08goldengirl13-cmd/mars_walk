import 'package:material_ui/material_ui.dart';

import 'data/route_models.dart';
import 'data/route_repository.dart';
import 'i18n/strings.dart';
import 'logic/app_settings.dart';
import 'map/astronaut_marker.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class MarsWalkApp extends StatefulWidget {
  const MarsWalkApp({
    super.key,
    this.routeOverride,
    this.networkTiles = true,
    this.showIntro = true,
  });

  /// Used by tests to skip asset loading.
  final RouteData? routeOverride;

  /// False in widget tests (no network there).
  final bool networkTiles;
  final bool showIntro;

  @override
  State<MarsWalkApp> createState() => _MarsWalkAppState();
}

class _MarsWalkAppState extends State<MarsWalkApp> {
  final LanguageController _lang = LanguageController();
  late final AppSettings _settings = AppSettings(networkTiles: widget.networkTiles);
  late final Future<RouteData> _route = widget.routeOverride != null
      ? Future.value(widget.routeOverride)
      : RouteRepository.load();

  @override
  void dispose() {
    _lang.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LangScope(
      controller: _lang,
      child: MaterialApp(
        title: 'Mars Walk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: FutureBuilder<RouteData>(
          future: _route,
          builder: (context, snap) {
            if (!snap.hasData) return const _Loading();
            return HomeScreen(route: snap.data!, settings: _settings, showIntro: widget.showIntro);
          },
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AstronautMarker(size: 80),
            const SizedBox(height: 16),
            Text(context.s.t('loading'), style: AppTheme.small),
          ],
        ),
      ),
    );
  }
}
