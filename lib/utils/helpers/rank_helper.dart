import 'package:flutter/material.dart';
import '../constants/rank_constants.dart';

class RankHelper {
  static UserRank getRankFromString(String rank) {
    try {
      return UserRank.values.firstWhere(
        (e) => e.toString().split('.').last == rank.toLowerCase(),
        orElse: () => UserRank.cow,
      );
    } catch (_) {
      return UserRank.cow;
    }
  }
  
  static double getRankProgress(int points, UserRank rank) {
    // Return 0.0 to 1.0 based on points within current rank bracket
    int prevThreshold = 0;
    int nextThreshold = 100;

    switch (rank) {
      case UserRank.cow:
        prevThreshold = 0;
        nextThreshold = 100;
        break;
      case UserRank.donkey:
        prevThreshold = 100;
        nextThreshold = 500;
        break;
      case UserRank.zebra:
        prevThreshold = 500;
        nextThreshold = 2000;
        break;
      case UserRank.lion:
        prevThreshold = 2000;
        nextThreshold = 5000;
        break;
      case UserRank.goat:
        return 1.0; // Max rank
    }
    
    if (points >= nextThreshold) return 1.0;
    if (points <= prevThreshold) return 0.0;
    
    return (points - prevThreshold) / (nextThreshold - prevThreshold);
  }
  

  static String getRankDisplayName(UserRank rank) {
    return rank.toString().split('.').last.toUpperCase();
  }

  static String getRankIcon(UserRank rank) {
    switch (rank) {
      case UserRank.cow:
        return '🐮';
      case UserRank.donkey:
        return '🐴';
      case UserRank.zebra:
        return '🦓';
      case UserRank.lion:
        return '🦁';
      case UserRank.goat:
        return '🐐';
    }
  }

  static dynamic getRankColor(UserRank rank) {
    switch (rank) {
      case UserRank.cow:
        return Colors.brown; 
      case UserRank.donkey:
        return Colors.grey; 
      case UserRank.zebra:
        return Colors.white; // Or stripped logic elsewhere, but white for text/icon usually
      case UserRank.lion:
        return Colors.amber; 
      case UserRank.goat:
        return Colors.purpleAccent; 
    }
  }
}
