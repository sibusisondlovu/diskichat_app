import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../data/models/match_model.dart';
import '../services/mock_data_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  List<MatchModel> _allMatches = [];
  List<MatchModel> _liveMatches = [];
  List<MatchModel> _todayMatches = [];
  MatchModel? _selectedMatch;

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, live, today

  // Getters
  List<MatchModel> get allMatches => _allMatches;
  List<MatchModel> get liveMatches => _liveMatches;
  List<MatchModel> get todayMatches => _todayMatches;
  MatchModel? get selectedMatch => _selectedMatch;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  List<MatchModel> get displayedMatches {
    switch (_selectedFilter) {
      case 'live':
        return _liveMatches;
      case 'today':
        return _todayMatches;
      default:
        return _allMatches;
    }
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Load mock matches
  // Now only returns upcoming/finished mock matches to avoid overwriting real live data
  List<MatchModel> _getMockUpcomingMatches() {
    return MockDataService.getMockMatches()
        .where((m) => m.status != 'live')
        .toList();
  }

  // Load all matches (Live from API + Upcoming from Mock)
  Future<void> loadMatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // 1. Fetch Live Matches from API
      final liveMatches = await _apiService.getLiveMatches();
      _liveMatches = liveMatches;
      
      // 2. Fetch Mock Upcoming (since we don't have API for upcoming yet)
      final upcomingMatches = _getMockUpcomingMatches();
      
      // 3. Combine
      _allMatches = [..._liveMatches, ...upcomingMatches];
      
      // 4. Update Today (simplified)
      _todayMatches = _allMatches;
      
    } catch (e) {
      debugPrint('Error loading matches: $e');
      _errorMessage = 'Failed to load matches';
      
      // Fallback: If API fails, show what we have (mock upcoming) 
      // or should we show mock live too? Let's stick to mock upcoming to avoid confusion.
      _allMatches = _getMockUpcomingMatches();
      _liveMatches = []; 
      _todayMatches = _allMatches;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load live matches
  Future<void> loadLiveMatches() async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();
    
    try {
      final matches = await _apiService.getLiveMatches();
      _liveMatches = matches;
      
      // Update all matches to include these new live ones
      final upcomingMatches = _getMockUpcomingMatches();
      _allMatches = [..._liveMatches, ...upcomingMatches];
      _todayMatches = _allMatches;
      
      if (_liveMatches.isEmpty) {
        debugPrint('No live matches found from API');
      }
    } catch (e) {
      debugPrint('Error loading live matches: $e');
      _errorMessage = 'Failed to load live matches.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load today's matches
  void loadTodayMatches() {
     // Reuse loadMatches for now as it sets _todayMatches
     loadMatches();
  }

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