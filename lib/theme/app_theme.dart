import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ───────────────────────── App-wide design tokens ─────────────────────────
/// Единая тёмная сине-чёрная тема для всего приложения.
/// Используется на ВСЕХ экранах, чтобы визуально они были одним целым.

// Фон — глубокий чёрно-синий градиент
const List<Color> kBgGradientColors = [
  Color(0xFF03050A),
  Color(0xFF070C1D),
  Color(0xFF0B1638),
  Color(0xFF0A1230),
];

const Alignment kBgGradientBegin = Alignment.topLeft;
const Alignment kBgGradientEnd = Alignment.bottomRight;

const LinearGradient kBgGradient = LinearGradient(
  begin: kBgGradientBegin,
  end: kBgGradientEnd,
  colors: kBgGradientColors,
  stops: [0.0, 0.35, 0.7, 1.0],
);

// Акцентный синий градиент (кнопки, активные состояния, свечения)
const LinearGradient kAccentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF3E7BFA), Color(0xFF1633A6)],
);

const Color kAccent = Color(0xFF4C86FF);
const Color kAccentDeep = Color(0xFF1B3FCE);
const Color kAccentLight = Color(0xFF9DBBFF);
const Color kAccentBg = Color(0x264C86FF);

// Стеклянная поверхность карточек поверх тёмного фона
const Color kSurface = Color(0xFF121A33);
const LinearGradient kSurfaceGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF17203F), Color(0xFF0E1530)],
);
const Color kBorder = Color(0x1EFFFFFF); // тонкая белая обводка ~12%
const Color kBorderStrong = Color(0x33FFFFFF);

// Семантические цвета — подобраны так, чтобы «дышать» на тёмном фоне
const Color kGreen = Color(0xFF35E0A0);
const Color kGreenBg = Color(0x2635E0A0);
const Color kClay = Color(0xFFFF6B62);
const Color kClayBg = Color(0x26FF6B62);
const Color kAmber = Color(0xFFFFB84D);
const Color kAmberBg = Color(0x26FFB84D);

// Текст
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFFAEB7D6);
const Color kTextMuted = Color(0xFF6E769A);

TextStyle appDisplay({
  double fontSize = 24,
  FontWeight fontWeight = FontWeight.w700,
  Color color = kTextPrimary,
  double? height,
}) =>
    GoogleFonts.golosText(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );

TextStyle appBody({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w500,
  Color color = kTextPrimary,
  double? height,
  double? letterSpacing,
}) =>
    GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

/// Полноэкранный фон-градиент, который использует каждый экран приложения.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool safeArea;
  const AppBackground({super.key, required this.child, this.safeArea = true});

  @override
  Widget build(BuildContext context) {
    // 🔴 ТҮЗЕТІЛДІ: DecoratedBox орнына экранды толық жабатын Container
    final content = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // мягкое синее свечение сверху-справа для «мощности»
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kAccent.withOpacity(0.20), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kAccentDeep.withOpacity(0.18), Colors.transparent],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
    return safeArea ? SafeArea(child: content) : content;
  }
}

/// Стеклянная карточка — базовый строительный блок всех экранов.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.gradient,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? kSurface) : null,
        gradient: gradient ?? (color == null ? kSurfaceGradient : null),
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: kBorder),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: child,
    );
  }
}

/// Кнопка с акцентным градиентом.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double verticalPadding;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.verticalPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: kAccentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kAccent.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: verticalPadding),
              child: Center(
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(label,
                              style: appBody(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
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

InputDecoration appFieldDecoration(String label,
    {String? hint, Widget? prefixIcon, Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    labelStyle: appBody(color: kTextSecondary, fontSize: 13.5),
    hintStyle: appBody(color: kTextMuted, fontSize: 13),
    iconColor: kTextSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kAccent, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kClay),
    ),
  );
}

/// Тема MaterialApp — тёмная, синяя.
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF03050A),
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: kAccent,
      secondary: kAccentLight,
      surface: kSurface,
      error: kClay,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: kTextPrimary,
      displayColor: kTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: kTextPrimary,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kSurface,
      contentTextStyle: appBody(color: kTextPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: kAccent),
  );
}
