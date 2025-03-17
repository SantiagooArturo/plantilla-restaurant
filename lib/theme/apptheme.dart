import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Garamond',
    colorScheme: ColorScheme.light(primary: const Color(0xFF0E4975)),
    textTheme: _textTheme,
    navigationBarTheme: NavigationBarThemeData(
      height: 20,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return const TextStyle(
          color: Color(0xFF0E4975),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return const IconThemeData(
          color: Color(0xFF0E4975),
          size: 14,
        );
      }),
    ),
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: 'Garamond'),
    displayMedium: TextStyle(fontFamily: 'Garamond'),
    displaySmall: TextStyle(fontFamily: 'Garamond'),
    headlineLarge: TextStyle(fontFamily: 'Garamond'),
    headlineMedium: TextStyle(fontFamily: 'Garamond'),
    headlineSmall: TextStyle(fontFamily: 'Garamond'),
    titleLarge: TextStyle(fontFamily: 'Garamond'),
    titleMedium: TextStyle(fontFamily: 'Garamond'),
    titleSmall: TextStyle(fontFamily: 'Garamond'),
    bodyLarge: TextStyle(fontFamily: 'Garamond'),
    bodyMedium: TextStyle(fontFamily: 'Garamond'),
    bodySmall: TextStyle(fontFamily: 'Garamond'),
    labelLarge: TextStyle(fontFamily: 'Garamond'),
    labelMedium: TextStyle(fontFamily: 'Garamond'),
    labelSmall: TextStyle(fontFamily: 'Garamond'),
  );

  static ThemeData getTheme() => themeData;
}