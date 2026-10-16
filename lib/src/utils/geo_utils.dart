import '../models/lat_lng.dart';

/// Geo-calculations powered by `latlong2`.
///
/// Exposed so apps don't need to depend on `latlong2` directly:
///
/// ```dart
/// final total = MhjMapsGeo.totalDistance(polyline); // meters
/// final center = MhjMapsGeo.center(points);
/// ```
class MhjMapsGeo {
  const MhjMapsGeo._();

  /// Total length of a polyline in meters.
  static double totalDistance(List<MhjMapsLatLng> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (var i = 1; i < points.length; i++) {
      total += points[i - 1].distanceTo(points[i]);
    }
    return total;
  }

  /// Geographic center (average) of [points].
  static MhjMapsLatLng? center(List<MhjMapsLatLng> points) {
    if (points.isEmpty) return null;
    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.lat;
      lng += p.lng;
    }
    return MhjMapsLatLng(lat: lat / points.length, lng: lng / points.length);
  }

  /// Bounding box of [points] as (southWest, northEast).
  static (MhjMapsLatLng, MhjMapsLatLng)? bounds(List<MhjMapsLatLng> points) {
    if (points.isEmpty) return null;
    double minLat = points.first.lat,
        maxLat = points.first.lat,
        minLng = points.first.lng,
        maxLng = points.first.lng;
    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    return (
      MhjMapsLatLng(lat: minLat, lng: minLng),
      MhjMapsLatLng(lat: maxLat, lng: maxLng),
    );
  }

  /// Closest point in [points] to [target]. Returns null if empty.
  static MhjMapsLatLng? closestPoint(
      MhjMapsLatLng target, List<MhjMapsLatLng> points) {
    if (points.isEmpty) return null;
    MhjMapsLatLng best = points.first;
    double bestD = target.distanceTo(best);
    for (var i = 1; i < points.length; i++) {
      final d = target.distanceTo(points[i]);
      if (d < bestD) {
        bestD = d;
        best = points[i];
      }
    }
    return best;
  }

  /// Simplifies a polyline with radial-distance filtering.
  ///
  /// Keeps first/last points, drops intermediate points closer than
  /// [toleranceMeters] to the last kept point. Fast O(n), ideal before
  /// drawing long Valhalla shapes.
  static List<MhjMapsLatLng> simplify(
    List<MhjMapsLatLng> points, {
    double toleranceMeters = 5.0,
  }) {
    if (points.length <= 2) return List.of(points);
    final kept = <MhjMapsLatLng>[points.first];
    for (var i = 1; i < points.length - 1; i++) {
      if (kept.last.distanceTo(points[i]) >= toleranceMeters) {
        kept.add(points[i]);
      }
    }
    kept.add(points.last);
    return kept;
  }

  /// Interpolates [steps] points between [a] and [b] (inclusive).
  static List<MhjMapsLatLng> interpolate(
    MhjMapsLatLng a,
    MhjMapsLatLng b, {
    int steps = 10,
  }) {
    if (steps <= 1) return [a, b];
    return List.generate(steps + 1, (i) => a.lerp(b, i / steps));
  }
}
