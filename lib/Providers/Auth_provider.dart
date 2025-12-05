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
  pendingApproval,
  adminAuthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin credentials
  static const String adminEmail = 'ahmadasif2022@gmail.com';

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
  bool get isAuthenticated => _status == AuthStatus.authenticated || _status == AuthStatus.adminAuthenticated;
  bool get isPendingApproval => _status == AuthStatus.pendingApproval;
  bool get isAutoLoginChecked => _isAutoLoginChecked;
  bool get isAdminAuthenticated => _status == AuthStatus.adminAuthenticated;

  AuthProvider() {
    _init();
  }

  /// Check if email is admin
  bool isAdminEmail(String email) {
    return email.toLowerCase().trim() == adminEmail.toLowerCase();
  }

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
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
        if (_auth.currentUser != null) {
          await _loadUserData();
          return _status == AuthStatus.authenticated || _status == AuthStatus.adminAuthenticated;
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
        return _status == AuthStatus.authenticated || _status == AuthStatus.adminAuthenticated;
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

      // Check if admin
      if (isAdminEmail(currentUser.email ?? '')) {
        _isAdmin = true;
        _status = AuthStatus.adminAuthenticated;
        _user = AppUser(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: 'Admin',
          isApproved: true,
          isAdmin: true,
          createdAt: DateTime.now(),
        );

        // Ensure admin document exists
        await _ensureAdminDocument(currentUser);
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

      if (userData['isApproved'] != true) {
        _status = AuthStatus.pendingApproval;
        _user = AppUser.fromJson(userData);
        notifyListeners();
        return;
      }

      _user = AppUser.fromJson(userData);
      _isAdmin = userData['isAdmin'] ?? false;
      _status = _isAdmin ? AuthStatus.adminAuthenticated : AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// Ensure admin document exists in Firestore
  Future<void> _ensureAdminDocument(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': 'Admin',
        'photoUrl': '',
        'isApproved': true,
        'isAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': FieldValue.serverTimestamp(),
        'favoriteSymbols': [],
        'preferences': {},
      });
    } else {
      // Ensure admin flags are set
      await docRef.update({
        'isApproved': true,
        'isAdmin': true,
      });
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

      // Prevent registering with admin email
      if (isAdminEmail(email)) {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'This email is reserved';
        notifyListeners();
        return {'success': false, 'error': 'This email is reserved'};
      }

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

      // Create user document with pending approval status
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': '',
        'isApproved': false,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'favoriteSymbols': [],
        'preferences': {
          'tradingStyle': 'intraday',
          'defaultTimeframe': '15m',
          'notifications': true,
        },
      });

      _status = AuthStatus.pendingApproval;
      notifyListeners();

      return {
        'success': true,
        'message': 'Registration successful! Waiting for admin approval.',
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

      // Check if this is the admin
      if (isAdminEmail(email)) {
        await _ensureAdminDocument(credential.user!);

        _isAdmin = true;
        _status = AuthStatus.adminAuthenticated;
        _user = AppUser(
          uid: credential.user!.uid,
          email: email,
          displayName: 'Admin',
          isApproved: true,
          isAdmin: true,
          createdAt: DateTime.now(),
        );

        if (rememberMe) {
          await _saveCredentials(email, password);
        } else {
          await _clearSavedCredentials();
        }

        notifyListeners();
        return {
          'success': true,
          'isAdmin': true,
          'user': _user,
        };
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

      // Check if user is approved
      if (userData['isApproved'] != true) {
        await _auth.signOut();
        _status = AuthStatus.pendingApproval;
        _errorMessage = 'Your account is pending approval. Please wait for admin verification.';
        notifyListeners();
        return {
          'success': false,
          'error': 'Your account is pending approval. Please wait for admin verification.',
          'pendingApproval': true,
        };
      }

      _user = AppUser.fromJson(userData);
      _isAdmin = userData['isAdmin'] ?? false;
      _status = _isAdmin ? AuthStatus.adminAuthenticated : AuthStatus.authenticated;

      if (rememberMe) {
        await _saveCredentials(email, password);
      } else {
        await _clearSavedCredentials();
      }

      notifyListeners();
      return {
        'success': true,
        'isAdmin': _isAdmin,
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

  /// Approve a user (admin only)
  Future<Map<String, dynamic>> approveUser(String userId) async {
    if (!_isAdmin) {
      return {'success': false, 'error': 'Unauthorized'};
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'isApproved': true,
        'approvedAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'message': 'User approved successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Decline/Delete a user (admin only)
  Future<Map<String, dynamic>> declineUser(String userId) async {
    if (!_isAdmin) {
      return {'success': false, 'error': 'Unauthorized'};
    }

    try {
      await _firestore.collection('users').doc(userId).delete();
      return {'success': true, 'message': 'User declined successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get pending approvals (admin only)
  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    if (!_isAdmin) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('isApproved', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all users (admin only)
  Future<List<AppUser>> getAllUsers() async {
    if (!_isAdmin) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppUser.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}