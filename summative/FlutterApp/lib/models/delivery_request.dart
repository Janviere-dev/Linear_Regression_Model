/// The 8 values our deployed API's /predict endpoint needs mirrors
/// the Pydantic `DeliveryPredictionRequest` schema in summative/API/schemas.py.
class DeliveryRequest {
  final int age;
  final double rating;
  final double restaurantLat;
  final double restaurantLon;
  final double deliveryLat;
  final double deliveryLon;
  final String typeOfOrder;
  final String typeOfVehicle;

  const DeliveryRequest({
    required this.age,
    required this.rating,
    required this.restaurantLat,
    required this.restaurantLon,
    required this.deliveryLat,
    required this.deliveryLon,
    required this.typeOfOrder,
    required this.typeOfVehicle,
  });

  Map<String, dynamic> toJson() => {
        'delivery_person_age': age,
        'delivery_person_ratings': rating,
        'restaurant_latitude': restaurantLat,
        'restaurant_longitude': restaurantLon,
        'delivery_latitude': deliveryLat,
        'delivery_longitude': deliveryLon,
        'type_of_order': typeOfOrder,
        'type_of_vehicle': typeOfVehicle,
      };
}
