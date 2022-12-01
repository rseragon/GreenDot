import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendot/model/plant_model.dart';

class PlantTypeWidget extends StatelessWidget {

  PlantType info;

  PlantTypeWidget(this.info, {super.key});

  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: getPlantPictureDownloadUrl(info),
              builder: (context, snapshot) {

                Widget child = Image.asset("assets/plant_placeholder.png");
                if(snapshot.hasData && snapshot.data != "") {
                  child = Image.network(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  );
                }
                return SizedBox(
                  height: 90,
                  child: child,
                );
              }
            ),
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Species: ${info.plantName}"),
                  Text("Count: ${info.count}"),
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
  Future<String> getPlantPictureDownloadUrl(PlantType info) async {

    final storageRef = FirebaseStorage.instance.ref().child("static");

    String url = "";
    try{
    var plantImage = storageRef.child("${info.plantName}.jpg");
      url = await plantImage.getDownloadURL();
    }
    catch (e) {
      return "";
    }

    return (url.isEmpty) ? "" : url;
  }
}
