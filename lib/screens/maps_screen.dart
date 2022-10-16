import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:fyto/model/plant_model.dart';
import 'package:fyto/model/plant_type.dart';
import 'package:fyto/res/custom_color.dart';
import 'package:fyto/screens/plant_locations.dart';
import 'package:fyto/screens/plants_info.dart';
import 'package:fyto/screens/add_location.dart';
import 'package:fyto/screens/login_screen.dart';
import 'package:fyto/screens/user_info.dart';
import 'package:fyto/utils/database.dart';
import 'package:fyto/utils/fireauth.dart';
import 'package:fyto/widgets/plant_type_widget.dart';

class MapsScreen extends StatefulWidget {
  @override State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {

  late final _mapController;

  static Map<String, List<PlantInfo>> plantsInfo = {};
  static List<String> plantTypes = [];
  int count = 0;

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
        title: const Text("Fyto Map"),
        actions: [
          IconButton(
            onPressed: () async {
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent
              ),
              child: Text(
                "Fyto geo tagger",
                style: TextStyle(color: Colors.white),
              )
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
                  MaterialPageRoute(builder: (builder) => PlantsInfoScreen()),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("TODO")));
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
                        Icons.map_rounded, 
                        color: Colors.greenAccent,
                        size: 20,
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

  Future<void> getDatabaseData({bool forced = true}) async {

    if(plantsInfo.isEmpty || forced) {
      plantsInfo = await PlantDatabase.getPlantsLocationInfo();
      plantTypes = plantsInfo.keys.toList();
      count = 0;
      plantsInfo.forEach((key, value) { count += value.length; });
    }
  }
}
