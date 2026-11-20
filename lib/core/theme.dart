import 'package:flutter/material.dart';

/// Token warna dari design.pen (mode light & dark).
///
/// Selalu ambil lewat `AppColors.of(context)` supaya ikut mode terang/gelap:
/// ```dart
/// final c = AppColors.of(context);
/// Text('Hemat 60%', style: TextStyle(color: c.primary));
/// ```
/// Jangan tulis kode hex langsung di halaman modul.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.onPrimary,
    required this.primaryTint,
    required this.sticker,
    required this.onSticker,
    required this.urgency,
    required this.urgencyText,
    required this.urgencyTint,
    required this.success,
    required this.warning,
    required this.error,
    required this.errorTint,
    required this.gray,
    required this.inverseSurface,
    required this.onInverse,
    required this.inverseAccent,
  });

  final Color bg, surface, surface2, text, textMuted, border, divider;
  final Color primary, primaryHover, primaryPressed, onPrimary, primaryTint;
  final Color sticker, onSticker, urgency, urgencyText, urgencyTint;
  final Color success, warning, error, errorTint, gray;
  final Color inverseSurface, onInverse, inverseAccent;

  static const light = AppColors(
    bg: Color(0xFFF6F8F3),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE8EFE7),
    text: Color(0xFF14301F),
    textMuted: Color(0xFF4D6455),
    border: Color(0xFF7A8F80),
    divider: Color(0xFFDFE6DF),
    primary: Color(0xFF1F4D33),
    primaryHover: Color(0xFF173C27),
    primaryPressed: Color(0xFF0F2E1D),
    onPrimary: Color(0xFFFFFFFF),
    primaryTint: Color(0xFFE1ECE3),
    sticker: Color(0xFFF4D56A),
    onSticker: Color(0xFF14301F),
    urgency: Color(0xFFFF9300),
    urgencyText: Color(0xFFA34A00),
    urgencyTint: Color(0xFFFFF1DD),
    success: Color(0xFF1D6B47),
    warning: Color(0xFF8A5A00),
    error: Color(0xFFB3261E),
    errorTint: Color(0xFFFBE9E7),
    gray: Color(0xFFDEE2E6),
    inverseSurface: Color(0xFF14301F),
    onInverse: Color(0xFFEEF3EC),
    inverseAccent: Color(0xFFF4D56A),
  );

  static const dark = AppColors(
    bg: Color(0xFF10261A),
    surface: Color(0xFF163021),
    surface2: Color(0xFF1D3A29),
    text: Color(0xFFEEF3EC),
    textMuted: Color(0xFFA9C0AF),
    border: Color(0xFF5F7D68),
    divider: Color(0xFF24402F),
    primary: Color(0xFF9FD3AE),
    primaryHover: Color(0xFFB8E0C3),
    primaryPressed: Color(0xFF8BC49B),
    onPrimary: Color(0xFF10261A),
    primaryTint: Color(0xFF1E3F2B),
    sticker: Color(0xFFF4D56A),
    onSticker: Color(0xFF14301F),
    urgency: Color(0xFFFFB347),
    urgencyText: Color(0xFFFFB347),
    urgencyTint: Color(0xFF3A2A12),
    success: Color(0xFF7FD1A3),
    warning: Color(0xFFF2C14E),
    error: Color(0xFFFF8A80),
    errorTint: Color(0xFF3A1A17),
    gray: Color(0xFF2E3438),
    inverseSurface: Color(0xFFEEF3EC),
    onInverse: Color(0xFF14301F),
    inverseAccent: Color(0xFF1F4D33),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith() => this;

  // ponytail: tanpa interpolasi warna per field; pergantian tema langsung berganti palet.
  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

/// Spacing 4pt. Padding layar 16 · item terkait 8–12 · antar blok 24 · antar section 32.
class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Target sentuh minimum.
  static const touch = 44.0;
}

/// Radius: sm = stiker, input, chip kotak · md = kartu, sheet, tombol · pill = chip filter.
class AppRadius {
  static const sm = 6.0;
  static const md = 12.0;
  static const pill = 999.0;
}

