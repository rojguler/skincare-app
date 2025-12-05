import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler - Profil sayfasındaki Renk Paleti
  static const Color yellow = Color(
    0xFFFFFBF0,
  ); // Even Lighter Pastel Yellow (input field background) - Updated
  static const Color pink = Color(
    0xFFFADADD,
  ); // Lighter Soft Pink (icons and accents) - Updated to lighter
  static const Color lightPink = Color(
    0xFFFEF2F7,
  ); // Very Light Pink (card backgrounds)
  static const Color marron = Color(0xFF8A8651); // Marron Premium
  static const Color purple = Color(0xFF9C27B0); // Purple for gradients
  static const Color nude = Color(
    0xFFFFFBF0,
  ); // Nude Pastel Background (matching yellow) - Updated
  static const Color darkGray = Color(0xFF424242); // Dark Gray
  static const Color lightGray = Color(0xFF757575); // Light Gray
  static const Color white = Color(0xFFFFFFFF); // Pure White
  static const Color textPrimary = Color(0xFF212121); // Dark Gray for text
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Light Gray for secondary text
  static const Color background = white;
  static const Color cardBackground =
      lightPink; // Light pink for card backgrounds

  // Modern UI renkleri
  static const Color primary = pink;
  static const Color secondary = yellow;
  static const Color accent = marron;
  static const Color surface = white;
  static const Color error = Color(0xFF424242); // Dark gray (error)
  static const Color success = Color(0xFF8A8651); // Marron (success)
  static const Color warning = Color(0xFFFFFBF0); // Yellow (warning) - Updated

  // Gradient renkleri
  static const Color gradientStart = pink;
  static const Color gradientEnd = yellow;

  // Eski renkler (geriye uyumluluk için)
  static const Color brown = marron;
  static const Color beige = Color(0xFFF5F5DC);
  static const Color pastelPink = pink;

  // Enhanced shadow colors for softer shadows
  static const Color shadowLight = Color(
    0x1AFADADD,
  ); // Very light pink shadow - Updated
  static const Color shadowMedium = Color(
    0x26FADADD,
  ); // Medium pink shadow - Updated
  static const Color shadowDark = Color(
    0x33FADADD,
  ); // Darker pink shadow - Updated
}
