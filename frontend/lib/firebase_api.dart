import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Get the token each time the application loads
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print('FirebaseMessaging token: $token');
  }
}
