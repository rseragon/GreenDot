import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyto/model/plant_model.dart';

/* This shows the longitue latitue and extra info about the plants
  Used in the plant_locations screen
*/

class PlantLocationInfoWidget extends StatelessWidget {

  PlantLocationInfo info;

  PlantLocationInfoWidget(this.info, {super.key});

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

                String url = "https://www.nicepng.com/png/detail/73-730825_pot-plant-clipart-potted-plant-pot-plant-icon.png";
                if(snapshot.hasData && snapshot.data != null) {
                  url = snapshot.data!;
                }
                print(url);
                return SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.network(url),
                );
              }
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Species: ${info.plantType}"),
                Text("Latitude: ${info.lat}° Longitude: ${info.lng}°"),
                Text("Extra Info: ${info.extraInfo}"),
                Divider()
              ],
            ),
          ],
        ),
      ),
    );

  }

  // These are pictures uploaded by user
  Future<String> getPlantPictureDownloadUrl(PlantLocationInfo info) async {

    final storageRef = FirebaseStorage.instance.ref().child("userUploads");

    var plantImage = storageRef.child(info.imageUri);

    var url = await plantImage.getDownloadURL();

    return (url.isEmpty) ? "https://www.nicepng.com/png/detail/73-730825_pot-plant-clipart-potted-plant-pot-plant-icon.png" : url;
  }
}
