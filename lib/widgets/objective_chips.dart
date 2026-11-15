import 'package:material_ui/material_ui.dart';

import '../data/objectives_content.dart';
import '../i18n/strings.dart';
import '../theme/app_theme.dart';

/// Small chips with official NASA Moon to Mars objective codes.
/// Tap / hover shows the plain-language label.
class ObjectiveChips extends StatelessWidget {
  const ObjectiveChips({super.key, required this.codes, this.max = 2});

  final List<String> codes;
  final int max;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final list = codes.where(objectives.containsKey).take(max).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final code in list)
          Tooltip(
            message: '${s.t('objectivesChipTitle')} $code: ${s.tr(objectives[code]!.label)}',
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2A4A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3B5A9A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag_outlined, size: 14, color: Color(0xFF9CC2FF)),
                  const SizedBox(width: 4),
                  Text(
                    'NASA $code',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFCFE0FF),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      s.tr(objectives[code]!.label),
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.small.copyWith(fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
