import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  // Initialize auth state listener
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  // Load user profile from Firestore
  Future<void> loadUserProfile() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await _authService.getUserProfile(_user!.uid);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;

    await _authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        success = true;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error;
        success = false;
        _isLoading = false;
        notifyListeners();
      },
    );

    return success;
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _errorMessage = 'Verification ID not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.verifyOTP(
        verificationId: _verificationId!,
        otp: otp,
      );

      if (userCredential != null) {
        _user = userCredential.user;
        await loadUserProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? favoriteTeam,
    String? country,
    String? bio,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateUserProfile(
        userId: _user!.uid,
        displayName: displayName,
        username: username,
        avatarUrl: avatarUrl,
        favoriteTeam: favoriteTeam,
        country: country,
        bio: bio,
      );

      await loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();

    _user = null;
    _userProfile = null;
    _verificationId = null;
    _isLoading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}