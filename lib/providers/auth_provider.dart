import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/sample_data.dart';

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
        _user = SampleData.defaultProfile;
      }
    } else {
      _user = SampleData.defaultProfile;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoggedIn = true;
    _user = UserProfile(
      id: 'user_${email.hashCode}',
      name: email.contains('@') ? email.split('@').first : 'User',
      email: email,
      currency: _user?.currency ?? 'USD',
      primaryGoal: _user?.primaryGoal ?? 'Track spending',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', rememberMe);
    await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoggedIn = true;
    _isOnboarded = false;
    _user = UserProfile(
      id: 'user_${email.hashCode}',
      name: name,
      email: email,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_onboarded', false);
    await prefs.setString('user_profile', jsonEncode(_user!.toJson()));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> completeOnboarding(String goal, String currency, bool enableNotifs) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      primaryGoal: goal,
      currency: currency,
      notificationsEnabled: enableNotifs,
    );
    _isOnboarded = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    await prefs.setString('user_profile', jsonEncode(_user!.toJson()));
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
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    notifyListeners();
  }
}
