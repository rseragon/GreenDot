import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyto/model/plant_model.dart';
import 'package:fyto/res/custom_color.dart';
import 'package:fyto/screens/maps_screen.dart';
import 'package:fyto/screens/user_info.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireAuth {

  static SnackBar customSnackbar({required String content}) {
    return SnackBar(
      backgroundColor: CustomColors.nordPolarNight1,
      content: Text(content),
      duration: const Duration(seconds: 2),
    );
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MapsScreen(),
        ),
      );
    }

    return firebaseApp;
  }

  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static bool checkLoggedin({required BuildContext context}) {

    FirebaseApp app = Firebase.app();

    User? user = FirebaseAuth.instanceFor(app: app).currentUser;

    if(user != null) {
      return true;
    }
    return false;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
      final UserCredential userCredential =
      await auth.signInWithCredential(credential);

      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          FireAuth.customSnackbar(
            content:
            'The account already exists with a different credential',
          ),
        );
      } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            FireAuth.customSnackbar(
              content:
              'Error occurred while accessing credentials. Try again.',
            ),
          );
        }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        FireAuth.customSnackbar(
          content: 'Error occurred using Google Sign In. Try again.',
        ),
      );
    }
    }

    return user;
  }



  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      FireAuth.customSnackbar(
        content: 'Error signing out. Try again.',
      ),
    );
  }
  }

}
