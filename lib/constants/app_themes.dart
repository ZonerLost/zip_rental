// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

//! AppThemes 

class AppThemeColors {
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getTertiary(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  static Color getquaternary(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color getfifth(BuildContext context) {
    return Theme.of(context).colorScheme.onTertiary;
  }

  static Color getsplashcolor(BuildContext context) {
    return Theme.of(context).splashColor;
  }

  static Color getblack(BuildContext context) {
    return Theme.of(context).shadowColor;
  }
}