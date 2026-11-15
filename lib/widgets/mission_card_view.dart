import 'package:material_ui/material_ui.dart';

import '../data/cards_content.dart';
import '../data/stops_content.dart';
import '../i18n/strings.dart';
import '../logic/mission_model.dart';
import '../theme/app_theme.dart';
import 'objective_chips.dart';

String fmt1(double v) => v.toStringAsFixed(1);

String optionLabel(S s, OptionKind kind, Stop to) {
  switch (kind) {
    case OptionKind.go:
      return s.t('optGo', {'stop': s.tr(to.name)});
    case OptionKind.half:
      return s.t('optHalf');
    case OptionKind.study:
      return s.t('optStudy');
    case OptionKind.askEarth:
      return s.t('optAskEarth');
  }
}

IconData optionIcon(OptionKind kind) => switch (kind) {
  OptionKind.go => Icons.directions_walk,
  OptionKind.half => Icons.science_outlined,
  OptionKind.study => Icons.search,
  OptionKind.askEarth => Icons.satellite_alt,
};

/// One decision card: scenario built from a real leg + big option buttons.
class MissionCardView extends StatelessWidget {
  const MissionCardView({
    super.key,
    required this.card,
    required this.leg,
    required this.from,
    required this.to,
    required this.number,
    required this.total,
    required this.onChoose,
  });

  final MissionCard card;
  final Leg leg;
  final Stop from;
  final Stop to;
  final int number;
  final int total;
  final ValueChanged<OptionKind> onChoose;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final params = <String, Object>{
      'from': s.tr(from.name),
      'to': s.tr(to.name),
      'km': fmt1(leg.km),
      'hours': fmt1(leg.hoursRoundTrip),
      'oxygen': MissionConstants.suitHours.round(),
      'gain': leg.elevGain.round(),
    };
    var scenario = s.tr(card.scenario);
    params.forEach((k, v) => scenario = scenario.replaceAll('{$k}', '$v'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.t('cardOf', {'n': number, 'total': total}).toUpperCase(), style: AppTheme.label),
        const SizedBox(height: 4),
        Text(s.tr(to.name), style: AppTheme.title),
        const SizedBox(height: 8),
        Text(scenario, style: AppTheme.body.copyWith(fontSize: 15)),
        const SizedBox(height: 8),
        Text(
          // A negative gain reads as "m down" instead of "−19 m up".
          s.t(leg.elevGain.round() < 0 ? 'legFactsDown' : 'legFacts', {
            'km': fmt1(leg.km),
            'gain': leg.elevGain.round().abs(),
            'tilt': leg.avgTilt.round(),
            'sols': leg.sols,
          }),
          style: AppTheme.small,
        ),
        const SizedBox(height: 10),
        ObjectiveChips(codes: card.objectiveCodes),
        const SizedBox(height: 14),
        for (final kind in card.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                side: const BorderSide(color: AppColors.accent),
              ),
              onPressed: () => onChoose(kind),
              icon: Icon(optionIcon(kind), color: AppColors.accentSoft),
              label: Text(
                optionLabel(s, kind, to),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        Text(s.t('modelNote'), style: AppTheme.small.copyWith(fontSize: 11.5)),
      ],
    );
  }
}

/// Safe / Risky / Too far — with icon and text, not colour alone.
class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.verdict});
  final Verdict verdict;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final (color, icon, key) = switch (verdict) {
      Verdict.safe => (AppColors.safe, Icons.check_circle, 'verdictSafe'),
      Verdict.risky => (AppColors.warning, Icons.warning_amber_rounded, 'verdictRisky'),
      Verdict.tooFar => (AppColors.danger, Icons.cancel, 'verdictTooFar'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            s.t(key),
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Animated bar from [before] to [after] (both in 0…[max]).
class ResourceBar extends StatelessWidget {
  const ResourceBar({
    super.key,
    required this.label,
    required this.before,
    required this.after,
    required this.max,
    required this.valueText,
    required this.color,
  });

  final String label;
  final double before;
  final double after;
  final double max;
  final String Function(double v) valueText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: before, end: after),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label, style: AppTheme.small)),
                Text(valueText(v), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: max <= 0 ? 0 : (v / max).clamp(0.0, 1.0),
                minHeight: 10,
                color: color,
                backgroundColor: AppColors.border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown after a choice: verdict, resources, what NASA did, the lesson.
class MissionResultView extends StatelessWidget {
  const MissionResultView({
    super.key,
    required this.card,
    required this.outcome,
    required this.to,
    required this.totalRadiation,
    required this.isLast,
    required this.onNext,
  });

  final MissionCard card;
  final ChoiceOutcome outcome;
  final Stop to;
  final double totalRadiation;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final o = outcome;
    final verdictText = switch (o.verdict) {
      Verdict.safe => s.t('verdictSafeText'),
      Verdict.risky => s.t('verdictRiskyText'),
      Verdict.tooFar => s.t('verdictTooFarText'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            VerdictBadge(verdict: o.verdict),
            const Spacer(),
            Text(
              s.t('points', {'points': o.points > 0 ? '+${o.points}' : '${o.points}'}),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: o.points >= 0 ? AppColors.safe : AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (o.advised != null) ...[
          Text(
            s.t('askEarthText', {'choice': optionLabel(s, o.advised!, to)}),
            style: AppTheme.body,
          ),
          const SizedBox(height: 6),
        ],
        Text(verdictText, style: AppTheme.body),
        const SizedBox(height: 4),
        Text(s.t('resWalk', {'hours': fmt1(o.hoursUsed)}), style: AppTheme.small),
        const SizedBox(height: 10),
        ResourceBar(
          label: s.t('resOxygen'),
          before: MissionConstants.suitHours,
          after: o.oxygenLeft,
          max: MissionConstants.suitHours,
          valueText: (v) => '${fmt1(v)} h',
          color: o.verdict == Verdict.safe ? AppColors.safe : AppColors.warning,
        ),
        ResourceBar(
          label: s.t('resEnergy'),
          before: o.energyBefore,
          after: o.energyAfter,
          max: 100,
          valueText: (v) => '${v.round()} %',
          color: AppColors.accentSoft,
        ),
        Row(
          children: [
            const Icon(Icons.flare, size: 18, color: AppColors.accentSoft),
            const SizedBox(width: 6),
            Text('${s.t('resRadiation')}: ', style: AppTheme.small),
            Expanded(
              child: Text(
                s.t('resRadValue', {
                  'dose': o.radiationMsv.toStringAsFixed(2),
                  'total': totalRadiation.toStringAsFixed(2),
                }),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoBox(
          title: s.t('whatNasaDid'),
          text: s.tr(card.nasaDid),
          color: const Color(0xFF3B5A9A),
        ),
        const SizedBox(height: 8),
        _InfoBox(title: s.t('takeaway'), text: s.tr(card.takeaway), color: AppColors.accent),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onNext,
          icon: Icon(isLast ? Icons.emoji_events : Icons.arrow_forward),
          label: Text(isLast ? s.t('finish') : s.t('nextCard')),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.text, required this.color});
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.label),
          const SizedBox(height: 4),
          Text(text, style: AppTheme.body),
        ],
      ),
    );
  }
}
