import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fyto/model/plant_model.dart';

class PlantDatabase {
  static late final FirebaseDatabase database;
  static late final plantsRef;
  static bool inited = false;

  static void initDatabase() {
    if (inited) {
      return;
    }
    database = FirebaseDatabase.instance;
    database.setPersistenceEnabled(true);
    plantsRef = database.ref("plants/");
    inited = true;
  }

  // static Future<void> addDummyData() async {
  //   final plan1 = plantsRef.child("plan1");
  //   await plan1.set(
  //       {"name": "plan1", "lat": 18.5204, "lng": 73.8567, "extra_info": ""});
  // }
  //
  // static Future<PlantInfo?> getDummyData() async {
  //   final plan1 = await plantsRef.child("plan1").get();
  //
  //   if (plan1.exists) {
  //     return Future.value(PlantInfo(plan1.value['lat'], plan1.value['lng'],
  //         plan1.value['plantType'], plan1.value['extra_info'], plan1.value['user_email']));
  //   } else {
  //     return Future.value(null);
  //   }
  // }

  static Future<List<String>> getPlantTypes() async {
    List<String> plants = [];

    if (!inited) {
      initDatabase();
    }
    final plantsTypeRef =
        database.ref("PlantTypes"); // TODO: Expects "PlantsType" in firebase db

    final allTypes = await plantsTypeRef.get();

    if (allTypes.exists && allTypes.value != null) {
      (allTypes.value as Map).forEach((key, value) {
        plants.add(key);
      });
    }
    return Future.value(plants.toSet().toList());
  }

  static Future<bool> uploadPlantLocationInfo(PlantInfo info) async {

    //TODO: Error handling

    final plantLocationRef = database.ref("PlantLocation/${info.plantType}");
    final newLocref = plantLocationRef.push();
    newLocref.set({
      "lat": info.lat,
      "lng": info.lng,
      "plant_type": info.plantType,
      "user_email": info.userEmail,
      "extra_info": info.extraInfo
    });

    return Future.value(true);
  }


  static List<Widget> getPlantsInfo() {
    return const [
      Text("1"),
      Text("3"),
      Text("4"),
      Text("5"),
      Text("6"),
      Text("7"),
      Text("8"),
      Text("9"),
    ];
  }
}
