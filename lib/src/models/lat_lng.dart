import 'package:latlong2/latlong.dart' as ll;

/// A lightweight latitude/longitude pair used across the MhjMaps SDK.
///
/// Wraps `latlong2` so you get precise geo-calculations without
/// importing a third package in your app:
///
/// ```dart
/// const paris = MhjMapsLatLng(lat: 48.8566, lng: 2.3522);
/// const lyon = MhjMapsLatLng(lat: 45.7640, lng: 4.8357);
///
/// print(paris.distanceTo(lyon)); // meters (double)
/// print(paris.bearingTo(lyon));  // degrees 0-360
/// ```
class MhjMapsLatLng {
  final double lat;
  final double lng;

  const MhjMapsLatLng({
    required this.lat,
    required this.lng,
  });

  static final _distance = ll.Distance();

  /// `true` if lat ∈ [-90, 90] and lng ∈ [-180, 180].
  bool get isValid => lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;

  /// Converts to `latlong2` [LatLng] (for `flutter_map` layers).
  ll.LatLng get toLatLng => ll.LatLng(lat, lng);

  /// Builds from a `latlong2` [LatLng].
  factory MhjMapsLatLng.fromLatLng(ll.LatLng p) =>
      MhjMapsLatLng(lat: p.latitude, lng: p.longitude);

  /// Distance in meters to [other] (WGS84, via `latlong2`).
  double distanceTo(MhjMapsLatLng other) =>
      _distance(toLatLng, other.toLatLng).toDouble();

  /// Initial bearing in degrees (0-360) towards [other].
  double bearingTo(MhjMapsLatLng other) =>
      _distance.bearing(toLatLng, other.toLatLng).toDouble();

  /// Destination point [distanceMeters] away on [bearingDegrees].
  MhjMapsLatLng destinationPoint(double distanceMeters, double bearingDegrees) {
    final p = _distance.offset(toLatLng, distanceMeters, bearingDegrees);
    return MhjMapsLatLng(lat: p.latitude, lng: p.longitude);
  }

  /// Linear interpolation towards [other] (`t` in 0..1).
  MhjMapsLatLng lerp(MhjMapsLatLng other, double t) {
    final c = t.clamp(0.0, 1.0);
    return MhjMapsLatLng(
      lat: lat + (other.lat - lat) * c,
      lng: lng + (other.lng - lng) * c,
    );
  }

  /// Approximate equality within [toleranceMeters].
  bool isAlmostEqual(MhjMapsLatLng other, {double toleranceMeters = 1.0}) =>
      distanceTo(other) <= toleranceMeters;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  factory MhjMapsLatLng.fromJson(Map<String, dynamic> json) {
    return MhjMapsLatLng(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'MhjMapsLatLng(lat: $lat, lng: $lng)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MhjMapsLatLng &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}
