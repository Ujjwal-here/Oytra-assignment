import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF141417);
  static const Color surfaceHigh = Color(0xFF1C1C21);
  static const Color border = Color(0xFF2A2A32);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanGlow = Color(0x2000E5FF);

  static const Color amber = Color(0xFFFFB300);
  static const Color amberGlow = Color(0x20FFB300);

  static const Color violet = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFAB76FF);
  static const Color violetGlow = Color(0x207C3AED);

  static const Color success = Color(0xFF00C97A);
  static const Color successGlow = Color(0x2000C97A);
  static const Color danger = Color(0xFFFF3B5C);
  static const Color dangerGlow = Color(0x20FF3B5C);

  static const Color textHigh = Color(0xFFF2F2F4);
  static const Color textMid = Color(0xFF9898A8);
  static const Color textLow = Color(0xFF4E4E5C);

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0099FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C97A), Color(0xFF00A06A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient productGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF0D2040)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scannerGradient = LinearGradient(
    colors: [Color(0xFF1A0A2E), Color(0xFF2D1052)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orderGradient = LinearGradient(
    colors: [Color(0xFF061A0F), Color(0xFF0A2B1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    final base = GoogleFonts.cabinTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: textHigh),
        displayMedium: TextStyle(color: textHigh),
        displaySmall: TextStyle(color: textHigh),
        headlineLarge: TextStyle(color: textHigh),
        headlineMedium: TextStyle(color: textHigh),
        headlineSmall: TextStyle(color: textHigh),
        titleLarge: TextStyle(color: textHigh),
        titleMedium: TextStyle(color: textHigh),
        titleSmall: TextStyle(color: textMid),
        bodyLarge: TextStyle(color: textHigh),
        bodyMedium: TextStyle(color: textMid),
        bodySmall: TextStyle(color: textLow),
        labelLarge: TextStyle(color: textHigh),
        labelMedium: TextStyle(color: textMid),
        labelSmall: TextStyle(color: textLow),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      textTheme: base,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: amber,
        surface: surface,
        onSurface: textHigh,
        error: danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textHigh,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cabin(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textHigh,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: textMid),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: Color(0xFF001820),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cabin(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cyan, width: 1.5),
        ),
        labelStyle: GoogleFonts.cabin(color: textMid, fontSize: 14),
        hintStyle: GoogleFonts.cabin(color: textLow, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 0.8,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.cabin(color: textHigh, fontSize: 14),
      ),
    );
  }
}

class R {
  final double width;
  final double height;
  final double _scale;

  R._(this.width, this.height, this._scale);

  factory R.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final shortest = math.min(w, h);
    final scale = (shortest / 390).clamp(0.78, 1.52);
    return R._(w, h, scale);
  }

  double sp(double size) => size * _scale;
  double dp(double size) => size * _scale;

  bool get isLandscape => width > height;

  double get maxContentWidth {
    if (width >= 1600) return 1200;
    if (width >= 1200) return 1000;
    if (width >= 900) return 800;
    if (width >= 600) return math.min(width - 32, 560);
    return width;
  }

  int get gridColumns => width >= 600 ? 3 : 2;

  double get moduleTileAspectRatio {
    if (width >= 900) return 1.25;
    if (width >= 600) return 1.2;
    return isLandscape ? 1.05 : 0.95;
  }

  EdgeInsets contentPadding({double top = 8, double bottom = 32}) {
    final base = width >= 900 ? 32.0 : (width >= 600 ? 26.0 : 20.0);
    final h = dp(base);
    return EdgeInsets.fromLTRB(h, dp(top), h, dp(bottom));
  }
}

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.maxContentWidth),
        child: child,
      ),
    );
  }
}
