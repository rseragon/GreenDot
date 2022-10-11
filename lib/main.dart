import 'package:flutter/material.dart';
import 'package:fyto/screens/login_screen.dart';
import 'package:fyto/screens/maps_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: "Fyto",
      themeMode: ThemeMode.dark,
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
