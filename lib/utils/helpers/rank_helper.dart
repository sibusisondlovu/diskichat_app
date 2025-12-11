
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
}
