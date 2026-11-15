import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../data/route_models.dart';
import '../data/stops_content.dart';
import '../i18n/strings.dart';
import '../logic/app_settings.dart';
import '../logic/playback_controller.dart';
import '../theme/app_theme.dart';
import 'astronaut_marker.dart';
import 'tile_layers.dart';

/// Asks the map to follow the astronaut again and centre on it.
class MapFocus extends ChangeNotifier {
  void request() => notifyListeners();
}

/// Full-screen Mars map: NASA Trek tiles, Curiosity's real route, numbered
/// stops and the astronaut. Uses an equirectangular CRS (Epsg4326), which
/// matches the Mars Trek "EQ" tile grid.
class MarsMap extends StatefulWidget {
  const MarsMap({
    super.key,
    required this.route,
    required this.playback,
    required this.settings,
    required this.tileStatus,
    required this.focus,
    required this.onStopTap,
    this.highlightStopId,
    this.uiPadding = EdgeInsets.zero,
  });

  /// Screen area covered by floating panels (wide layout). The camera keeps
  /// the route and the astronaut inside the uncovered part.
  final EdgeInsets uiPadding;

  final RouteData route;
  final PlaybackController playback;
  final AppSettings settings;
  final TileStatus tileStatus;
  final MapFocus focus;
  final void Function(Stop stop, int index) onStopTap;
  final String? highlightStopId;

  @override
  State<MarsMap> createState() => _MarsMapState();
}

class _MarsMapState extends State<MarsMap> {
  static const double _followZoom = 13.0;

  final MapController _map = MapController();
  late final List<LatLng> _all;
  late final List<int> _stopIdx;
  StreamSubscription<MapEvent>? _events;
  bool _ready = false;
  bool _following = true;

  @override
  void initState() {
    super.initState();
    _all = [for (final p in widget.route.points) LatLng(p.lat, p.lon)];
    _stopIdx = [for (final s in stops) s.indexIn(widget.route.points)];
    widget.playback.addListener(_onPlayback);
    widget.focus.addListener(_onFocusRequest);
  }

  @override
  void dispose() {
    widget.playback.removeListener(_onPlayback);
    widget.focus.removeListener(_onFocusRequest);
    _events?.cancel();
    _map.dispose();
    super.dispose();
  }

  void _onMapReady() {
    _ready = true;
    _events = _map.mapEventStream.listen((event) {
      const userMoves = {
        MapEventSource.dragStart,
        MapEventSource.onDrag,
        MapEventSource.onMultiFinger,
        MapEventSource.flingAnimationController,
        MapEventSource.keyboard,
      };
      if (_following && userMoves.contains(event.source)) {
        setState(() => _following = false);
      }
    });
  }

  LatLng get _astronaut {
    final p = widget.playback.current;
    return LatLng(p.lat, p.lon);
  }

  /// Map centre that puts [target] in the middle of the area NOT covered by
  /// floating panels ([MarsMap.uiPadding]).
  LatLng _centerFor(LatLng target, double zoom) {
    final pad = widget.uiPadding;
    final shift = Offset((pad.left - pad.right) / 2, (pad.top - pad.bottom) / 2);
    if (shift == Offset.zero) return target;
    final cam = _map.camera;
    return cam.unprojectAtZoom(cam.projectAtZoom(target, zoom) - shift, zoom);
  }

  void _onPlayback() {
    if (!_ready || !_following) return;
    final cam = _map.camera;
    if (widget.settings.calm || !widget.playback.isPlaying) {
      _map.move(_centerFor(_astronaut, cam.zoom), cam.zoom);
      return;
    }
    // Ease the camera towards the astronaut while playing.
    const k = 0.12;
    final zoom = cam.zoom < _followZoom ? cam.zoom + (_followZoom - cam.zoom) * 0.04 : cam.zoom;
    final target = _centerFor(_astronaut, zoom);
    final c = cam.center;
    final eased = LatLng(
      c.latitude + (target.latitude - c.latitude) * k,
      c.longitude + (target.longitude - c.longitude) * k,
    );
    _map.move(eased, zoom);
  }

