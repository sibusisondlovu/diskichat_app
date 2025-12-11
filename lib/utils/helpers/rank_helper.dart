import 'package:flutter/material.dart';
import '../constants/rank_constants.dart';

class RankHelper {
  static UserRank getRankFromString(String rank) {
    try {
      return UserRank.values.firstWhere(
        (e) => e.toString().split('.').last == rank,
        orElse: () => UserRank.amateur,
      );
    } catch (_) {
      return UserRank.amateur;
    }
  }
  
  static double getRankProgress(int points, UserRank rank) {
    return 0.5; // dummy implementation
  }
  

  static String getRankDisplayName(UserRank rank) {
    return rank.toString().split('.').last.toUpperCase().replaceAll('_', ' ');
  }

  static String getRankIcon(UserRank rank) {
    switch (rank) {
      case UserRank.amateur:
        return '🌱';
      case UserRank.semi_pro:
        return '⭐';
      case UserRank.pro:
        return '🌟';
      case UserRank.world_class:
        return '🏆';
      case UserRank.legend:
        return '👑';
    }
  }

  static dynamic getRankColor(UserRank rank) {
    // Basic color implementation - you might want to use AppColors here
    switch (rank) {
      case UserRank.amateur:
        return Color(0xFF8D6E63); // Brown
      case UserRank.semi_pro:
        return Color(0xFFB0BEC5); // Silver/Grey
      case UserRank.pro:
        return Color(0xFFFFD700); // Gold
      case UserRank.world_class:
        return Color(0xFF00BFA5); // Teal/Emerald
      case UserRank.legend:
        return Color(0xFF9C27B0); // Purple
    }
  }
}
