import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary & Secondary Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color secondary = Color(0xFF0EA5E9); // Sky
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Color(0xFFFFFFFF);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444); // Red
  static const Color priorityHighBg = Color(0xFFFEE2E2);
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber
  static const Color priorityMediumBg = Color(0xFFFEF3C7);
  static const Color priorityLow = Color(0xFF10B981); // Emerald
  static const Color priorityLowBg = Color(0xFFD1FAE5);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
