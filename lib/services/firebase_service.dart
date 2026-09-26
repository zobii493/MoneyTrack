import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';

class FirebaseService {
  static bool _isFirebaseInitialized = false;

  static bool get isInitialized => _isFirebaseInitialized;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      debugPrint('Firebase initialized successfully.');
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint('Firebase initialization notice: $e (Falling back to local storage).');
    }
  }

  // --- Auth Operations ---

  static Future<UserCredential?> signUpWithEmail(String email, String password) async {
    if (!_isFirebaseInitialized) return null;
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Automatically send real email verification
    try {
      await credential.user?.sendEmailVerification();
      debugPrint('Verification email sent to $email');
    } catch (e) {
      debugPrint('Error sending verification email: $e');
    }

    return credential;
  }

  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!_isFirebaseInitialized) return null;
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Real Google Sign In Integration
  static Future<UserCredential?> signInWithGoogle() async {
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not initialized.');
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  static Future<void> sendEmailVerification() async {
    if (!_isFirebaseInitialized) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<bool> checkEmailVerified() async {
    if (!_isFirebaseInitialized) return true; // Default true if offline
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    await user.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  static Future<void> sendPasswordReset(String email) async {
    if (!_isFirebaseInitialized) return;
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    if (!_isFirebaseInitialized) return;
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }

  static String? get currentUserId {
    if (!_isFirebaseInitialized) return null;
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static User? get currentUser {
    if (!_isFirebaseInitialized) return null;
    return FirebaseAuth.instance.currentUser;
  }

  // --- Firestore Collections ---

  static DocumentReference? _userDoc(String uid) {
    if (!_isFirebaseInitialized) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  // Save User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    final doc = _userDoc(profile.id);
    if (doc == null) return;
    await doc.set(profile.toJson(), SetOptions(merge: true));
  }

  // Save Transaction to Firestore
  static Future<void> saveTransaction(TransactionModel txn) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('transactions').doc(txn.id).set(txn.toJson());
  }

  static Future<void> deleteTransaction(String txnId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('transactions').doc(txnId).delete();
  }

  // Save Account to Firestore
  static Future<void> saveAccount(AccountModel acc) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('accounts').doc(acc.id).set(acc.toJson());
  }

  static Future<void> deleteAccount(String accId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('accounts').doc(accId).delete();
  }

  // Save Budget to Firestore
  static Future<void> saveBudget(BudgetModel budget) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('budgets').doc(budget.id).set(budget.toJson());
  }

  static Future<void> deleteBudget(String budgetId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('budgets').doc(budgetId).delete();
  }

  // Save Goal to Firestore
  static Future<void> saveGoal(GoalModel goal) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('goals').doc(goal.id).set(goal.toJson());
  }

  static Future<void> deleteGoal(String goalId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('goals').doc(goalId).delete();
  }

  // Save Category to Firestore
  static Future<void> saveCategory(CategoryModel cat) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('categories').doc(cat.id).set(cat.toJson());
  }

  static Future<void> deleteCategory(String catId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _userDoc(uid)?.collection('categories').doc(catId).delete();
  }

  // Fetch all user data from Firestore
  static Future<Map<String, dynamic>?> fetchAllUserData(String uid) async {
    if (!_isFirebaseInitialized) return null;
    final userRef = _userDoc(uid);
    if (userRef == null) return null;

    final profileSnap = await userRef.get();
    final txnsSnap = await userRef.collection('transactions').get();
    final accsSnap = await userRef.collection('accounts').get();
    final budgsSnap = await userRef.collection('budgets').get();
    final goalsSnap = await userRef.collection('goals').get();
    final catsSnap = await userRef.collection('categories').get();
    final notifsSnap = await userRef.collection('notifications').get();

    return {
      'profile': profileSnap.data(),
      'transactions': txnsSnap.docs.map((d) => d.data()).toList(),
      'accounts': accsSnap.docs.map((d) => d.data()).toList(),
      'budgets': budgsSnap.docs.map((d) => d.data()).toList(),
      'goals': goalsSnap.docs.map((d) => d.data()).toList(),
      'categories': catsSnap.docs.map((d) => d.data()).toList(),
      'notifications': notifsSnap.docs.map((d) => d.data()).toList(),
    };
  }
}
