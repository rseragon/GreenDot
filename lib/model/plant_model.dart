class PlantLocationInfo {

  // lat lng
  double lat;
  double lng;
  String extraInfo = "";
  String plantType = "";
  String userEmail = "";

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
