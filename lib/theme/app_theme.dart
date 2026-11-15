import 'package:material_ui/material_ui.dart';

/// Every colour and text style of the app lives here, so the look can be
/// changed in one place.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0D1A);
  static const Color panel = Color(0xFF12152A);
  static const Color panelRaised = Color(0xFF1A1E38);
  static const Color border = Color(0xFF2A2F55);

  static const Color accent = Color(0xFFFF8A4C); // Mars orange
  static const Color accentSoft = Color(0xFFFFC24C); // amber
  static const Color safe = Color(0xFF4CD39A);
  static const Color warning = Color(0xFFFFC24C);
  static const Color danger = Color(0xFFFF5D5D);

  static const Color text = Color(0xFFF2F4FF);
  static const Color muted = Color(0xFF9AA3C7);

  static const Color routeAll = Color(0xFFB8BCD6);
  static const Color routeWalked = Color(0xFFFFB347);
  static const Color demoBanner = Color(0xFFFFD54F);
}

class AppTheme {
  AppTheme._();

  static const double radius = 14;
  static const double gap = 12;

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.accent, brightness: Brightness.dark)
        .copyWith(
          primary: AppColors.accent,
          secondary: AppColors.accentSoft,
          surface: AppColors.panel,
          error: AppColors.danger,
          onPrimary: Colors.black,
          onSurface: AppColors.text,
        );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.text, displayColor: AppColors.text)
          .copyWith(
            bodyMedium: const TextStyle(fontSize: 14, color: AppColors.text, height: 1.35),
            bodySmall: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.3),
          ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.accentSoft,
        overlayColor: Color(0x33FF8A4C),
        trackHeight: 4,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size(44, 44),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size(44, 44),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.panel,
        showDragHandle: true,
      ),
      dividerColor: AppColors.border,
    );
  }

  /// Decoration for floating panels on top of the map.
  static BoxDecoration panelDecoration({double opacity = 0.94}) => BoxDecoration(
    color: AppColors.panel.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.border),
    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.muted,
  );
  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.text, height: 1.35);
  static const TextStyle small = TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.3);
}
