import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/objectives_content.dart';
import '../data/route_models.dart';
import '../data/sources_content.dart';
import '../i18n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/lang_toggle.dart';

/// Every NASA dataset we use, what for, and an honesty note.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key, required this.route});

  final RouteData route;

  static const String objectivesUrl = 'https://www.nasa.gov/MoonToMarsArchitecture';

  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final failText = context.s.t('linkFailed');
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) messenger.showSnackBar(SnackBar(content: Text(failText)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final usedCodes = objectives.keys.toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title: Text(s.t('sourcesTitle')),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: LangToggle())],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.t('sourcesIntro'), style: AppTheme.body.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              _Note(icon: Icons.info_outline, text: s.t('honesty')),
              const SizedBox(height: 8),
              _Note(
                icon: Icons.route,
                text: s.t('routeInfo', {
                  'source': route.source,
                  'date': route.downloaded.isEmpty ? '—' : route.downloaded,
                  'n': route.length,
                }),
              ),
              const SizedBox(height: 16),
              for (final src in dataSources)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Text(src.name, style: AppTheme.cardTitle)),
                              if (src.approximation) _Tag(text: s.t('approxTag')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${s.t('usedFor')}: ${s.tr(src.usedFor)}', style: AppTheme.body),
                          if (src.url != null) ...[
                            const SizedBox(height: 4),
                            SelectableText(src.url!, style: AppTheme.small),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _open(context, src.url!),
                                icon: const Icon(Icons.open_in_new, size: 18),
                                label: Text(s.t('openLink')),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(s.t('objectivesTitle'), style: AppTheme.title),
              const SizedBox(height: 6),
              Text(s.t('objectivesNote'), style: AppTheme.small),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _open(context, objectivesUrl),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text(objectivesUrl),
                ),
              ),
              for (final code in usedCodes)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 64,
                    child: Text(
                      code,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFCFE0FF)),
                    ),
                  ),
                  title: Text(s.tr(objectives[code]!.label), style: AppTheme.body),
                  subtitle: Text(
                    '${objectives[code]!.appliesTo} · PDF p. ${objectives[code]!.pdfPage}',
                    style: AppTheme.small,
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panelRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentSoft, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTheme.body)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
