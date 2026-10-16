import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lat_lng.dart';
import '../models/route_result.dart';
import '../models/geocode_result.dart';
import '../models/autocomplete_result.dart';
import '../models/maneuver.dart';
import '../models/mhj_maps_config.dart';
import '../utils/polyline_decoder.dart';
import '../utils/format_utils.dart';

/// Costing profiles supported by Valhalla.
class MhjMapsCosting {
  static const String auto = 'auto';
  static const String bicycle = 'bicycle';
  static const String pedestrian = 'pedestrian';
  static const String motorcycle = 'motorcycle';
  static const String truck = 'truck';

  static const List<String> all = [auto, bicycle, pedestrian, motorcycle, truck];
}

class MhjMapsService {
  final MhjMapsConfig config;

  MhjMapsService({this.config = const MhjMapsConfig()});

  static const _ua = 'mhj_maps-flutter/2.0';

  // ─── Simple in-memory cache (respects free-tier usage) ──────────────
  final Map<String, GeocodeResult> _geocodeCache = {};
  final Map<String, RouteResult> _routeCache = {};
  DateTime _lastNominatimCall = DateTime.fromMillisecondsSinceEpoch(0);

  /// Throttles Nominatim to max 1 req/sec (usage policy).
  Future<void> _throttleNominatim() async {
    final elapsed =
        DateTime.now().difference(_lastNominatimCall).inMilliseconds;
    if (elapsed < 1100) {
      await Future.delayed(Duration(milliseconds: 1100 - elapsed));
    }
    _lastNominatimCall = DateTime.now();
  }

  /// Clears in-memory caches.
  void clearCache() {
    _geocodeCache.clear();
    _routeCache.clear();
  }

  String _routeKey(
    MhjMapsLatLng origin,
    MhjMapsLatLng dest,
    List<MhjMapsLatLng> via,
    String costing,
  ) =>
      '${origin.lat},${origin.lng}|${via.map((e) => '${e.lat},${e.lng}').join(';')}|${dest.lat},${dest.lng}|$costing';

  // ─── Routing ────────────────────────────────────────────────────────

