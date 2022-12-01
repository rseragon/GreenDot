import 'package:flutter/material.dart';
import 'package:greendot/screens/login_screen.dart';
import 'package:greendot/screens/maps_screen.dart';
import 'package:greendot/utils/fireauth.dart';
import 'package:shared_preferences/shared_preferences.dart';


/*
  First of all, who ever is reading this project, please refrain from doing so
  This might be the most unpleasent experience in your entire life

  If you still think of proceeding, then follow the steps in `steps` file to make it a working project
  
  and here are refer each file's top to get to know what that file is for 

  good luck misfortued stranger
*/

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Will be done while logging in
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform
  // );

  runApp(const Fyto());
}

class Fyto extends StatelessWidget {

  const Fyto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Green Dot",
      themeMode: ThemeMode.system,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {

          if(snapshot.connectionState == ConnectionState.done) {
            if(!snapshot.hasError) {
              // Navigator.push(
              //   context, 
              //   MaterialPageRoute(builder: (context) => LoginScreen()),
              // );
              if(snapshot.hasData) {
                final prefs = snapshot.data;

                bool? skip = prefs?.getBool("skip_login");

                if(skip == null || skip == false) {
                  return LoginScreen();
                }
                else {
                  FireAuth.initializeFirebase(context: context);
                  return MapsScreen();
                }

              }
            }
          }
          return const Center(
            child: CircularProgressIndicator()
          );
        }
      ),

    );
  }

}
