import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trading_models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // ==================== AUTHENTICATION ====================

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with email
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return {'success': false, 'error': 'Failed to create user'};
      }

      // Create user document - Simple, no approval needed
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

      return {
        'success': true,
        'message': 'Registration successful!',
        'userId': credential.user!.uid,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return {'success': false, 'error': 'Login failed'};
      }

      // Check if user document exists
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {'success': false, 'error': 'User profile not found'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      return {
        'success': true,
        'user': AppUser.fromJson(userData),
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

      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current user data
  Future<AppUser?> getCurrentUserData() async {
    if (currentUser == null) return null;

    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return AppUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== SIGNAL HISTORY ====================

  /// Save signal to history
  Future<void> saveSignalToHistory(TradingSignal signal) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('signal_history')
          .doc(signal.id)
          .set({
        ...signal.toJson(),
        'userId': currentUser!.uid,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save signal: $e');
    }
  }

  /// Get signal history
  Future<List<TradingSignal>> getSignalHistory({int limit = 50}) async {
    if (currentUser == null) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('signal_history')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
          TradingSignal.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get signal history stream
  Stream<List<TradingSignal>> getSignalHistoryStream() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('signal_history')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TradingSignal.fromJson(doc.data()))
        .toList());
  }

  /// Update signal status
  Future<void> updateSignalStatus({
    required String signalId,
    required String status,
    double? exitPrice,
    double? profitLoss,
  }) async {
    if (currentUser == null) return;

    try {
      Map<String, dynamic> updateData = {'status': status};

      if (exitPrice != null) {
        updateData['exitPrice'] = exitPrice;
      }
      if (profitLoss != null) {
        updateData['profitLoss'] = profitLoss;
      }
      if (status == 'completed') {
        updateData['closedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('signal_history')
          .doc(signalId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update signal: $e');
    }
  }

  // ==================== USER PREFERENCES ====================

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  /// Add favorite symbol
  Future<void> addFavoriteSymbol(String symbol) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'favoriteSymbols': FieldValue.arrayUnion([symbol]),
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Remove favorite symbol
  Future<void> removeFavoriteSymbol(String symbol) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'favoriteSymbols': FieldValue.arrayRemove([symbol]),
      });
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // ==================== STATISTICS ====================

  /// Get user trading statistics
  Future<Map<String, dynamic>> getUserStats() async {
    if (currentUser == null) return {};

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('signal_history')
          .get();

      List<TradingSignal> signals = snapshot.docs
          .map((doc) =>
          TradingSignal.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      int totalSignals = signals.length;
      int buySignals = signals.where((s) => s.signalType == 'BUY').length;
      int sellSignals = signals.where((s) => s.signalType == 'SELL').length;
      int waitSignals = signals.where((s) => s.signalType == 'WAIT').length;

      double avgConfidence = totalSignals > 0
          ? signals.map((s) => s.confidence).reduce((a, b) => a + b) /
          totalSignals
          : 0;

      return {
        'totalSignals': totalSignals,
        'buySignals': buySignals,
        'sellSignals': sellSignals,
        'waitSignals': waitSignals,
        'avgConfidence': avgConfidence,
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get all users (for any admin features you might add later)
  Future<List<AppUser>> getAllUsers() async {
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

  /// Delete user account (for user self-deletion)
  Future<Map<String, dynamic>> deleteUserAccount() async {
    if (currentUser == null) {
      return {'success': false, 'error': 'No user logged in'};
    }

    try {
      final userId = currentUser!.uid;

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user authentication
      await currentUser!.delete();

      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}