import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// UserModel definition
class UserModel {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;

  UserModel(
      {required this.uid,
      required this.username,
      required this.email,
      required this.imageUrl});

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}

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
