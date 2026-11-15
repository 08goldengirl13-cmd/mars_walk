import 'package:material_ui/material_ui.dart';

import '../i18n/strings.dart';
import '../map/astronaut_marker.dart';
import '../theme/app_theme.dart';
import 'lang_toggle.dart';

/// Three short first-launch slides. "Seen" is kept in memory only.
class IntroOverlay extends StatefulWidget {
  const IntroOverlay({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<IntroOverlay> createState() => _IntroOverlayState();
}

class _IntroOverlayState extends State<IntroOverlay> {
  final PageController _pages = PageController();
  int _page = 0;

  static const _slides = [
    ('intro1Title', 'intro1Body', Icons.person_pin_circle),
    ('intro2Title', 'intro2Body', Icons.smart_toy_outlined),
    ('intro3Title', 'intro3Body', Icons.play_circle_fill),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _slides.length - 1) {
      widget.onDone();
    } else {
      _pages.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final last = _page == _slides.length - 1;
    return Material(
      color: const Color(0xE60B0D1A),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: AppTheme.panelDecoration(opacity: 1),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const LangToggle(),
                        const Spacer(),
                        TextButton(onPressed: widget.onDone, child: Text(s.t('skip'))),
                      ],
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pages,
                        itemCount: _slides.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, i) {
                          final (title, body, icon) = _slides[i];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (i == 0)
                                const AstronautMarker(size: 96)
                              else
                                Icon(icon, size: 72, color: AppColors.accent),
                              const SizedBox(height: 20),
                              Text(
                                s.t(title),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                s.t(body),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _slides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            width: i == _page ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _page ? AppColors.accent : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _next,
                          child: Text(last ? s.t('start') : s.t('next')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
