import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: SafeArea(
        child: IntroductionScreen(
          showSkipButton: false,
          showNextButton: false,
          showBackButton: false,
          onDone: () {
              Navigator.pop(context);
          },
          done: const Icon(Icons.done),
          pages: [
            PageViewModel(
                title: "Green Dot Plant Geo-Tagging Application",
                body:
                    "Initiated by Being Volunteer Foundation, Green Dot app is used for Geo-Tagging Plants.",
                image: Center(child: Image.asset("assets/being_volunteer.png")))
          ],
        ),
      ),
    );
  }
}
