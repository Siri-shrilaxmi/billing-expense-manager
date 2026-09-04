import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
      seedColor:
          const Color(0xFF2563EB),
      brightness:
          Brightness.light,
    );

    return ThemeData(
      useMaterial3:
          true,

      brightness:
          Brightness.light,

      colorScheme:
          colorScheme,

      scaffoldBackgroundColor:
          const Color(0xFFF5F7FB),

      // ========================================================
      // TYPOGRAPHY
      // ========================================================

      textTheme:
          const TextTheme(
        headlineLarge:
            TextStyle(
          fontSize: 32,
          fontWeight:
              FontWeight.w700,
        ),

        headlineMedium:
            TextStyle(
          fontSize: 26,
          fontWeight:
              FontWeight.w700,
        ),

        titleLarge:
            TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.w700,
        ),

        titleMedium:
            TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.w600,
        ),

        bodyLarge:
            TextStyle(
          fontSize: 16,
        ),

        bodyMedium:
            TextStyle(
          fontSize: 14,
        ),
      ),

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme:
          const AppBarTheme(
        centerTitle:
            false,

        elevation:
            0,

        scrolledUnderElevation:
            0,

        backgroundColor:
            Colors.transparent,

        surfaceTintColor:
            Colors.transparent,
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme:
          CardThemeData(
        elevation:
            0,

        color:
            Colors.white,

        surfaceTintColor:
            Colors.transparent,

        margin:
            const EdgeInsets.symmetric(
          vertical: 5,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),

          side:
              BorderSide(
            color:
                colorScheme.outlineVariant,
          ),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================

      inputDecorationTheme:
          InputDecorationTheme(
        filled:
            true,

        fillColor:
            Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                colorScheme.outlineVariant,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                colorScheme.primary,

            width:
                2,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTONS
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          minimumSize:
              const Size(
            0,
            50,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTONS
      // ========================================================

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          minimumSize:
              const Size(
            0,
            50,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTONS
      // ========================================================

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),

      // ========================================================
      // DROPDOWNS
      // ========================================================

      dropdownMenuTheme:
          const DropdownMenuThemeData(
        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
        ),
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================

      dividerTheme:
          DividerThemeData(
        color:
            colorScheme.outlineVariant,

        thickness:
            1,
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
      seedColor:
          const Color(0xFF60A5FA),
      brightness:
          Brightness.dark,
    );

    return ThemeData(
      useMaterial3:
          true,

      brightness:
          Brightness.dark,

      colorScheme:
          colorScheme,

      scaffoldBackgroundColor:
          const Color(0xFF0B1120),

      // ========================================================
      // TYPOGRAPHY
      // ========================================================

      textTheme:
          const TextTheme(
        headlineLarge:
            TextStyle(
          fontSize: 32,
          fontWeight:
              FontWeight.w700,
        ),

        headlineMedium:
            TextStyle(
          fontSize: 26,
          fontWeight:
              FontWeight.w700,
        ),

        titleLarge:
            TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.w700,
        ),

        titleMedium:
            TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.w600,
        ),

        bodyLarge:
            TextStyle(
          fontSize: 16,
        ),

        bodyMedium:
            TextStyle(
          fontSize: 14,
        ),
      ),

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme:
          const AppBarTheme(
        centerTitle:
            false,

        elevation:
            0,

        scrolledUnderElevation:
            0,

        backgroundColor:
            Colors.transparent,

        surfaceTintColor:
            Colors.transparent,
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme:
          CardThemeData(
        elevation:
            0,

        color:
            const Color(0xFF151E2F),

        surfaceTintColor:
            Colors.transparent,

        margin:
            const EdgeInsets.symmetric(
          vertical: 5,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),

          side:
              BorderSide(
            color:
                colorScheme.outlineVariant,
          ),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================

      inputDecorationTheme:
          InputDecorationTheme(
        filled:
            true,

        fillColor:
            const Color(0xFF111827),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                colorScheme.outlineVariant,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              BorderSide(
            color:
                colorScheme.primary,

            width:
                2,
          ),
        ),
      ),

      // ========================================================
      // BUTTONS
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          minimumSize:
              const Size(
            0,
            50,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          minimumSize:
              const Size(
            0,
            50,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),

      dividerTheme:
          DividerThemeData(
        color:
            colorScheme.outlineVariant,

        thickness:
            1,
      ),
    );
  }
}