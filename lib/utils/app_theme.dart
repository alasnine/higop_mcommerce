import 'package:flutter/material.dart';

class HigopColors {
  static const kayumanggi = Color(0xFF6B4423); // primary
  static const tsokolate = Color(0xFF3B2314); // text / admin sidebar
  static const gatas = Color(0xFFFBF3E4); // background
  static const abaka = Color(0xFFEBDCC0); // cards / chips
  static const ginto = Color(0xFFC8963E); // accent
  static const pula = Color(0xFFA63D2F); // error / delete
  static const dahon = Color(0xFF5B7F3B); // success
}

class HigopTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: HigopColors.kayumanggi,
      brightness: Brightness.light,
    ).copyWith(
      primary: HigopColors.kayumanggi,
      onPrimary: Colors.white,
      secondary: HigopColors.ginto,
      surface: HigopColors.gatas,
      onSurface: HigopColors.tsokolate,
      error: HigopColors.pula,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: HigopColors.gatas,
      appBarTheme: const AppBarTheme(
        backgroundColor: HigopColors.kayumanggi,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HigopColors.kayumanggi, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: HigopColors.kayumanggi,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: HigopColors.kayumanggi),
      ),
    );
  }
}