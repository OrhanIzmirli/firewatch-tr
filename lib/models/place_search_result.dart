/// One neighbourhood or address found through the backend's Nominatim proxy.
class PlaceSearchResult {
  /// Short name for the form: "Zeytinalanı".
  final String name;

  /// Full line for the list: "Zeytinalanı, Urla, İzmir".
  final String label;
  final double latitude;
  final double longitude;

  const PlaceSearchResult({
    required this.name,
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) => PlaceSearchResult(
        name: json['name'] as String,
        label: json['label'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}
