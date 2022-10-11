import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SharedData {
  static final SharedData _sharedData = SharedData._internal();

  factory SharedData() {
    return _sharedData;
  }

  SharedData._internal();

  static User? currentUser;
  static FirebaseAuth? firebaseAuth;
  static FirebaseApp? firebaseApp;

}
