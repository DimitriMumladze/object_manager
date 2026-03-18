import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryHover;
  final Color primaryLight;
  final Color primaryContainer;

  final Color background;
  final Color surface;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color divider;
  final Color border;

  final Color error;
  final Color errorLight;
  final Color success;
  final Color successLight;
  final Color warning;

  final Color chipBackground;
  final Color chipText;

  final Color shimmerBase;
  final Color shimmerHighlight;

  const AppColors({
    required this.primary,
    required this.primaryHover,
    required this.primaryLight,
    required this.primaryContainer,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.border,
    required this.error,
    required this.errorLight,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.chipBackground,
    required this.chipText,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const AppColors light = AppColors(
    primary: Color(0xFF1A56DB),
    primaryHover: Color(0xFF1E40AF),
    primaryLight: Color(0xFFDBEAFE),
    primaryContainer: Color(0xFFEFF6FF),
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    divider: Color(0xFFE5E7EB),
    border: Color(0xFFD1D5DB),
    error: Color(0xFFDC2626),
    errorLight: Color(0xFFFEF2F2),
    success: Color(0xFF16A34A),
    successLight: Color(0xFFF0FDF4),
    warning: Color(0xFFF59E0B),
    chipBackground: Color(0xFFF3F4F6),
    chipText: Color(0xFF374151),
    shimmerBase: Color(0xFFE5E7EB),
    shimmerHighlight: Color(0xFFF9FAFB),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF3B82F6),
    primaryHover: Color(0xFF60A5FA),
    primaryLight: Color(0xFF1E3A5F),
    primaryContainer: Color(0xFF172554),
    background: Color(0xFF0F1117),
    surface: Color(0xFF1A1D27),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    divider: Color(0xFF2D3748),
    border: Color(0xFF3F4A5C),
    error: Color(0xFFEF4444),
    errorLight: Color(0xFF3B1818),
    success: Color(0xFF22C55E),
    successLight: Color(0xFF14332A),
    warning: Color(0xFFFBBF24),
    chipBackground: Color(0xFF252A36),
    chipText: Color(0xFFCBD5E1),
    shimmerBase: Color(0xFF2D3748),
    shimmerHighlight: Color(0xFF3F4A5C),
  );

  /// Get the current AppColors from the nearest Theme.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryLight,
    Color? primaryContainer,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? border,
    Color? error,
    Color? errorLight,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? chipBackground,
    Color? chipText,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      chipBackground: chipBackground ?? this.chipBackground,
      chipText: chipText ?? this.chipText,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
    );
  }
}
