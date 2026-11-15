import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../i18n/strings.dart';
import '../logic/mission_controller.dart';
import '../logic/mission_model.dart';
import '../theme/app_theme.dart';
import '../widgets/mission_card_view.dart';

/// Mission mode panel: intro → 5 decision cards → end screen.
/// It sits next to (or below) the map; the map jumps to each card's stop.
class MissionPanel extends StatelessWidget {
  const MissionPanel({super.key, required this.mission, required this.onExit});

  final MissionController mission;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ListenableBuilder(
      listenable: mission,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(s.t('missionTitle'), style: AppTheme.label),
                const Spacer(),
                IconButton(
                  tooltip: s.t('missionExit'),
                  onPressed: onExit,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (mission.phase != MissionPhase.intro && mission.phase != MissionPhase.end)
              _ProgressDots(done: mission.outcomes.length, total: mission.cardCount),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey('${mission.phase}-${mission.cardIndex}'),
                child: _body(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    final s = context.s;
    switch (mission.phase) {
      case MissionPhase.intro:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.t('missionGoal'), style: AppTheme.title),
            const SizedBox(height: 10),
            Text(
              s.t('missionRules', {
                'oxygen': MissionConstants.suitHours.round(),
                'reserve': (MissionConstants.reserveFraction * 100).round(),
              }),
              style: AppTheme.body,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: mission.start,
              icon: const Icon(Icons.play_arrow),
              label: Text(s.t('missionStart')),
            ),
            const SizedBox(height: 8),
            Text(s.t('modelNote'), style: AppTheme.small.copyWith(fontSize: 11.5)),
          ],
        );
      case MissionPhase.card:
        return MissionCardView(
          card: mission.card,
          leg: mission.leg,
          from: mission.fromStop,
          to: mission.toStop,
          number: mission.cardIndex + 1,
          total: mission.cardCount,
          onChoose: mission.choose,
        );
      case MissionPhase.result:
        return MissionResultView(
          card: mission.card,
          outcome: mission.lastOutcome!,
          to: mission.toStop,
          totalRadiation: mission.totalRadiation,
          isLast: mission.cardIndex + 1 >= mission.cardCount,
          onNext: mission.next,
        );
      case MissionPhase.end:
        return _EndView(mission: mission, onExit: onExit);
    }
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++)
          Expanded(
            child: Container(
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i < done ? AppColors.accent : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}

class _EndView extends StatefulWidget {
  const _EndView({required this.mission, required this.onExit});
  final MissionController mission;
  final VoidCallback onExit;

  @override
  State<_EndView> createState() => _EndViewState();
}

class _EndViewState extends State<_EndView> {
  bool _copied = false;

  String _achText(S s, Achievement a) => switch (a) {
    Achievement.safeWalker => s.t('achSafe'),
    Achievement.explorer => s.t('achExplorer'),
    Achievement.oxygenSaver => s.t('achSaver'),
    Achievement.teamPlayer => s.t('achTeam'),
  };

  Future<void> _copy(S s, MissionSummary sum) async {
    final text = s.t('shareText', {
      'score': sum.score,
      'stops': sum.stopsReached,
      'total': sum.cardCount,
    });
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final sum = widget.mission.summary;
    final summary = sum.stopsReached >= 3 && sum.achievements.contains(Achievement.safeWalker)
        ? s.t('summaryGreat')
        : sum.score > 150
        ? s.t('summaryOk')
        : s.t('summaryLow');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.t('endTitle'), style: AppTheme.title),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: sum.score),
              duration: const Duration(milliseconds: 1200),
              builder: (context, v, _) => Text(
                '$v',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentSoft,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(s.t('score'), style: AppTheme.label),
            ),
          ],
        ),
        Text(
          s.t('stopsReached', {'n': sum.stopsReached, 'total': sum.cardCount}),
          style: AppTheme.body,
        ),
        const SizedBox(height: 4),
        Text(summary, style: AppTheme.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(s.t('achievements').toUpperCase(), style: AppTheme.label),
        const SizedBox(height: 6),
        if (sum.achievements.isEmpty) Text(s.t('achNone'), style: AppTheme.small),
        for (final a in sum.achievements)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.military_tech, color: AppColors.accentSoft),
                const SizedBox(width: 6),
                Expanded(child: Text(_achText(s, a), style: AppTheme.body)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _copy(s, sum),
          icon: Icon(_copied ? Icons.check : Icons.copy),
          label: Text(_copied ? s.t('copied') : s.t('copyResult')),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _copied = false);
                  widget.mission.start();
                },
                child: Text(s.t('playAgain')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(onPressed: widget.onExit, child: Text(s.t('backToMap'))),
            ),
          ],
        ),
      ],
    );
  }
}
