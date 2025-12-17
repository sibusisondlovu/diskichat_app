import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../data/models/match_model.dart';
import '../services/mock_data_service.dart';
import '../services/subscription_service.dart';
import 'auth_provider.dart';

class MatchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider; // Can be null if not using ProxyProvider or passed in init
  final SubscriptionService _subscriptionService = SubscriptionService();

  // MatchProvider({AuthProvider? authProvider}) : _authProvider = authProvider; 
  // removed constuctor dependencyinjection to favor proxy update
  MatchProvider();

  void updateAuth(AuthProvider auth) {
    _authProvider = auth;
    notifyListeners();
  }

  List<MatchModel> _matches = [];
  MatchModel? _selectedMatch;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MatchModel> get matches => _matches;
  MatchModel? get selectedMatch => _selectedMatch;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all matches from API (Unified Request)
  Future<void> loadMatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('MatchProvider: Fetching matches from API...');
      
      // 1. Fetch Matches from API (Now returns ALL matches: Live, Upcoming, Finished)
      var fetchedMatches = await _apiService.getLiveMatches();
      debugPrint('MatchProvider: Fetched ${fetchedMatches.length} matches from API');

      // Apply Subscription Limit
      if (_authProvider != null && _authProvider!.userProfile != null) {
        final subType = _authProvider!.userProfile!.subscriptionType;
        final limit = _subscriptionService.getMatchViewLimit(subType);
        debugPrint('MatchProvider: User Subscription: $subType, Limit: $limit');
        
        if (fetchedMatches.length > limit) {
          fetchedMatches = fetchedMatches.sublist(0, limit);
        }
      } else {
        // Default to basic (1 match) if no auth provider yet
         debugPrint('MatchProvider: No User Profile, defaulting to limit 1');
         if (fetchedMatches.isNotEmpty) {
           fetchedMatches = fetchedMatches.sublist(0, 1);
         }
      }

      // 2. Set State
      _matches = fetchedMatches;
      
      debugPrint('MatchProvider: display list size: ${_matches.length}');
      
    } catch (e) {
      debugPrint('MatchProvider Error: $e');
      _errorMessage = 'Failed to load matches: $e';
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper alias if needed by older code, but preferably remove usage
  Future<void> loadLiveMatches() => loadMatches();

  // Select match
  void selectMatch(MatchModel match) {
    _selectedMatch = match;
    notifyListeners();
  }

  // Listen to selected match updates
  void listenToMatch(String matchId) {
    _firestoreService.getMatch(matchId).listen(
          (match) {
        if (match != null) {
          _selectedMatch = match;
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}