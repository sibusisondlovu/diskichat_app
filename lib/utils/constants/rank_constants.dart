
enum UserRank { amateur, semi_pro, pro, world_class, legend }

class RankConstants {
  static int getPointsToNextRank(int currentPoints) {
    return 100; // dummy implementation
  }
  
  static UserRank? getNextRank(UserRank current) {
    return UserRank.values[(current.index + 1) % UserRank.values.length];
  }
}
