import 'package:material_ui/material_ui.dart';

import '../data/route_models.dart';
import '../data/stops_content.dart';
import '../i18n/strings.dart';
import '../theme/app_theme.dart';
import 'objective_chips.dart';

/// Pop-up card for a tapped stop. Sol and elevation come from the route data.
class StopCard extends StatefulWidget {
  const StopCard({
    super.key,
    required this.stop,
    required this.number,
    required this.point,
    required this.onClose,
  });

  final Stop stop;
  final int number;
  final RoutePoint point;
  final VoidCallback onClose;

  @override
  State<StopCard> createState() => _StopCardState();
}

class _StopCardState extends State<StopCard> {
  bool _more = false;

  @override
  void didUpdateWidget(covariant StopCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stop.id != widget.stop.id) _more = false;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final p = widget.point;
    final elev = p.elev.round();
    return Container(
      decoration: AppTheme.panelDecoration(opacity: 0.97),
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent,
                child: Text(
                  '${widget.number}',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(s.tr(widget.stop.name), style: AppTheme.cardTitle)),
              IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.t('chipSol', {'sol': p.sol})} · ${s.t('chipKm', {'km': p.km.toStringAsFixed(1)})} · '
                  '${s.t('chipElev', {'elev': elev < 0 ? '−${-elev}' : '$elev'})}',
                  style: AppTheme.small,
                ),
                const SizedBox(height: 6),
                Text(s.tr(widget.stop.short), style: AppTheme.body),
                if (_more) ...[
                  const SizedBox(height: 6),
                  Text(s.tr(widget.stop.more), style: AppTheme.small.copyWith(fontSize: 13.5)),
                ],
                const SizedBox(height: 8),
                ObjectiveChips(codes: widget.stop.objectiveCodes),
                TextButton(
                  onPressed: () => setState(() => _more = !_more),
                  child: Text(_more ? s.t('less') : s.t('more')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
