import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const backgroundTop = Color(0xFFF2D9E8);
  static const backgroundBottom = Color(0xFFFBE3CE);
  static const card = Color(0xFFFFFFFF);
  static const pillTrack = Color(0xFFF1EFF3);
  static const textPrimary = Color(0xFF262229);
  static const textSecondary = Color(0xFF9A94A0);
  static const accentStart = Color(0xFFE86FA0);
  static const accentEnd = Color(0xFF8E6FE8);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  static const accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accentEnd,
    ),
  );
}
