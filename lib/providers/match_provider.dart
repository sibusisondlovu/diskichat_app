import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../data/models/match_model.dart';
import '../services/mock_data_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

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
  void loadMockMatches() {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _allMatches = MockDataService.getMockMatches();
      _liveMatches = _allMatches.where((m) => m.status == 'live').toList();
      _todayMatches = _allMatches;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Load all matches
  void loadMatches() {
    // For now, use mock data as requested
    loadMockMatches();
  }

  // Load live matches
  void loadLiveMatches() {
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay for consistency
    Future.delayed(const Duration(milliseconds: 300), () {
      final mockData = MockDataService.getMockMatches();
      _liveMatches = mockData.where((m) => m.status == 'live').toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Load today's matches
  void loadTodayMatches() {
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 300), () {
      // For mock data, we just return all of them as "Today" or specific ones
      _todayMatches = MockDataService.getMockMatches();
      _isLoading = false;
      notifyListeners();
    });
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