/// Elevasi: hanya elemen melayang yang diberi bayangan; sisanya datar.
class AppShadow {
  /// E1: sticky bar, ticket strip.
  static const e1 = [
    BoxShadow(color: Color(0x141C2616), offset: Offset(0, -2), blurRadius: 8),
  ];

  /// E2: bottom sheet, popup peta, marker terpilih.
  static const e2 = [
    BoxShadow(color: Color(0x1F1C2616), offset: Offset(0, -4), blurRadius: 20),
  ];
}

/// Gaya teks khusus. Warna tidak diset: ikut `DefaultTextStyle` (warna teks tema),
/// atau tambahkan `.copyWith(color: AppColors.of(context).x)`.
class AppText {
  static const fontUi = 'PlusJakartaSans';
  static const fontMono = 'JetBrainsMono';

  /// Kode tiket & countdown besar: `H7K · 49`.
  static const code = TextStyle(
    fontFamily: fontMono,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  /// Harga & jam: `Rp8.000`, `20.30`.
  static const mono = TextStyle(
    fontFamily: fontMono,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  static final light = _build(AppColors.light, Brightness.light);
  static final dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final textTheme = TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: c.text,
      ), // display
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: c.text,
      ), // judul layar
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: c.text,
      ), // heading section
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: c.text,
      ), // judul list
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c.text,
      ), // body
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c.text,
      ), // body sekunder
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c.textMuted,
      ), // meta
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: c.text,
      ), // tombol
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c.text,
      ), // chip, label input
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.text,
      ), // caption, label nav
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    const buttonSize = Size(64, 48);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20);
    OutlineInputBorder inputBorder(Color color, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: color, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppText.fontUi,
      textTheme: textTheme,
      extensions: [c],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.onPrimary,
        primaryContainer: c.primaryTint,
        onPrimaryContainer: c.text,
        secondary: c.sticker,
        onSecondary: c.onSticker,
        error: c.error,
        onError: c.onPrimary,
        errorContainer: c.errorTint,
        surface: c.surface,
        onSurface: c.text,
        onSurfaceVariant: c.textMuted,
        surfaceContainerHighest: c.surface2,
        outline: c.border,
        outlineVariant: c.divider,
        inverseSurface: c.inverseSurface,
        onInverseSurface: c.onInverse,
      ),
      scaffoldBackgroundColor: c.bg,
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),

      // App Bar: menyatu dengan background, judul 20/700 rata kiri.
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: TextStyle(
          fontFamily: AppText.fontUi,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: c.text,
        ),
      ),

      // Btn/Primary
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surface2,
          disabledForegroundColor: c.textMuted,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: const TextStyle(
            fontFamily: AppText.fontUi,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      // Btn/Secondary
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.text,
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: c.border),
          textStyle: const TextStyle(
            fontFamily: AppText.fontUi,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(AppSpace.touch, AppSpace.touch),
          textStyle: const TextStyle(
            fontFamily: AppText.fontUi,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Input: radius 6, tinggi 48, garis $border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: c.textMuted),
        helperStyle: TextStyle(fontSize: 12, color: c.textMuted),
        errorStyle: TextStyle(fontSize: 12, color: c.error),
        prefixIconColor: c.textMuted,
        suffixIconColor: c.textMuted,
        border: inputBorder(c.border),
        enabledBorder: inputBorder(c.border),
        focusedBorder: inputBorder(c.primary, 2),
        errorBorder: inputBorder(c.error),
        focusedErrorBorder: inputBorder(c.error, 2),
      ),

      // Chip filter: pill, tinggi 36, label 14/600.
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.primaryTint,
        checkmarkColor: c.primary,
        side: BorderSide(color: c.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        labelStyle: TextStyle(
          fontFamily: AppText.fontUi,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.text,
        ),
      ),

      // Toggle (mis. Peta/Daftar, tab Aktif/Riwayat): terpilih = primary-tint.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.text,
          selectedBackgroundColor: c.primaryTint,
          selectedForegroundColor: c.primary,
          side: BorderSide(color: c.border),
          textStyle: const TextStyle(
            fontFamily: AppText.fontUi,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.divider),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textMuted,
        textColor: c.text,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: AppText.fontUi,
          fontSize: 14,
          color: c.onInverse,
        ),
        actionTextColor: c.inverseAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.divider,
      ),
    );
  }
}
