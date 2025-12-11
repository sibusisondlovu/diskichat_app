import '../data/models/match_model.dart';
import '../utils/constants/teams_constants.dart';

class MockDataService {
  static List<MatchModel> getMockMatches() {
    return [
      MatchModel(
        id: 'mock_1',
        homeTeam: 'Kaizer Chiefs',
        awayTeam: 'Orlando Pirates',
        homeLogo: TeamsConstants.getLogoPath('Kaizer Chiefs'),
        awayLogo: TeamsConstants.getLogoPath('Orlando Pirates'),
        matchDate: DateTime.now(),
        status: 'live',
        scoreHome: 1,
        scoreAway: 1,
        elapsedTime: "65'",
        fanCount: 1250,
        venue: 'FNB Stadium',
        createdAt: DateTime.now(),
      ),
      MatchModel(
        id: 'mock_2',
        homeTeam: 'Mamelodi Sundowns',
        awayTeam: 'AmaZulu',
        homeLogo: TeamsConstants.getLogoPath('Mamelodi Sundowns'),
        awayLogo: TeamsConstants.getLogoPath('AmaZulu'),
        matchDate: DateTime.now(),
        status: 'live',
        scoreHome: 2,
        scoreAway: 0,
        elapsedTime: "32'",
        fanCount: 850,
        venue: 'Loftus Versfeld',
        createdAt: DateTime.now(),
      ),
      MatchModel(
        id: 'mock_3',
        homeTeam: 'Cape Town City',
        awayTeam: 'Cape Town Spurs',
        homeLogo: TeamsConstants.getLogoPath('Cape Town City'),
        awayLogo: TeamsConstants.getLogoPath('Cape Town Spurs'),
        matchDate: DateTime.now().add(const Duration(hours: 2)),
        status: 'upcoming',
        scoreHome: 0,
        scoreAway: 0,
        elapsedTime: null,
        fanCount: 320,
        venue: 'DHL Stadium',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
