class CropModel {
  final String id;
  final String name;
  final String emoji;
  final String nameSanskrit; // Hindi/local name
  final String imageAsset;

  const CropModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.nameSanskrit,
    required this.imageAsset,
  });
}

class LocationModel {
  final String id;
  final String name;
  final String state;
  final double lat;
  final double lng;

  const LocationModel({
    required this.id,
    required this.name,
    required this.state,
    required this.lat,
    required this.lng,
  });
}
