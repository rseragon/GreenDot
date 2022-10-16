import 'package:flutter/material.dart';
import 'package:fyto/model/plant_model.dart';
import 'package:fyto/widgets/plant_info_widget.dart';

class PlantLocationsScreen extends StatelessWidget {

  List<PlantInfo> plants = [];
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
            children: plants.map((e) => PlantInfoListWidget(e)).toList(),
          ),
        )
      ),
    );
  }
}
