import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:greendot/model/plant_model.dart';
import 'package:greendot/screens/login_screen.dart';
import 'package:greendot/utils/database.dart';
import 'package:greendot/utils/fireauth.dart';
import 'package:image_picker/image_picker.dart';

/* This screen is for adding location for the plant */

class AddLocation extends StatefulWidget {

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {

  late final MapController _mapController;
  final PickerMapController _pickerMapController = PickerMapController(
    initMapWithUserPosition: true
  );
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _extraInfo = TextEditingController();

  double latDouble = 0.0;
  double lngDouble = 0.0;

  List<String> plantTypes = [];
  String selectedPlant = "";
  String imagePath = "";

  late final focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pickerMapController.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Plant upload"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await uploadPlantLocationInfo(context);
        },
        child: Icon(Icons.upload_rounded),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width,
                      child: CustomPickerLocation(
                        controller: _pickerMapController,
                        onMapReady: setCurrentLocation,
                        pickerConfig: const CustomPickerLocationConfig(
                          initZoom: 17,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          GeoPoint point = await _pickerMapController.selectAdvancedPositionPicker();

                          updatePoint(point.latitude, point.longitude);

                          await _pickerMapController.advancedPositionPicker();
                        }, 
                        icon: const Icon(Icons.add_location), 
                        label: const Text("Update location"),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _longitude,
                              decoration: const InputDecoration(labelText: 'Longitude'),
                              enabled: false,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _latitude,
                              decoration: const InputDecoration(labelText: 'Latitude',),
                              enabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    FutureBuilder(
                      future: getPlantTypesList(),
                      builder: ((context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.done) {
                          List<String> plants = snapshot.data ?? [];
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: DropdownButton(
                              value: selectedPlant,
                              isExpanded: true,
                              items: plants.map((e) => DropdownMenuItem(value: e,child: Text(e),)).toList(),
                              onChanged: (String? val) {
                                if(val is String) {
                                  setState(() {
                                    selectedPlant = val;
                                  });
                                  if(focusNode.hasFocus) {
                                    focusNode.unfocus();
                                  }
                                }
                              }
                            ),
                          );
                        }
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [CircularProgressIndicator()],
                          )
                        );
                      })
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
                        if(image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Image not selected"),
                            backgroundColor: Colors.redAccent,
                          )
                          );
                        }
                        else {
                          imagePath = image.path;
                        }
                      },
                      icon: const Icon(Icons.camera), 
                      label: const Text("Take Picture")
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Extra Info'),
                        controller: _extraInfo,
                        focusNode: focusNode,
                        autofocus: false,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadPlantLocationInfo(BuildContext context) async  {
    if(FireAuth.checkLoggedin(context: context) == false) {
      ScaffoldMessenger.of(context).showSnackBar(FireAuth.customSnackbar(content: "User not logged in"));
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (builder) => LoginScreen())
      );
    }
      else {
      User? user = FireAuth.getCurrentUser();
      if(user == null) {
        ScaffoldMessenger.of(context).showSnackBar(FireAuth.customSnackbar(content: "User not logged in"));
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (builder) => LoginScreen())
        );
      }
        else {
        // TODO: Check the data valididty
        String userEmail = user.email ?? "";
        double lat = latDouble;
        double lng = lngDouble;
        String info = _extraInfo.text;

        if(userEmail.isEmpty || lat == 0.0 || lng == 0.0 || imagePath.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Invalid data"),
            backgroundColor: Colors.redAccent,
          )
          );
          return;
        }

        bool res = await PlantDatabase.uploadPlantLocationInfo(PlantLocationInfo(lat, lng, selectedPlant, userEmail, info), imagePath);

        if(res == true) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Uploaded successfully"),
            backgroundColor: Colors.greenAccent,
          )
          );
          Navigator.pop(context);
        }
          else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to upload data"),
            backgroundColor: Colors.redAccent,
          )
          );
        }

      }
    }

  }

  void updatePoint(double lat, double lng) {
    latDouble = lat;
    lngDouble = lng;
    setState(() {
      _latitude.text = "$latDouble°";
      _longitude.text = "$lngDouble°";
    });
  }

  Future<void> setCurrentLocation(bool isReady) async {

    GeoPoint point = await _pickerMapController.selectAdvancedPositionPicker();
    updatePoint(point.latitude, point.longitude);
  }

  Future<List<String>> getPlantTypesList() async {
    if(plantTypes.isEmpty) {
      plantTypes = await PlantDatabase.getPlantTypes();
      plantTypes = plantTypes.toSet().toList();
      selectedPlant = plantTypes.first;
    }
    return Future.value(plantTypes);
  }

}
