import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Trading_Models.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;
  bool _isAutoLoginChecked = false;

  // Getters
  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAutoLoginChecked => _isAutoLoginChecked;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
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
        if (_auth.currentUser != null) {
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
      if (_auth.currentUser != null) {
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

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        notifyListeners();
        return;
      }

      // Get user document from Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (!doc.exists) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        notifyListeners();
        return;
      }

      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      _user = AppUser.fromJson(userData);
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

      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Failed to create user';
        notifyListeners();
        return {'success': false, 'error': 'Failed to create user'};
      }

      // Create user document - user is automatically approved
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'favoriteSymbols': [],
        'preferences': {
          'tradingStyle': 'intraday',
          'defaultTimeframe': '15m',
          'notifications': true,
        },
      });

      // Load user data
      await _loadUserData();

      return {
        'success': true,
        'message': 'Registration successful!',
        'userId': credential.user!.uid,
      };
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return {'success': false, 'error': e.message};
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

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Login failed';
        notifyListeners();
        return {'success': false, 'error': 'Login failed'};
      }

      // Check if user document exists
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'User profile not found';
        notifyListeners();
        return {'success': false, 'error': 'User profile not found'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      _user = AppUser.fromJson(userData);
      _status = AuthStatus.authenticated;

      if (rememberMe) {
        await _saveCredentials(email, password);
      } else {
        await _clearSavedCredentials();
      }

      notifyListeners();
      return {
        'success': true,
        'user': _user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = errorMessage;
      notifyListeners();
      return {'success': false, 'error': errorMessage};
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
      await _auth.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
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
}