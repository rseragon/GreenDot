import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendot/model/plant_model.dart';

/*
  Used by plant_details_screen to display static info about plants
  which is fetched from the db

  see plant_details_screen for more info
*/

class PlantDetailsWidget extends StatelessWidget {

  PlantDetails info;

  PlantDetailsWidget(this.info, {super.key});

  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: getPlantPictureDownloadUrl(info),
              builder: (context, snapshot) {

                Widget child = Image.asset("assets/plant_placeholder.png");
                if(snapshot.hasData && snapshot.data != "") {
                    child = Image.network(snapshot.data!);
                }
                return SizedBox(
                  height: 50,
                  width: 50,
                  child: child,
                );
              }
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.8,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Species: ${info.name}"),
                  Text("Scientific Name: ${info.scientificName}"),
                  Text("Info: ${info.info}"),
                  Divider()
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  // These are statck files
  Future<String> getPlantPictureDownloadUrl(PlantDetails info) async {

    final storageRef = FirebaseStorage.instance.ref().child("static");

    String url = "";
    try{
      var plantImage = storageRef.child("${info.scientificName}.jpg");
      url = await plantImage.getDownloadURL();
    }
    catch (e) {
      return "";
    }

    return url;
  }
}
