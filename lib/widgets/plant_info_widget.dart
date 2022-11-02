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
            SizedBox(
              height: 50,
              width: 50,
              child: Image.network("https://www.nicepng.com/png/detail/73-730825_pot-plant-clipart-potted-plant-pot-plant-icon.png")
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
}
