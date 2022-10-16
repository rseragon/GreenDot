import 'package:flutter/material.dart';
import 'package:fyto/model/plant_model.dart';
import 'package:fyto/res/custom_color.dart';
import 'package:fyto/utils/database.dart';

class PlantsInfoScreen extends StatefulWidget {

  @override
  State<PlantsInfoScreen> createState() => _PlantsInfoScreenState();
}

class _PlantsInfoScreenState extends State<PlantsInfoScreen> {

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.firebaseNavy,
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder(
          future: PlantDatabase.getPlantTypes(), // TODO: Change this to plant info
          builder: ((context, snapshot) {

            List<Widget> children = [];

            if(snapshot.hasData) {
              if(snapshot.data != null) {
                int len = snapshot.data?.length ?? 0;
                  if(len != 0) {
                    for(int i = 0; i < len; i++) {
                    // children.add(Text(snapshot.data?[i].plantType ?? ""));
                    children.add(Text(snapshot.data?[i]?? ""));
                    children.add(const Divider(color: Colors.black87));
                  }
                }
              }
                else {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ];
              }
            }
              else if(snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ];
              }
                else {
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  ),
                ];

              }

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              ),
            );

          }))
      ),
    );
  }


  Future<List<PlantInfo>> getInfoFromDb() async {
    // PlantInfo p1 = PlantInfo(1.0, 2.0, "plan1", "");
    // PlantInfo p2 = PlantInfo(1.0, 2.0, "plan2", "");
    // PlantInfo p3 = PlantInfo(1.0, 2.0, "plan3", "");
    // PlantInfo p4 = PlantInfo(1.0, 2.0, "plan4", "");
    // PlantInfo p5 = PlantInfo(1.0, 2.0, "plan5", "");

    await Future.delayed(Duration(seconds: 3));
    return Future.value([]);

    // return Future.value([p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, p1, p2, p3, p4, p5, ]);
  }
}
