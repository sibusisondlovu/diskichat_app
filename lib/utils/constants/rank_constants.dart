
enum UserRank { cow, donkey, zebra, lion, goat }

class RankConstants {
  static int getPointsToNextRank(int currentPoints) {
    if (currentPoints < 100) return 100 - currentPoints; // Cow -> Donkey
    if (currentPoints < 500) return 500 - currentPoints; // Donkey -> Zebra
    if (currentPoints < 2000) return 2000 - currentPoints; // Zebra -> Lion
    if (currentPoints < 5000) return 5000 - currentPoints; // Lion -> Goat
    return 0; // Max Rank
  }
  
  static UserRank? getNextRank(UserRank current) {
    if (current.index >= UserRank.values.length - 1) return null;
    return UserRank.values[current.index + 1];
  }
}
