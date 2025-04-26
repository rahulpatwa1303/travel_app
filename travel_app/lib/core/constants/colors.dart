import 'package:flutter/material.dart';
// Example Flutter ColorScheme definition (Light)
const lightColorScheme =  ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFE65100), // Deep Orange
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFCCBC), // Light Orange/Peach
  onPrimaryContainer: Color(0xFF3E0F00),
  secondary: Color(0xFFFF8F00), // Amber/Gold
  onSecondary: Color(0xFF000000), // Black for contrast on yellow
  secondaryContainer: Color(0xFFFFECB3), // Light Yellow
  onSecondaryContainer: Color(0xFF291E00),
  tertiary: Color(0xFF6A1B9A), // Deep Purple
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFEAD7F8), // Light Purple
  onTertiaryContainer: Color(0xFF26003A),
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFCD8DF),
  onErrorContainer: Color(0xFF410E0B),
  background: Color(0xFFFFF8F0), // Warm Off-White
  onBackground: Color(0xFF201A17), // Dark Brown/Grey
  surface: Color(0xFFFFF8F0),
  onSurface: Color(0xFF201A17),
  surfaceVariant: Color(0xFFF0E0D6), // Beige variant
  onSurfaceVariant: Color(0xFF50443E),
  outline: Color(0xFF82746D),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFF362F2B), // Dark Brown/Grey
  onInverseSurface: Color(0xFFFAEFE7),
  inversePrimary: Color(0xFFFFB77E), // Light Orange
);

// Example Flutter ColorScheme definition (Dark)
const darkColorScheme =  ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF86CFFF), // Lighter Blue
  onPrimary: Color(0xFF00344C),
  primaryContainer: Color(0xFF004C6D), // Darker Blue Base
  onPrimaryContainer: Color(0xFFC7E7FF),
  secondary: Color(0xFF8DD8E0), // Lighter Teal
  onSecondary: Color(0xFF00373A),
  secondaryContainer: Color(0xFF004F53), // Darker Teal Base
  onSecondaryContainer: Color(0xFFB2EBEE),
  tertiary: Color(0xFFD6C78C), // Lighter Gold/Olive
  onTertiary: Color(0xFF393004),
  tertiaryContainer: Color(0xFF514719), // Darker Gold Base
  onTertiaryContainer: Color(0xFFF3E3A6),
  error: Color(0xFFFFB4AB), // Light Red
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF001F25), // Very Dark Blue/Teal
  onBackground: Color(0xFFA6EEFF), // Light Cyan Text
  surface: Color(0xFF001F25), // Same as background or slightly lighter dark
  onSurface: Color(0xFFA6EEFF),
  surfaceVariant: Color(0xFF41484D), // Mid-Dark Grey
  onSurfaceVariant: Color(0xFFC1C7CE),
  outline: Color(0xFF8B9297), // Lighter Neutral Outline
  shadow: Color(0xFF000000), // Black
  inverseSurface: Color(0xFFA6EEFF), // Light Cyan for contrasted elements
  onInverseSurface: Color(0xFF001F25), // Dark Text on Inverse
  inversePrimary: Color(0xFF00658E), // Original Primary Blue
);