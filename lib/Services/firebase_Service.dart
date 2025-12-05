import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trading_models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin email for OTP notifications
  static const String adminEmail = 'ahmadasif20222@gmail.com'; // Replace with actual admin email

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

      // Generate OTP
      String otp = _generateOTP();

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
        'pendingOtp': otp,
        'otpCreatedAt': FieldValue.serverTimestamp(),
      });

      // Send OTP to admin for approval
      await _sendOtpToAdmin(email, displayName, otp);

      return {
        'success': true,
        'message': 'Registration successful! Waiting for admin approval.',
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

      // Check if user is approved
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {'success': false, 'error': 'User profile not found'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userData['isApproved'] != true) {
        await _auth.signOut();
        return {
          'success': false,
          'error': 'Your account is pending approval. Please wait for admin verification.',
          'pendingApproval': true,
        };
      }

      return {
        'success': true,
        'user': AppUser.fromJson(userData),
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Generate 6-digit OTP
  String _generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP to admin email (simulated - in production use email service)
  Future<void> _sendOtpToAdmin(String userEmail, String userName, String otp) async {
    // Store OTP request in Firestore for admin to see
    await _firestore.collection('pending_approvals').add({
      'userEmail': userEmail,
      'userName': userName,
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    // In production, you would send an actual email here using:
    // - Firebase Cloud Functions with SendGrid/Mailgun
    // - Or use a third-party email service

    print('OTP for $userEmail: $otp (Send to admin email: $adminEmail)');
  }

  /// Verify OTP and approve user (Admin function)
  Future<Map<String, dynamic>> verifyAndApproveUser({
    required String userId,
    required String enteredOtp,
  }) async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {'success': false, 'error': 'User not found'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String? storedOtp = userData['pendingOtp'];

      if (storedOtp == null || storedOtp != enteredOtp) {
        return {'success': false, 'error': 'Invalid OTP'};
      }

      // Approve user
      await _firestore.collection('users').doc(userId).update({
        'isApproved': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'pendingOtp': FieldValue.delete(),
        'otpCreatedAt': FieldValue.delete(),
      });

      // Update pending approval status
      QuerySnapshot pendingDocs = await _firestore
          .collection('pending_approvals')
          .where('userEmail', isEqualTo: userData['email'])
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in pendingDocs.docs) {
        await doc.reference.update({'status': 'approved'});
      }

      return {'success': true, 'message': 'User approved successfully'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
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

  /// Check if user is approved
  Future<bool> isUserApproved() async {
    if (currentUser == null) return false;

    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['isApproved'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
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
          .map((doc) => TradingSignal.fromJson(doc.data() as Map<String, dynamic>))
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

  // ==================== ADMIN FUNCTIONS ====================

  /// Get pending approvals (Admin only)
  Future<List<Map<String, dynamic>>> getPendingApprovals() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('pending_approvals')
          .where('status', isEqualTo: 'pending')
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

  /// Get all users (Admin only)
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

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    if (currentUser == null) return false;

    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['isAdmin'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
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
          .map((doc) => TradingSignal.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      int totalSignals = signals.length;
      int buySignals = signals.where((s) => s.signalType == 'BUY').length;
      int sellSignals = signals.where((s) => s.signalType == 'SELL').length;
      int waitSignals = signals.where((s) => s.signalType == 'WAIT').length;

      double avgConfidence = totalSignals > 0
          ? signals.map((s) => s.confidence).reduce((a, b) => a + b) / totalSignals
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
}