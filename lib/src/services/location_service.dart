import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/lat_lng.dart';

/// User position with accuracy info.
class MhjMapsLocationData {
  final MhjMapsLatLng position;
  final double accuracyMeters;
  final double? headingDegrees;
  final double? speedMps;
  final DateTime timestamp;

  const MhjMapsLocationData({
    required this.position,
    required this.accuracyMeters,
    this.headingDegrees,
    this.speedMps,
    required this.timestamp,
  });

  factory MhjMapsLocationData.fromPosition(Position p) =>
      MhjMapsLocationData(
        position: MhjMapsLatLng(lat: p.latitude, lng: p.longitude),
        accuracyMeters: p.accuracy,
        headingDegrees: p.heading,
        speedMps: p.speed,
        timestamp: p.timestamp,
      );
}

/// Location tracking powered by `geolocator`.
///
/// Handles permission requests + position stream + follow logic:
///
/// ```dart
/// final loc = MhjMapsLocationService();
/// final ok = await loc.requestPermission();
/// loc.track().listen((fix) => print(fix.position));
/// ```
class MhjMapsLocationService {
  StreamSubscription<Position>? _sub;
  MhjMapsLocationData? _last;
  final _controller = StreamController<MhjMapsLocationData>.broadcast();

  /// Last known fix (null until first fix).
  MhjMapsLocationData? get lastLocation => _last;

  /// Broadcast stream of location fixes.
  Stream<MhjMapsLocationData> get stream => _controller.stream;

  /// `true` while actively tracking.
  bool get isTracking => _sub != null;

  /// Checks + requests location permission. Returns true if granted.
  Future<bool> requestPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  /// Whether permission is currently granted (no prompt).
  Future<bool> hasPermission() async {
    final perm = await Geolocator.checkPermission();
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  /// One-shot current position (requests permission first).
  Future<MhjMapsLocationData?> getCurrentPosition() async {
    try {
      final ok = await requestPermission();
      if (!ok) return null;
      final p = await Geolocator.getCurrentPosition();
      _last = MhjMapsLocationData.fromPosition(p);
      return _last;
    } catch (e) {
      debugPrint('MhjMaps location error: $e');
      return null;
    }
  }

  /// Starts continuous tracking. Safe to call twice (restarts stream).
  Future<bool> startTracking({
    int distanceFilterMeters = 5,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final ok = await requestPermission();
    if (!ok) return false;
    await stopTracking();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (p) {
        _last = MhjMapsLocationData.fromPosition(p);
        if (!_controller.isClosed) _controller.add(_last!);
      },
      onError: (e) => debugPrint('MhjMaps tracking error: $e'),
    );
    return true;
  }

  /// Alias for [startTracking] returning the broadcast stream.
  Stream<MhjMapsLocationData> track({
    int distanceFilterMeters = 5,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    startTracking(
      distanceFilterMeters: distanceFilterMeters,
      accuracy: accuracy,
    );
    return stream;
  }

  Future<void> stopTracking() async {
    await _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    stopTracking();
    _controller.close();
  }
}
