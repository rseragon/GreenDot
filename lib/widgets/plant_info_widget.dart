import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendot/model/plant_model.dart';
import 'package:photo_view/photo_view.dart';

/* This shows the longitue latitue and extra info about the plants
  Used in the plant_locations screen
*/

class PlantLocationInfoWidget extends StatelessWidget {

  PlantLocationInfo info;

  PlantLocationInfoWidget(this.info, {super.key});

  @override
  Widget build(BuildContext context) {

    return Material(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: getPlantPictureDownloadUrl(info),
              builder: (context, snapshot) {

                String url = "https://www.nicepng.com/png/detail/73-730825_pot-plant-clipart-potted-plant-pot-plant-icon.png";
                if(snapshot.hasData && snapshot.data != null) {
                  url = snapshot.data!;
                }
                return SizedBox(
                  height: 140,
                  width: MediaQuery.of(context).size.width * 0.3 - 10,
                  child: InkWell(
                    child: Hero(
                      tag: "imageView",
                      child: Image.network(url),
                    ),
                    onTap: () {
                      showDialog(
                        context: context, 
                        builder: (_) => HeroPhotoViewRouteWrapper(imageProvider: NetworkImage(url))
                      );
                    },
                  ),
                );
              }
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.7 - 10,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Species ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(info.plantType),
                  const Text("Latitude ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("${info.lat}"),
                  const Text("Longitude ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("${info.lng}"),
                  const Text("Extra Info ", style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(info.extraInfo),
                  const Divider()
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  // These are pictures uploaded by user
  Future<String> getPlantPictureDownloadUrl(PlantLocationInfo info) async {

    final storageRef = FirebaseStorage.instance.ref().child("userUploads");

    var plantImage = storageRef.child(info.imageUri);

    var url = await plantImage.getDownloadURL();

    return (url.isEmpty) ? "https://www.nicepng.com/png/detail/73-730825_pot-plant-clipart-potted-plant-pot-plant-icon.png" : url;
  }
}
class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
  });

  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: imageProvider,
        backgroundDecoration: backgroundDecoration,
        minScale: minScale,
        maxScale: maxScale,
        heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
      ),
    );
  }
}
