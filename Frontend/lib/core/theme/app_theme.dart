import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final appThemeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});

class AppTheme {
  AppTheme();

  ThemeData get light => FlexThemeData.light(
        scheme: FlexScheme.gold,
        surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
        blendLevel: 10,
        appBarOpacity: 0.95,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          elevatedButtonSchemeColor: SchemeColor.primary,
          cardRadius: 18,
          popupMenuRadius: 16,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      );

  ThemeData get dark => FlexThemeData.dark(
        scheme: FlexScheme.gold,
        surfaceMode: FlexSurfaceMode.level,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 25,
          elevatedButtonSchemeColor: SchemeColor.primary,
          cardRadius: 18,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      );
}