  /// Turn-by-turn route from [origin] to [destination].
  ///
  /// - [via]: optional intermediate waypoints (Valhalla `through`).
  /// - [costing]: see [MhjMapsCosting] (`auto`, `bicycle`, `pedestrian`…).
  /// - [alternates]: number of alternate routes requested (0-2).
  Future<RouteResult> route({
    required MhjMapsLatLng origin,
    required MhjMapsLatLng destination,
    List<MhjMapsLatLng> via = const [],
    String costing = MhjMapsCosting.auto,
    int alternates = 0,
    bool useCache = true,
  }) async {
    final key = _routeKey(origin, destination, via, costing);
    if (useCache && alternates == 0 && _routeCache.containsKey(key)) {
      return _routeCache[key]!;
    }

    final locations = <Map<String, dynamic>>[
      {'lat': origin.lat, 'lon': origin.lng, 'type': 'break'},
      for (final w in via)
        {'lat': w.lat, 'lon': w.lng, 'type': 'through'},
      {'lat': destination.lat, 'lon': destination.lng, 'type': 'break'},
    ];

    final body = <String, dynamic>{
      'locations': locations,
      'costing': costing,
      'directions_options': {'units': 'km'},
      if (alternates > 0) 'alternates': alternates.clamp(0, 2),
    };

    final response = await http.post(
      Uri.parse('${config.valhallaUrl}/route'),
      headers: {'Content-Type': 'application/json', 'User-Agent': _ua},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Route request failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final trip = data['trip'];
    final result = _parseTrip(trip);

    // Parse alternate routes if Valhalla returned them.
    List<AlternateRoute>? altRoutes;
    final alts = trip['alternates'] as List?;
    if (alts != null && alts.isNotEmpty) {
      altRoutes = alts.map((a) {
        final s = a['summary'] ?? {};
        final shape = (a['legs']?[0]?['shape'] as String?) ?? '';
        final km = (s['length'] as num?)?.toDouble() ?? 0.0;
        final secs = (s['time'] as num?)?.toInt() ?? 0;
        final meters = (km * 1000).round();
        return AlternateRoute(
          durationSeconds: secs,
          durationText: MhjMapsFormat.duration(secs),
          distanceMeters: meters,
          distanceText: MhjMapsFormat.distance(meters),
          polyline: MhjMapsPolyline.decode(shape),
        );
      }).toList();
    }

    final full = RouteResult(
      durationSeconds: result.durationSeconds,
      durationText: result.durationText,
      distanceMeters: result.distanceMeters,
      distanceText: result.distanceText,
      polyline: result.polyline,
      maneuvers: result.maneuvers,
      alternates: altRoutes,
    );

    if (useCache && alternates == 0) _routeCache[key] = full;
    return full;
  }

  RouteResult _parseTrip(dynamic trip) {
    final summary = trip['summary'];
    final shape = trip['legs'][0]['shape'] as String? ?? '';

    final polyline = MhjMapsPolyline.decode(shape);
    final int durationSeconds = (summary['time'] as num?)?.toInt() ?? 0;
    final double distanceKm = (summary['length'] as num?)?.toDouble() ?? 0.0;
    final int distanceMeters = (distanceKm * 1000).round();

    List<Maneuver>? maneuvers;
    if (trip['legs'][0]['maneuvers'] != null) {
      maneuvers = (trip['legs'][0]['maneuvers'] as List).map((m) {
        final double mLon = (m['lon'] as num?)?.toDouble() ?? 0.0;
        final double mLat = (m['lat'] as num?)?.toDouble() ?? 0.0;
        final double lenKm = (m['length'] as num?)?.toDouble() ?? 0.0;
        final int lenM = (lenKm * 1000).round();
        final int time = (m['time'] as num?)?.toInt() ?? 0;
        return Maneuver(
          instruction: m['instruction'] ?? '',
          type: (m['type'] as int?)?.toString() ?? '0',
          distanceMeters: lenM,
          distanceText: MhjMapsFormat.distance(lenM),
          durationSeconds: time,
          durationText: MhjMapsFormat.duration(time),
          startPoint: MhjMapsLatLng(lat: mLat, lng: mLon),
        );
      }).toList();
    }

    return RouteResult(
      durationSeconds: durationSeconds,
      durationText: MhjMapsFormat.duration(durationSeconds),
      distanceMeters: distanceMeters,
      distanceText: MhjMapsFormat.distance(distanceMeters),
      polyline: polyline,
      maneuvers: maneuvers,
    );
  }

  /// Route distance/duration matrix (N×M) via Valhalla `sources_to_targets`.
  ///
  /// Useful for "closest store" / delivery use-cases.
  Future<List<List<double>>> distanceMatrix({
    required List<MhjMapsLatLng> sources,
    required List<MhjMapsLatLng> targets,
    String costing = MhjMapsCosting.auto,
  }) async {
    final response = await http.post(
      Uri.parse('${config.valhallaUrl}/sources_to_targets'),
      headers: {'Content-Type': 'application/json', 'User-Agent': _ua},
      body: jsonEncode({
        'sources': [
          for (final s in sources) {'lat': s.lat, 'lon': s.lng}
        ],
        'targets': [
          for (final t in targets) {'lat': t.lat, 'lon': t.lng}
        ],
        'costing': costing,
        'directions_options': {'units': 'km'},
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Matrix request failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    final matrix = (data['sources_to_targets'] as List);
    return [
      for (final row in matrix)
        [
          for (final cell in (row as List))
            ((cell['time'] as num?)?.toDouble() ?? -1.0),
        ],
    ];
  }

  // ─── Geocoding ──────────────────────────────────────────────────────

  Future<GeocodeResult> geocode(String address,
      {bool useCache = true}) async {
    final key = address.trim().toLowerCase();
    if (useCache && _geocodeCache.containsKey(key)) {
      return _geocodeCache[key]!;
    }
    await _throttleNominatim();
    final response = await http.get(
      Uri.parse(
          '${config.nominatimUrl}/search?q=${Uri.encodeComponent(address)}&format=json&limit=1'),
      headers: {'User-Agent': _ua},
    );

    if (response.statusCode != 200) {
      throw Exception('Geocoding request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List || data.isEmpty) {
      throw Exception('No geocoding results found for address: $address');
    }

    final result = data[0];
    final out = GeocodeResult(
      lat: double.parse(result['lat']),
      lng: double.parse(result['lon']),
      displayName: result['display_name'] ?? '',
    );
    if (useCache) _geocodeCache[key] = out;
    return out;
  }

  Future<GeocodeResult> reverseGeocode(double lat, double lng) async {
    await _throttleNominatim();
    final response = await http.get(
      Uri.parse('${config.nominatimUrl}/reverse?lat=$lat&lon=$lng&format=json'),
      headers: {'User-Agent': _ua},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Reverse geocoding request failed: ${response.statusCode}');
    }

    final result = jsonDecode(response.body);
    return GeocodeResult(
      lat: lat,
      lng: lng,
      displayName: result['display_name'] ?? '',
    );
  }

  Future<List<AutocompleteResult>> autocomplete(String query,
      {int limit = 5}) async {
    if (query.trim().isEmpty) return [];
    final response = await http.get(
      Uri.parse(
          '${config.photonUrl}/api?q=${Uri.encodeComponent(query)}&limit=$limit'),
      headers: {'User-Agent': _ua},
    );

    if (response.statusCode != 200) {
      throw Exception('Autocomplete request failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> features = data['features'] ?? [];

    return features.map((f) {
      final props = f['properties'];
      final coords = f['geometry']['coordinates'];

      return AutocompleteResult(
        lat: (coords[1] as num?)?.toDouble() ?? 0.0,
        lng: (coords[0] as num?)?.toDouble() ?? 0.0,
        name: props['name'] ?? '',
        displayName: [
          props['name'],
          props['street'],
          props['city'] ?? props['town'] ?? props['village'],
          props['state'],
          props['country']
        ].where((e) => e != null).join(', '),
        city: props['city'] ?? props['town'] ?? props['village'],
        state: props['state'],
        country: props['country'],
        street: props['street'],
        postcode: props['postcode'],
      );
    }).toList();
  }
}
