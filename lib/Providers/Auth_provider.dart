import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trading_models.dart';
import '../services/firebase_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  pendingApproval,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;
  bool _isAdmin = false;
  bool _isAutoLoginChecked = false;

  // Getters
  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isPendingApproval => _status == AuthStatus.pendingApproval;
  bool get isAutoLoginChecked => _isAutoLoginChecked;

  AuthProvider() {
    _init();
  }

  void _init() {
    _firebaseService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _isAdmin = false;
      } else {
        await _loadUserData();
      }
      _isAutoLoginChecked = true;
      notifyListeners();
    });
  }

  /// Check for auto-login on app start
  Future<bool> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (rememberMe && savedEmail != null && savedPassword != null) {
        // Check if user is already logged in via Firebase
        if (_firebaseService.currentUser != null) {
          await _loadUserData();
          return _status == AuthStatus.authenticated;
        }

        // Try to login with saved credentials
        final result = await login(
          email: savedEmail,
          password: savedPassword,
          rememberMe: true,
        );
        return result['success'] == true;
      }

      // Check if Firebase session exists
      if (_firebaseService.currentUser != null) {
        await _loadUserData();
        return _status == AuthStatus.authenticated;
      }

      _isAutoLoginChecked = true;
      notifyListeners();
      return false;
    } catch (e) {
      _isAutoLoginChecked = true;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      AppUser? userData = await _firebaseService.getCurrentUserData();

      if (userData == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        return;
      }

      if (!userData.isApproved) {
        _status = AuthStatus.pendingApproval;
        _user = userData;
        return;
      }

      _user = userData;
      _isAdmin = userData.isAdmin;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _firebaseService.registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result['success'] == true) {
        _status = AuthStatus.pendingApproval;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = result['error'];
      }

      notifyListeners();
      return result;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _firebaseService.loginUser(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        _user = result['user'];
        _isAdmin = _user?.isAdmin ?? false;
        _status = AuthStatus.authenticated;

        // Save credentials if remember me is checked
        if (rememberMe) {
          await _saveCredentials(email, password);
        } else {
          await _clearSavedCredentials();
        }
      } else if (result['pendingApproval'] == true) {
        _status = AuthStatus.pendingApproval;
        _errorMessage = result['error'];
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = result['error'];
      }

      notifyListeners();
      return result;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Save credentials for auto-login
  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear saved credentials
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check if remember me was enabled
  Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('remember_me') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get saved email for auto-fill
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('saved_email');
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _clearSavedCredentials();
      await _firebaseService.logout();
      _status = AuthStatus.unauthenticated;
      _user = null;
      _isAdmin = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> approveUser({
    required String userId,
    required String otp,
  }) async {
    if (!_isAdmin) {
      return {'success': false, 'error': 'Unauthorized'};
    }

    try {
      final result = await _firebaseService.verifyAndApproveUser(
        userId: userId,
        enteredOtp: otp,
      );
      return result;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    if (!_isAdmin) return [];
    return await _firebaseService.getPendingApprovals();
  }

  Future<List<AppUser>> getAllUsers() async {
    if (!_isAdmin) return [];
    return await _firebaseService.getAllUsers();
  }
}