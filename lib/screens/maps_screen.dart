import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:greendot/model/plant_model.dart';
import 'package:greendot/res/custom_color.dart';
import 'package:greendot/screens/about_screen.dart';
import 'package:greendot/screens/plant_details_screen.dart';
import 'package:greendot/screens/plant_locations.dart';
import 'package:greendot/screens/add_location.dart';
import 'package:greendot/screens/login_screen.dart';
import 'package:greendot/screens/user_info.dart'; 
import 'package:greendot/utils/database.dart';
import 'package:greendot/utils/fireauth.dart';
import 'package:greendot/widgets/plant_type_widget.dart';

/* This shows most of the plants from the data */

class MapsScreen extends StatefulWidget {
  @override State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {

  late final MapController _mapController;

  static Map<String, List<PlantLocationInfo>> plantsInfo = {};
  static List<String> plantTypes = [];
  int count = 0;

  bool mapInitedWithData = false;

  @override
    void initState() {
      super.initState();
      
      _mapController = MapController(
                            initMapWithUserPosition: false,
                            initPosition: GeoPoint(latitude:  18.751071 , longitude: 73.802194),
                            // areaLimit: BoundingBox( east: 10.4922941, north: 47.8084648, south: 45.817995, west: 5.9559113,),
                       );
    }

    @override
      void dispose() {
        super.dispose();
        _mapController.dispose();
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          bool loggedIn = await FireAuth.checkLoggedin(context: context);
          if(!loggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("User not logged in"),
              backgroundColor: Colors.redAccent,
            ));
          }
          else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => AddLocation())
            );
          }
        }
      ),

      appBar: AppBar(
        title: const Text("Plants Map"),
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     GeoPoint p = GeoPoint(latitude: 18.5204, longitude: 73.8567);
          //     await _mapController.addMarker(p);
          //     setState(() {});
          //   }, 
          //   icon: Icon(Icons.location_pin),
          // ),
          IconButton(
            onPressed: () async {
              PlantDatabase.initDatabase();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Database fetching..."),
                backgroundColor: Colors.blueAccent,
                duration: Duration(milliseconds: 500),
              ));
              await getDatabaseData(forced:  true);
              setState(() {});
            }, 
            icon: Icon(Icons.refresh_rounded)
          ),
          IconButton(
            onPressed: () async {
              bool loggedIn = await FireAuth.checkLoggedin(context: context);
              if(loggedIn) {
                User user = FireAuth.getCurrentUser()!;
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (builder) => UserInfoScreen(user: user)),
                );
              }
                else {
                ScaffoldMessenger.of(context).showSnackBar(
                  FireAuth.customSnackbar(content: "User not logged in"),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => LoginScreen()),
                );
              }
            }, 
            icon: const Icon(Icons.account_circle)
          ),
        ],
        
      ),

      drawer: Drawer(
        backgroundColor: CustomColors.firebaseNavy,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: CustomColors.nordSnowStorm1,
              ),
              child: Image.asset("assets/being_volunteer.png"),
            ),
            ListTile(
              title: const Text(
                "Plants Info",
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.info_rounded, color: Colors.white70,),
              onTap: () {
                Navigator.pop(context); // To close the drawer
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (builder) => PlantDetailScreen()),
                );
              },
            ),
            ListTile(
              title: const Text(
                "About",
                style: TextStyle(color: Colors.white),
              ),
              leading: const Icon(Icons.info_rounded, color: Colors.white70,),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => AboutScreen())
                );
              },
            )
          ],
        )
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/3,
                child: OSMFlutter(
                  controller: _mapController,
                  initZoom: 14,
                  markerOption: MarkerOption(
                    defaultMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.location_pin, 
                        color: Colors.greenAccent,
                        size: 80,
                      ),
                    )
                  ),
                )
              ),
            ),
            FutureBuilder(
              future: getDatabaseData(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done) {
                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Total Count: $count"),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: plantTypes.length,
                            itemBuilder: ((context, index) {
                              return InkWell(
                                child: PlantTypeWidget(PlantType(plantTypes[index], plantsInfo[plantTypes[index]]?.length ?? 0)),
                                onTap: () {
                                  // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(plantTypes[index])));
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (builder) => PlantLocationsScreen(plantTypes[index], plantsInfo[plantTypes[index]] ?? []))
                                  );
                                },
                              );
                            })
                          ),
                        ),
                      ],
                    ),
                  );
                }
                  else {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    ),
                  );
                }
              }
            )
          ],
        )
      ),
    );
  }

  Future<void> updateMap({bool forced = false}) async {

    if(forced || !mapInitedWithData) {
      for(var kv in plantsInfo.entries) {
        var key = kv.key;
        var value = kv.value;

        double lat = 0.0;
        double lng = 0.0;
        int count = 0;
        for(var info in value.take(5)) {
          await _mapController.addMarker(GeoPoint(latitude: info.lat, longitude: info.lng));
          lat += info.lat;
          lng += info.lng;
          count ++;
        }
        lat = lat/count;
        lng = lng/count;
        await _mapController.goToLocation(GeoPoint(latitude: lat, longitude: lng));
      }
      setState(() {});
      mapInitedWithData = true;
    }

  }

  Future<void> getDatabaseData({bool forced = true}) async {
    if(plantsInfo.isEmpty || forced) {
      plantsInfo = await PlantDatabase.getPlantsLocationInfo();
      plantTypes = plantsInfo.keys.toList();
      count = 0;
      plantsInfo.forEach((key, value) { count += value.length; });
      await updateMap();
    }

  }
}
