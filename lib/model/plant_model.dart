class PlantLocationInfo {

  // lat lng
  double lat;
  double lng;
  String extraInfo = "";
  String plantType = ""; // This is the scientific name of the plant
  String userEmail = "";
  String imageUri = ""; // This will be processed while getting data

  PlantLocationInfo(this.lat, this.lng, this.plantType, this.userEmail, this.extraInfo);
}

class PlantDetails {
  String name;
  String scientificName;
  String info;

  PlantDetails(this.name, this.scientificName, this.info);
}

class PlantType {
  String plantName;
  int count = 0;

  PlantType(this.plantName, this.count);
}
