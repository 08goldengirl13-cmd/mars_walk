import 'package:material_ui/material_ui.dart';

import '../i18n/strings.dart';
import '../theme/app_theme.dart';

/// EN / UZ switch.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LangScope.controllerOf(context);
    return Semantics(
      label: context.s.t('btnLanguage'),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.panelRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final l in Lang.values)
              GestureDetector(
                onTap: () => controller.lang = l,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: controller.lang == l ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(
                    l.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: controller.lang == l ? Colors.black : AppColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
