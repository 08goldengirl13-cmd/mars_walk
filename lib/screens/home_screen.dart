import 'package:material_ui/material_ui.dart';

import '../data/route_models.dart';
import '../data/stops_content.dart';
import '../i18n/strings.dart';
import '../logic/app_settings.dart';
import '../logic/mission_controller.dart';
import '../logic/playback_controller.dart';
import '../map/mars_map.dart';
import '../theme/app_theme.dart';
import '../widgets/era_scene.dart';
import '../widgets/intro_overlay.dart';
import '../widgets/lang_toggle.dart';
import '../widgets/layer_card.dart';
import '../widgets/layers_sheet.dart';
import '../widgets/mars_today_card.dart';
import '../widgets/stop_card.dart';
import '../widgets/strata_column.dart';
import '../widgets/time_dock.dart';
import 'mission_screen.dart';
import 'sources_screen.dart';

/// Main screen: full map + strata/era panel + time dock (wide), or stacked
/// map / panel / dock (narrow, < 900 px).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.route, required this.settings, this.showIntro = true});

  final RouteData route;
  final AppSettings settings;
  final bool showIntro;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double wideBreakpoint = 900;

  late final PlaybackController _playback = PlaybackController(widget.route);
  late final MissionController _mission = MissionController(
    widget.route,
    onFocusIndex: (i) {
      _playback.jumpToIndex(i);
      _focus.request();
    },
  );
  final TileStatus _tiles = TileStatus();
  final MapFocus _focus = MapFocus();
  final ValueNotifier<int> _era = ValueNotifier(0);

  late bool _showIntro = widget.showIntro;
  bool _missionMode = false;
  int? _selectedStop;

  @override
  void initState() {
    super.initState();
    _era.value = _playback.eraIndex;
    _playback.addListener(() => _era.value = _playback.eraIndex);
  }

  @override
  void dispose() {
    _playback.dispose();
    _mission.dispose();
    _tiles.dispose();
    _focus.dispose();
    _era.dispose();
    super.dispose();
  }

  void _onStopTap(Stop stop, int index) {
    _playback.jumpToIndex(index);
    setState(() => _selectedStop = stops.indexOf(stop));
  }

  void _toggleMission() {
    setState(() {
      _missionMode = !_missionMode;
      _selectedStop = null;
    });
    if (_missionMode) {
      _playback.pause();
      _mission.reset();
    }
  }

  void _openSources() =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => SourcesScreen(route: widget.route)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= wideBreakpoint;
          return Stack(
            children: [
              Positioned.fill(child: wide ? _wideLayout() : _narrowLayout()),
              if (_showIntro)
                Positioned.fill(
                  child: IntroOverlay(onDone: () => setState(() => _showIntro = false)),
                ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------- layouts

  Widget _wideLayout() {
    return Stack(
      children: [
        Positioned.fill(child: _map(uiPadding: const EdgeInsets.fromLTRB(352, 80, 12, 180))),
        Positioned(top: 12, left: 12, right: 12, child: _topBar(wide: true)),
        Positioned(
          top: 80,
          left: 12,
          bottom: 12,
          width: 340,
          child: Container(
            decoration: AppTheme.panelDecoration(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: _missionMode ? _missionPanel() : _explorePanel(wide: true),
            ),
          ),
        ),
        Positioned(
          left: 364,
          right: 12,
          bottom: 12,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: TimeDock(playback: _playback),
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: 364,
          right: 12,
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: _overlays(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return SafeArea(
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(8, 6, 8, 6), child: _topBar(wide: false)),
          Expanded(
            flex: _missionMode ? 40 : 55,
            child: Stack(
              children: [
                Positioned.fill(child: _map(uiPadding: const EdgeInsets.only(bottom: 20))),
                Positioned(top: 8, left: 8, right: 8, child: _overlays()),
              ],
            ),
          ),
          Expanded(
            flex: _missionMode ? 60 : 45,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _missionMode ? _missionPanel() : _explorePanel(wide: false),
            ),
          ),
          if (!_missionMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: TimeDock(playback: _playback, compact: true),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- pieces

  Widget _map({EdgeInsets uiPadding = EdgeInsets.zero}) {
    return ListenableBuilder(
      listenable: _mission,
      builder: (context, _) => MarsMap(
        route: widget.route,
        playback: _playback,
        settings: widget.settings,
        tileStatus: _tiles,
        focus: _focus,
        onStopTap: _onStopTap,
        uiPadding: uiPadding,
        highlightStopId:
            _missionMode &&
                (_mission.phase == MissionPhase.card || _mission.phase == MissionPhase.result)
            ? _mission.toStop.id
            : null,
      ),
    );
  }

  Widget _topBar({required bool wide}) {
    final s = context.s;
    return Container(
      decoration: AppTheme.panelDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          if (wide) ...[
            const Icon(Icons.public, color: AppColors.accent),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.t('appTitle'),
                  style: AppTheme.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (wide)
                  Text(
                    s.t('appSubtitle', {'km': widget.route.totalKm.toStringAsFixed(1)}),
                    style: AppTheme.small,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const LangToggle(),
          const SizedBox(width: 6),
          if (wide) ...[
            FilledButton.icon(
              onPressed: _toggleMission,
              icon: Icon(_missionMode ? Icons.map : Icons.rocket_launch),
              label: Text(_missionMode ? s.t('backToMap') : s.t('btnMission')),
            ),
            IconButton(
              tooltip: s.t('btnLayers'),
              onPressed: () => showLayersSheet(context, widget.settings),
              icon: const Icon(Icons.layers),
            ),
            IconButton(
              tooltip: s.t('btnSources'),
              onPressed: _openSources,
              icon: const Icon(Icons.menu_book),
            ),
            IconButton(
              tooltip: s.t('btnHelp'),
              onPressed: () => setState(() => _showIntro = true),
              icon: const Icon(Icons.help_outline),
            ),
          ] else ...[
            IconButton.filled(
              tooltip: _missionMode ? s.t('backToMap') : s.t('btnMission'),
              onPressed: _toggleMission,
              icon: Icon(_missionMode ? Icons.map : Icons.rocket_launch),
            ),
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert),
              color: AppColors.panelRaised,
              onSelected: (v) {
                if (v == 0) showLayersSheet(context, widget.settings);
                if (v == 1) _openSources();
                if (v == 2) setState(() => _showIntro = true);
              },
              itemBuilder: (context) => [
                _menuItem(0, Icons.layers, s.t('btnLayers')),
                _menuItem(1, Icons.menu_book, s.t('btnSources')),
                _menuItem(2, Icons.help_outline, s.t('btnHelp')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<int> _menuItem(int value, IconData icon, String text) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: AppColors.accentSoft),
        const SizedBox(width: 10),
        Text(text),
      ],
    ),
  );

  /// Banners (demo data / offline tiles) and the tapped-stop card.
  Widget _overlays() {
    final s = context.s;
    return ListenableBuilder(
      listenable: _tiles,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.route.isDemo)
            _Banner(
              color: AppColors.demoBanner,
              icon: Icons.warning_amber,
              text: s.t('demoBanner'),
            ),
          if (_tiles.looksOffline)
            _Banner(
              color: AppColors.warning,
              icon: Icons.cloud_off,
              text: s.t('tilesOffline'),
              onClose: _tiles.dismiss,
            ),
          if (_selectedStop != null && !_missionMode)
            StopCard(
              stop: stops[_selectedStop!],
              number: _selectedStop! + 1,
              point: widget.route.points[stops[_selectedStop!].indexIn(widget.route.points)],
              onClose: () => setState(() => _selectedStop = null),
            ),
        ],
      ),
    );
  }

  Widget _explorePanel({required bool wide}) {
    final s = context.s;
    final scene = ListenableBuilder(
      listenable: Listenable.merge([_era, widget.settings]),
      builder: (context, _) =>
          EraScene(eraIndex: _era.value, calm: widget.settings.calm, height: wide ? 150 : 120),
    );
    final layerCard = ValueListenableBuilder<int>(
      valueListenable: _era,
      builder: (context, era, _) => LayerCard(eraIndex: era),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.t('sceneTitle'), style: AppTheme.label),
        const SizedBox(height: 6),
        if (wide) ...[
          scene,
          const SizedBox(height: 12),
          Text(s.t('strataTitle'), style: AppTheme.label),
          const SizedBox(height: 6),
          StrataColumn(playback: _playback, width: double.infinity, height: 220),
          const SizedBox(height: 10),
          layerCard,
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: scene),
              const SizedBox(width: 8),
              StrataColumn(playback: _playback, width: 150, height: 180),
            ],
          ),
          const SizedBox(height: 10),
          layerCard,
        ],
        const SizedBox(height: 10),
        const MarsTodayCard(),
        const SizedBox(height: 8),
        Text(s.t('stopTapHint'), style: AppTheme.small),
      ],
    );
  }

  Widget _missionPanel() => MissionPanel(mission: _mission, onExit: _toggleMission);
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.icon, required this.text, this.onClose});
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.black87),
            ),
        ],
      ),
    );
  }
}
