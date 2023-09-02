import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/user_model.dart';

// UserNotifier definition
class UserNotifier extends StateNotifier<UserModel?> {
  StreamSubscription<DocumentSnapshot>? _subscription;

  UserNotifier() : super(null) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _listenForUserDataChanges();
      } else {
        cancelSubscription();
        state = null; // Reset the user state when logged out
      }
    });
  }

  // Listen to real-time changes in Firestore
  void _listenForUserDataChanges() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        state = UserModel.fromFirestore(uid, snapshot.data()!);
      } else {
        state = null;
      }
    });
  }

  void cancelSubscription() {
    _subscription?.cancel();
  }
}

// Riverpod provider declaration
final userProvider =
    StateNotifierProvider<UserNotifier, UserModel?>((ref) => UserNotifier());
