import 'package:material_ui/material_ui.dart';

import '../data/strata_content.dart';
import '../i18n/strings.dart';
import '../theme/app_theme.dart';

/// Explains the rock layer the astronaut is climbing right now.
/// Two short sentences; the longer text is behind "More".
class LayerCard extends StatefulWidget {
  const LayerCard({super.key, required this.eraIndex});
  final int eraIndex;

  @override
  State<LayerCard> createState() => _LayerCardState();
}

class _LayerCardState extends State<LayerCard> {
  bool _more = false;

  @override
  void didUpdateWidget(covariant LayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eraIndex != widget.eraIndex) _more = false;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final era = eras[widget.eraIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(era.id),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.panelRaised,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border(left: BorderSide(color: era.bandColor, width: 5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.t('currentLayer'), style: AppTheme.label),
            const SizedBox(height: 4),
            Text(s.tr(era.name), style: AppTheme.cardTitle),
            const SizedBox(height: 6),
            Text(s.tr(era.short), style: AppTheme.body),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _more
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(s.tr(era.more), style: AppTheme.small.copyWith(fontSize: 13.5)),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _more = !_more),
                child: Text(_more ? s.t('less') : s.t('more')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
