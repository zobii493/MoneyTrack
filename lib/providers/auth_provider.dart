import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  UserProfile? _user;
  bool _isLoggedIn = false;
  bool _isOnboarded = false;
  bool _isLoading = true;

  UserProfile? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isOnboarded => _isOnboarded;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _isOnboarded = prefs.getBool('is_onboarded') ?? false;

    final userJson = prefs.getString('user_profile');
    if (userJson != null) {
      try {
        _user = UserProfile.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e) {
        _user = null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseService.isInitialized) {
        final credential = await FirebaseService.signInWithEmail(email, password);
        final uid = credential?.user?.uid ?? 'user_${email.hashCode}';
        final firebaseUser = credential?.user;
        _user = UserProfile(
          id: uid,
          name: firebaseUser?.displayName ?? (email.contains('@') ? email.split('@').first : 'User'),
          email: email,
          currency: _user?.currency ?? 'USD',
          primaryGoal: _user?.primaryGoal ?? 'Track spending',
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _user = UserProfile(
          id: 'user_${email.hashCode}',
          name: email.contains('@') ? email.split('@').first : 'User',
          email: email,
          currency: _user?.currency ?? 'USD',
          primaryGoal: _user?.primaryGoal ?? 'Track spending',
        );
      }

      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', rememberMe);
      await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

      if (FirebaseService.isInitialized && _user != null) {
        await FirebaseService.saveUserProfile(_user!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      String uid = 'user_${email.hashCode}';
      if (FirebaseService.isInitialized) {
        final credential = await FirebaseService.signUpWithEmail(email, password);
        uid = credential?.user?.uid ?? uid;
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _isLoggedIn = true;
      _isOnboarded = false;
      _user = UserProfile(
        id: uid,
        name: name,
        email: email,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setBool('is_onboarded', false);
      await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

      if (FirebaseService.isInitialized && _user != null) {
        await FirebaseService.saveUserProfile(_user!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Real Google Sign-In Function
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (FirebaseService.isInitialized) {
        final credential = await FirebaseService.signInWithGoogle();
        if (credential == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final firebaseUser = credential.user;
        _user = UserProfile(
          id: firebaseUser?.uid ?? 'google_${DateTime.now().millisecondsSinceEpoch}',
          name: firebaseUser?.displayName ?? 'Google User',
          email: firebaseUser?.email ?? 'google.user@gmail.com',
          avatarUrl: firebaseUser?.photoURL,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _user = UserProfile(
          id: 'google_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Google User',
          email: 'user.google@gmail.com',
        );
      }

      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

      if (FirebaseService.isInitialized && _user != null) {
        await FirebaseService.saveUserProfile(_user!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeOnboarding(String goal, String currency, bool enableNotifs) async {
    if (_user == null) {
      _user = UserProfile(
        id: FirebaseService.currentUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: FirebaseService.currentUser?.displayName ?? 'MoneyTrack User',
        email: FirebaseService.currentUser?.email ?? 'user@example.com',
        primaryGoal: goal,
        currency: currency,
        notificationsEnabled: enableNotifs,
      );
    } else {
      _user = _user!.copyWith(
        primaryGoal: goal,
        currency: currency,
        notificationsEnabled: enableNotifs,
      );
    }

    _isOnboarded = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

    if (FirebaseService.isInitialized && _user != null) {
      try {
        await FirebaseService.saveUserProfile(_user!);
      } catch (e) {
        debugPrint('Save profile error: $e');
      }
    }

    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? currency,
    String? primaryGoal,
    bool? notificationsEnabled,
    Map<String, bool>? dashboardWidgets,
  }) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      email: email,
      currency: currency,
      primaryGoal: primaryGoal,
      notificationsEnabled: notificationsEnabled,
      dashboardWidgets: dashboardWidgets,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

    if (FirebaseService.isInitialized && _user != null) {
      await FirebaseService.saveUserProfile(_user!);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isOnboarded = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.setBool('is_onboarded', false);
    if (FirebaseService.isInitialized) {
      await FirebaseService.signOut();
    }
    notifyListeners();
  }
}
