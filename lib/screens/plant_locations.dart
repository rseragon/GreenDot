import 'package:flutter/material.dart';
import 'package:greendot/model/plant_model.dart';
import 'package:greendot/widgets/plant_info_widget.dart';

/* 
  This is plant specific info page, which shows the info
  of latitiute, longitue, extrainfo, picture of plant
*/

class PlantLocationsScreen extends StatelessWidget {

  List<PlantLocationInfo> plants = [];
  String plantName = "";

  PlantLocationsScreen(this.plantName, this.plants);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: plants.map((e) => PlantLocationInfoWidget(e)).toList(),
          ),
        )
      ),
    );
  }
}
