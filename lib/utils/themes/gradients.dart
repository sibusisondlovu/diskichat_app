
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient matchCard = LinearGradient(
    colors: [AppColors.primaryLight, AppColors.primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
