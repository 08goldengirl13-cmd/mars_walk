import 'package:material_ui/material_ui.dart';

import '../i18n/strings.dart';
import '../logic/playback_controller.dart';
import '../theme/app_theme.dart';
import 'elevation_profile.dart';

/// The "Time Machine" controls: play/pause, speed, restart, sol slider, live
/// stat chips and the elevation profile.
class TimeDock extends StatelessWidget {
  const TimeDock({super.key, required this.playback, this.compact = false});

  final PlaybackController playback;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      decoration: AppTheme.panelDecoration(),
      padding: EdgeInsets.fromLTRB(12, 8, 12, compact ? 8 : 12),
      child: ListenableBuilder(
        listenable: playback,
        builder: (context, _) {
          final p = playback.current;
          final route = playback.route;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton.filled(
                    tooltip: playback.isPlaying ? s.t('pause') : s.t('play'),
                    onPressed: playback.toggle,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: Icon(playback.isPlaying ? Icons.pause : Icons.play_arrow, size: 28),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: s.t('restart'),
                    onPressed: playback.restart,
                    icon: const Icon(Icons.replay),
                  ),
                  _SpeedButton(playback: playback),
                  Expanded(
                    child: Semantics(
                      label: s.t('sliderLabel'),
                      value: 'Sol ${p.sol}',
                      child: Slider(
                        value: playback.position,
                        min: 0,
                        max: playback.maxIndex.toDouble(),
                        onChanged: playback.seek,
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Chip(icon: Icons.wb_sunny_outlined, text: s.t('chipSol', {'sol': p.sol})),
                  _Chip(
                    icon: Icons.directions_walk,
                    text: s.t('chipKm', {'km': p.km.toStringAsFixed(1)}),
                  ),
                  _Chip(icon: Icons.terrain, text: s.t('chipElev', {'elev': _signed(p.elev)})),
                  _Chip(
                    icon: Icons.signal_cellular_alt,
                    text: s.t('chipTilt', {'tilt': p.tilt.round()}),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Semantics(
                label: s.t('profileLabel'),
                child: ElevationProfile(route: route, distM: p.distM, height: compact ? 40 : 56),
              ),
              if (playback.reachedEnd) ...[
                const SizedBox(height: 8),
                Text(
                  s.t('funFact', {
                    'km': route.totalKm.toStringAsFixed(1),
                    'sols': route.solCount,
                    'climb': route.climbM.round(),
                    'marathons': (route.totalKm / 42.195).toStringAsFixed(1),
                  }),
                  style: const TextStyle(
                    color: AppColors.accentSoft,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Uses a real minus sign for negative elevations.
  static String _signed(double v) {
    final r = v.round();
    return r < 0 ? '−${-r}' : '$r';
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.playback});
  final PlaybackController playback;

  @override
  Widget build(BuildContext context) {
    final speeds = PlaybackController.speeds;
    final i = speeds.indexOf(playback.speed);
    return Tooltip(
      message: context.s.t('speed'),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          foregroundColor: AppColors.accentSoft,
        ),
        onPressed: () => playback.setSpeed(speeds[(i + 1) % speeds.length]),
        child: Text(
          '${playback.speed.toStringAsFixed(0)}×',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.panelRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentSoft),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
