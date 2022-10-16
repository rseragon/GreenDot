import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:fyto/model/plant_model.dart';
import 'package:fyto/res/custom_color.dart';
import 'package:fyto/screens/login_screen.dart';
import 'package:fyto/utils/database.dart';
import 'package:direct_select/direct_select.dart';
import 'package:fyto/utils/fireauth.dart';

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

  static List<String> plantTypes = [];
  String selectedPlant = "";

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
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
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
                      padding: EdgeInsets.all(4.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          GeoPoint point = await _pickerMapController.selectAdvancedPositionPicker();

                          updatePoint(point.latitude, point.longitude);

                          await _pickerMapController.advancedPositionPicker();
                        }, 
                        icon: Icon(Icons.add_location), 
                        label: Text("Update location"),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _longitude,
                              decoration: InputDecoration(labelText: 'Longitude'),
                              enabled: false,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _latitude,
                              decoration: InputDecoration(labelText: 'Latitude',),
                              enabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Extra Info'),
                      controller: _extraInfo,
                      focusNode: focusNode,
                      autofocus: false,
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
                              items: plants.map((e) => DropdownMenuItem(child: Text(e), value: e,)).toList(),
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
                            children: [CircularProgressIndicator()],
                          )
                        );
                      })
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
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

                            if(userEmail == "" || lat == 0.0 || lng == 0.0) {
                              ScaffoldMessenger.of(context).showSnackBar(FireAuth.customSnackbar(content: "Invalid data"));
                              return;
                            }

                            bool res = await PlantDatabase.uploadPlantLocationInfo(PlantInfo(lat, lng, selectedPlant, userEmail, info));

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

                      }, 
                      icon: Icon(Icons.upload_rounded), 
                      label: Text("Upload")
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
    return plantTypes;
  }
}
