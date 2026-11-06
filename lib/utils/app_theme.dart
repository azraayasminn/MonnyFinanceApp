import 'package:flutter/material.dart';
import 'app_color.dart';

/// Tema global. Memakai font bawaan Flutter.
class AppTheme {
  AppTheme._();

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        onPrimary: Colors.white,
        surface: AppColor.paper,
        onSurface: AppColor.ink,
        error: AppColor.expense,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColor.background,
      textTheme: base.textTheme.apply(
        bodyColor: AppColor.ink,
        displayColor: AppColor.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.background,
        foregroundColor: AppColor.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColor.ink,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.paper,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColor.muted),
        border: _border(AppColor.line),
        enabledBorder: _border(AppColor.line),
        focusedBorder: _border(AppColor.primary, width: 1.5),
        errorBorder: _border(AppColor.expense, width: 1.5),
        focusedErrorBorder: _border(AppColor.expense, width: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColor.primary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColor.sun,
        foregroundColor: AppColor.ink,
        elevation: 2,
        extendedTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColor.ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}