import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  static Future<bool> uploadPlantLocationInfo(PlantLocationInfo info, String imagePath) async {
    //TODO: Error handling

    final plantLocationRef = database.ref("PlantLocation/${info.plantType}");
    final newLocref = plantLocationRef.push();

    // Upload to database
    try {
      newLocref.set({
        "lat": info.lat,
        "lng": info.lng,
        "plant_type": info.plantType,
        "user_email": info.userEmail,
        "extra_info": info.extraInfo
      });
    } catch(e) {
      print(e);
      return Future.value(false);
    }

    // upload image to storage
    String imageUri = "userUploads/${info.plantType}/${newLocref.key}.jpg";
    final res = await uploadImage(imagePath, imageUri);
    if(!res) {
      return Future.value(false);
    }

    return Future.value(true);
  }

  static Future<bool> uploadImage(String imagePath, String uploadUrl) async {
    final storageRef = FirebaseStorage.instance.ref();

    final imageUriRef = storageRef.child(uploadUrl);

    try {
      await imageUriRef.putFile(File(imagePath));
    } on Exception catch (e) {
      print(e);
      return Future.value(false);
    }
  
    return Future.value(true);
  }

  static Future<Map<String, List<PlantLocationInfo>>> getPlantsLocationInfo() async {
    if (!inited) {
      initDatabase();
    }

    DataSnapshot plantLocRef = await database.ref("PlantLocation").get();

    Map<String, List<PlantLocationInfo>> info = {};
    // PlantName, PlantInfos

    if (plantLocRef.exists) {
      for (DataSnapshot child in plantLocRef.children) {
        String plantName = child.key as String;
        List<PlantLocationInfo> plantInfoList = [];
        for (DataSnapshot location in child.children) {
          final Map val = location.value as Map;
          if (val.isEmpty) {
            continue;
          }
          var plant = PlantLocationInfo(val['lat'], val['lng'], val['plant_type'],
                  val['user_email'], val['extra_info']);
          plant.imageUri = "${plant.plantType}/${location.key}.jpg";  // get plant image uri
          plantInfoList.add(plant);
        }
        info[plantName] = plantInfoList;
      }
    }
    return Future.value(info);
  }

  static Future<List<PlantDetails>> getPlantDetails() async {
    List<PlantDetails> details = [];

    if(!inited) {
      initDatabase();
    }

    DataSnapshot pDetRef = await database.ref("PlantDetails").get();

    if(pDetRef.exists) {
      for(DataSnapshot plant in pDetRef.children) {
        String plantName = plant.key as String;
        Map data = plant.value as Map;
        if(data.isEmpty) {
          continue;
        }
        details.add(PlantDetails(plantName, data['scientific_name'], data['info']));

      }
    }

    return Future.value(details);
  }
}
