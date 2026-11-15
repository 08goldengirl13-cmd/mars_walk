import 'package:material_ui/material_ui.dart';

import '../i18n/strings.dart';
import '../theme/app_theme.dart';

/// Modern conditions at Gale Crater. Approximate values only.
// VERIFY: temperature range (~−90…0 °C), pressure (~0.7–0.9 kPa), surface
// radiation (~0.6 mSv/day) — Curiosity REMS and RAD documentation (PDS).
// Gravity 0.38 g is standard. Strings live in i18n/strings.dart (today*Value).
class MarsTodayCard extends StatelessWidget {
  const MarsTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panelRaised,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.t('todayTitle'), style: AppTheme.label),
          const SizedBox(height: 8),
          _row(Icons.thermostat, s.t('todayTemp'), s.t('todayTempValue')),
          _row(Icons.compress, s.t('todayPressure'), s.t('todayPressureValue')),
          _row(Icons.flare, s.t('todayRadiation'), s.t('todayRadiationValue')),
          _row(Icons.fitness_center, s.t('todayGravity'), s.t('todayGravityValue')),
          const SizedBox(height: 4),
          Text(s.t('todayNote'), style: AppTheme.small.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentSoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label: ', style: AppTheme.small),
                TextSpan(
                  text: value,
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
