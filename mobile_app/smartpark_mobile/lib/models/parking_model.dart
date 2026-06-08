class ParkingModel {

  final String parkingName;
  final String address;
  final String image;
  final String mapLink;
  final String carPrice;
  final String bikePrice;
  final String carSlots;
  final String bikeSlots;

  ParkingModel({
    required this.parkingName,
    required this.address,
    required this.image,
    required this.mapLink,
    required this.carPrice,
    required this.bikePrice,
    required this.carSlots,
    required this.bikeSlots,
  });

  factory ParkingModel.fromJson(
      Map<String, dynamic> json) {

    return ParkingModel(
      parkingName: json["parking_name"] ?? "",
      address: json["address"] ?? "",
      image: json["image"] ?? "",
      mapLink: json["map_link"] ?? "",
      carPrice: json["car_price"]?.toString() ?? "",
      bikePrice: json["bike_price"]?.toString() ?? "",
      carSlots: json["car_slots"]?.toString() ?? "",
      bikeSlots: json["bike_slots"]?.toString() ?? "",
    );
  }
}