class SubscriptionService {
  static const int freeTeamLimit = 1;
  static const int freeLeagueLimit = 1;
  static const int proTeamLimit = 10;
  static const int proLeagueLimit = 10;

  bool canFollowMoreTeams(int currentCount, String subscriptionType) {
    final limit = subscriptionType == 'PRO' ? proTeamLimit : freeTeamLimit;
    return currentCount < limit;
  }

  bool canFollowMoreLeagues(int currentCount, String subscriptionType) {
    final limit = subscriptionType == 'PRO' ? proLeagueLimit : freeLeagueLimit;
    return currentCount < limit;
  }

  int getTeamLimit(String subscriptionType) {
    return subscriptionType == 'PRO' ? proTeamLimit : freeTeamLimit;
  }

  int getLeagueLimit(String subscriptionType) {
    return subscriptionType == 'PRO' ? proLeagueLimit : freeLeagueLimit;
  }
}
