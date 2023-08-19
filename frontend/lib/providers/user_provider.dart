import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/user_model.dart';

// UserNotifier definition
class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _listenForUserDataChanges();
  }

  // Listen to real-time changes in Firestore
  void _listenForUserDataChanges() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
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
}

// Riverpod provider declaration
final userProvider =
    StateNotifierProvider<UserNotifier, UserModel?>((ref) => UserNotifier());
