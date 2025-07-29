import 'package:flutter/material.dart';

class AppTheme {
  // Cores base para referência
  static const Color primaryColor = Color(0xFF004D40); // Teal Escuro
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color darkBackgroundColor = Color(0xFF212529);
  static const Color darkCardColor = Color(0xFF2C2C2E);
  static const Color accentColor = Color(0xFFB8860B); // Dourado

  // TEMA CLARO CORRIGIDO
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Habilita o Material 3
    brightness: Brightness.light,
    primaryColor: primaryColor,
    // Cor de fundo principal da tela
    scaffoldBackgroundColor: lightBackgroundColor,
    
    // ColorScheme agora sem os parâmetros obsoletos
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: lightCardColor, // Cor para Cards, cabeçalhos, etc.
      onSurface: Colors.black,   // Texto/ícones sobre o surface
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightCardColor, // AppBar usa a cor de superfície
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      ),
    ),
  );

  // TEMA ESCURO CORRIGIDO
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true, // Habilita o Material 3
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    // Cor de fundo principal da tela
    scaffoldBackgroundColor: darkBackgroundColor,

    // ColorScheme agora sem os parâmetros obsoletos
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: darkCardColor, // Cor para Cards, cabeçalhos, etc.
      onSurface: Colors.white,  // Texto/ícones sobre o surface
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCardColor, // AppBar usa a cor de superfície
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightCardColor, // Botão claro no tema escuro
        foregroundColor: darkBackgroundColor, // Texto escuro no botão claro
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
      ),
    ),
  );
}