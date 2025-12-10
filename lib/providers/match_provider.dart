import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../data/models/match_model.dart';

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

  // Load all matches
  void loadMatches() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getMatches().listen(
          (matches) {
        _allMatches = matches;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Load live matches
  void loadLiveMatches() {
    _firestoreService.getLiveMatches().listen(
          (matches) {
        _liveMatches = matches;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Load today's matches
  void loadTodayMatches() {
    _firestoreService.getMatchesByDate(DateTime.now()).listen(
          (matches) {
        _todayMatches = matches;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
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