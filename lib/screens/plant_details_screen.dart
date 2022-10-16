import 'package:flutter/material.dart';
import 'package:fyto/model/plant_details.dart';
import 'package:fyto/utils/database.dart';
import 'package:fyto/widgets/plant_details_widget.dart';

class PlantDetailScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plants Information"),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: buildPlantDetailsWidgets(),
          builder: ((context, snapshot) {

            List<Widget> children = [];

            if(snapshot.connectionState == ConnectionState.done) {

              return ListView(
                children: snapshot.data ?? [],
              );

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
                  child: Text('Loading...'),
                ),
              ];
            }
            return Center(
              child: Column(
                children: children,
              )
            );

          })
        )
      ),

    );
  }

  Future<List<Widget>> buildPlantDetailsWidgets() async {
    List<Widget> children = [];

    children = (await PlantDatabase.getPlantDetails()).map((e) => PlantDetailsWidget(e)).toList();

    return children;
  }
}
