import 'package:flutter/material.dart';
import 'package:fyto/model/plant_model.dart';

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
            SizedBox(
              height: 50,
              width: 50,
              child: Image.network("https://www.nicepng.com/png/detail/73-730825_pot-plant-clipart-potted-plant-pot-plant-icon.png")
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
}
