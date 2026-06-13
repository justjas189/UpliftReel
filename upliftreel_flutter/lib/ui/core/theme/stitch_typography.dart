import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Three-face type system:
/// - Fraunces: display only — hero titles, the prestige-cinema voice.
/// - Be Vietnam Pro: body and UI (retained from legacy Stitch).
/// - Space Mono: data — ratings, runtime, meta rows; ticket-stub register.
abstract final class StitchTypography {
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.8,
        color: primary,
      ),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.5,
        color: primary,
      ),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: primary,
      ),
      titleLarge: GoogleFonts.beVietnamPro(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      titleMedium: GoogleFonts.beVietnamPro(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      ),
      bodyLarge: GoogleFonts.beVietnamPro(
        fontSize: 16,
        height: 1.5,
        color: primary,
      ),
      bodyMedium: GoogleFonts.beVietnamPro(
        fontSize: 14,
        height: 1.45,
        color: secondary,
      ),
      bodySmall: GoogleFonts.beVietnamPro(
        fontSize: 12,
        height: 1.35,
        color: secondary,
      ),
      labelLarge: GoogleFonts.beVietnamPro(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: primary,
      ),
      labelSmall: GoogleFonts.spaceMono(
        fontSize: 11,
        letterSpacing: 1.2,
        color: secondary,
      ),
    );
  }

  /// Data face for values the eye scans: "8.1", "2h 28m", "2014".
  static TextStyle data({
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
