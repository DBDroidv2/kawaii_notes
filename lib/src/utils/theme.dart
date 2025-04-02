import 'package:flutter/material.dart';

// Define Kawaii Pastel Colors
const Color kawaiiPink = Color(0xFFFFE4E1); // Misty Rose
const Color kawaiiLightPink = Color(0xFFFFB6C1); // Light Pink
const Color kawaiiBlue = Color(0xFFADD8E6); // Light Blue
const Color kawaiiLightBlue = Color(0xFFB0E0E6); // Powder Blue
const Color kawaiiYellow = Color(0xFFFFFACD); // Lemon Chiffon
const Color kawaiiGreen = Color(0xFF98FB98); // Pale Green
const Color kawaiiPurple = Color(0xFFE6E6FA); // Lavender
const Color kawaiiText = Color(0xFF777777); // Dim Gray for readability
const Color kawaiiBackground = Color(0xFFFAF0E6); // Linen background

// Create the App Theme
final ThemeData kawaiiTheme = ThemeData(
  primaryColor: kawaiiPink,
  hintColor: kawaiiLightPink, // Often used for accents
  scaffoldBackgroundColor: kawaiiBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: kawaiiLightPink, // Changed to Light Pink
    foregroundColor: Colors.white, // White text on light pink app bar (might need adjustment?)
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white), // White icons on app bar
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kawaiiGreen, // Changed to Pale Green
    foregroundColor: kawaiiText, // Changed text color for better contrast on green
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kawaiiText, fontSize: 16),
    bodyMedium: TextStyle(color: kawaiiText, fontSize: 14),
    titleLarge: TextStyle(color: kawaiiText, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: kawaiiText, fontWeight: FontWeight.w600),
    // Add other text styles as needed
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 1.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none, // No border initially
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: kawaiiLightPink, width: 2.0),
    ),
    labelStyle: const TextStyle(color: kawaiiText),
    hintStyle: TextStyle(color: kawaiiText.withOpacity(0.6)),
  ),
  // Add other theme properties as needed (buttons, icons, etc.)
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: kawaiiPink,
    secondary: kawaiiLightPink,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kawaiiText,
    error: Colors.redAccent, // Or a pastel red?
    onError: Colors.white,
  ),
);
