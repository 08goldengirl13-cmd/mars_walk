import 'package:material_ui/material_ui.dart';

import '../i18n/strings.dart';
import '../logic/app_settings.dart';
import '../theme/app_theme.dart';

/// Bottom sheet: base map, overlays, opacity, calm mode.
Future<void> showLayersSheet(BuildContext context, AppSettings settings) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final s = context.s;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.t('layersTitle'), style: AppTheme.title),
                const SizedBox(height: 16),
                Text(s.t('baseMap').toUpperCase(), style: AppTheme.label),
                const SizedBox(height: 8),
                SegmentedButton<BaseMap>(
                  segments: [
                    ButtonSegment(
                      value: BaseMap.viking,
                      label: Text(s.t('baseViking')),
                      icon: const Icon(Icons.public),
                    ),
                    ButtonSegment(
                      value: BaseMap.mola,
                      label: Text(s.t('baseMola')),
                      icon: const Icon(Icons.terrain),
                    ),
                  ],
                  selected: {settings.base},
                  onSelectionChanged: (v) => settings.base = v.first,
                ),
                const SizedBox(height: 16),
                Text(s.t('overlays').toUpperCase(), style: AppTheme.label),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.t('overlayHirise')),
                  value: settings.hirise,
                  onChanged: (v) => settings.hirise = v,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.t('overlayCtx')),
                  value: settings.ctx,
                  onChanged: (v) => settings.ctx = v,
                ),
                Text(s.t('opacity'), style: AppTheme.small),
                Slider(
                  value: settings.overlayOpacity,
                  onChanged: (v) => settings.overlayOpacity = v,
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.t('calmMode')),
                  subtitle: Text(s.t('calmModeHint'), style: AppTheme.small),
                  value: settings.calm,
                  onChanged: (v) => settings.calm = v,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