  void _onFocusRequest() {
    if (!mounted) return;
    setState(() => _following = true);
    if (_ready) {
      final zoom = _map.camera.zoom < 12 ? 12.5 : _map.camera.zoom;
      _map.move(_centerFor(_astronaut, zoom), zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.route;
    return Stack(
      children: [
        ListenableBuilder(
          listenable: widget.settings,
          builder: (context, _) => FlutterMap(
            mapController: _map,
            options: MapOptions(
              crs: const Epsg4326(),
              // Start on the route even before the bounds fit runs, so the
              // first tile requests are not for flutter_map's default spot
              // (Europe), which only queues behind the real tiles.
              initialCenter: LatLng((r.minLat + r.maxLat) / 2, (r.minLon + r.maxLon) / 2),
              initialZoom: 12,
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds(LatLng(r.minLat, r.minLon), LatLng(r.maxLat, r.maxLon)),
                padding: widget.uiPadding + const EdgeInsets.all(24),
              ),
              minZoom: 3,
              maxZoom: 17,
              backgroundColor: AppColors.background,
              onMapReady: _onMapReady,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              if (widget.settings.networkTiles) ..._tileLayers(),
              ListenableBuilder(
                listenable: widget.playback,
                builder: (context, _) => PolylineLayer(polylines: _routeLines()),
              ),
              MarkerLayer(markers: _stopMarkers()),
              ListenableBuilder(
                listenable: Listenable.merge([widget.playback, widget.settings]),
                builder: (context, _) => MarkerLayer(
                  markers: [
                    Marker(
                      point: _astronaut,
                      width: 56,
                      height: 56,
                      child: IgnorePointer(child: AstronautMarker(pulse: !widget.settings.calm)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: widget.uiPadding.right + 4,
          top: widget.uiPadding.top > 0 ? widget.uiPadding.top : null,
          bottom: widget.uiPadding.top > 0 ? null : 6,
          child: _Attribution(text: context.s.t('attribution')),
        ),
        if (!_following)
          Positioned(
            right: widget.uiPadding.right + 8,
            bottom: widget.uiPadding.bottom + 12,
            child: FilledButton.icon(
              onPressed: widget.focus.request,
              icon: const Icon(Icons.my_location),
              label: Text(context.s.t('recentre')),
            ),
          ),
      ],
    );
  }

  List<Widget> _tileLayers() {
    final st = widget.settings;
    final base = st.base == BaseMap.viking ? TrekLayers.viking : TrekLayers.mola;
    return [
      baseTileLayer(base, widget.tileStatus),
      if (st.ctx) overlayTileLayer(TrekLayers.ctxGale, st.overlayOpacity),
      if (st.hirise) overlayTileLayer(TrekLayers.hirise, st.overlayOpacity),
    ];
  }

  List<Polyline> _routeLines() {
    final idx = widget.playback.currentIndex.clamp(0, _all.length - 1);
    final walked = <LatLng>[..._all.sublist(0, idx + 1), _astronaut];
    return [
      Polyline(
        points: _all,
        strokeWidth: 3,
        color: AppColors.routeAll.withValues(alpha: 0.75),
        borderStrokeWidth: 1.5,
        borderColor: const Color(0x99000000),
      ),
      Polyline(
        points: walked,
        strokeWidth: 4.5,
        color: AppColors.routeWalked,
        borderStrokeWidth: 1.5,
        borderColor: const Color(0xAA3A1A00),
      ),
    ];
  }

  List<Marker> _stopMarkers() {
    return [
      for (var i = 0; i < stops.length; i++)
        Marker(
          point: _all[_stopIdx[i]],
          width: 34,
          height: 34,
          child: _StopDot(
            number: i + 1,
            label: context.s.tr(stops[i].name),
            highlighted: stops[i].id == widget.highlightStopId,
            onTap: () => widget.onStopTap(stops[i], _stopIdx[i]),
          ),
        ),
    ];
  }
}

class _StopDot extends StatelessWidget {
  const _StopDot({
    required this.number,
    required this.label,
    required this.highlighted,
    required this.onTap,
  });

  final int number;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$number. $label',
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted ? AppColors.accent : AppColors.panel,
              border: Border.all(
                color: highlighted ? Colors.white : AppColors.accentSoft,
                width: 2,
              ),
              boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 6)],
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: highlighted ? Colors.black : AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xAA000000),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    );
  }
}
