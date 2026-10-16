import 'package:flutter/material.dart';
import '../models/autocomplete_result.dart';
import '../models/lat_lng.dart';
import '../models/map_theme.dart';
import '../models/route_result.dart';
import '../models/tile_provider.dart';
import '../services/mhj_maps_service.dart';
import '../services/location_service.dart';
import 'mhj_maps_map.dart';
import 'mhj_maps_search_field.dart';
import 'route_panel.dart';

/// Unified all-in-one map component.
///
/// Combines `flutter_map` rendering + `latlong2` geo-math + `free_map`
/// ideas (`FmMap` + `FmSearchField` + polylines) + live location tracking
/// + Valhalla route planning in a single widget:
///
/// ```dart
/// MhjMapsView(
///   initialCenter: MhjMapsLatLng(lat: 48.8566, lng: 2.3522),
///   theme: MhjMapsMapThemes.darkElegant,
///   showSearchBar: true,
///   showRoutePanel: true,
/// )
/// ```
///
/// For full custom control, use [MhjMapsMap] + [MhjMapsSearchField] +
/// [MhjMapsRoutePanel] separately.
class MhjMapsView extends StatefulWidget {
  final MhjMapsLatLng initialCenter;
  final double initialZoom;
  final MhjMapsMapTheme? theme;
  final MhjMapsTileProvider? tileProvider;
  final MhjMapsService? service;

  /// Show origin/destination search bar overlay.
  final bool showSearchBar;

  /// Show bottom route summary / maneuvers panel.
  final bool showRoutePanel;

  /// Show live user location dot.
  final bool showUserLocation;

  /// Camera follows GPS.
  final bool followUser;

  final bool showLocationButton;
  final bool showZoomControls;
  final bool showCompass;
  final bool showScale;

  /// Tapping the map sets destination (and recalculates if origin known).
  final bool tapToSetDestination;

  /// Prefill origin with GPS on startup.
  final bool useGpsAsOrigin;

  final String costing;
  final String originHint;
  final String destinationHint;

  final ValueChanged<RouteResult>? onRouteCalculated;
  final ValueChanged<MhjMapsMapController>? onMapCreated;
  final ValueChanged<MhjMapsLatLng>? onLocationUpdate;

  const MhjMapsView({
    super.key,
    required this.initialCenter,
    this.initialZoom = 13,
    this.theme,
    this.tileProvider,
    this.service,
    this.showSearchBar = true,
    this.showRoutePanel = true,
    this.showUserLocation = true,
    this.followUser = false,
    this.showLocationButton = true,
    this.showZoomControls = true,
    this.showCompass = false,
    this.showScale = true,
    this.tapToSetDestination = true,
    this.useGpsAsOrigin = false,
    this.costing = MhjMapsCosting.auto,
    this.originHint = 'Origin',
    this.destinationHint = 'Destination',
    this.onRouteCalculated,
    this.onMapCreated,
    this.onLocationUpdate,
  });

  @override
  State<MhjMapsView> createState() => _MhjMapsViewState();
}

class _MhjMapsViewState extends State<MhjMapsView> {
  late final MhjMapsService _service;
  MhjMapsMapController? _controller;
  AutocompleteResult? _origin;
  AutocompleteResult? _destination;
  MhjMapsLatLng? _gpsPosition;
  bool _loading = false;
  RouteResult? _route;
  String _costing = MhjMapsCosting.auto;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MhjMapsService();
    _costing = widget.costing;
    if (widget.useGpsAsOrigin) _fillGpsOrigin();
  }

  Future<void> _fillGpsOrigin() async {
    final loc = MhjMapsLocationService();
    final fix = await loc.getCurrentPosition();
    loc.dispose();
    if (fix == null || !mounted) return;
    setState(() => _gpsPosition = fix.position);
    try {
      final placemark =
          await _service.reverseGeocode(fix.position.lat, fix.position.lng);
      if (!mounted) return;
      setState(() {
        _origin = AutocompleteResult(
          lat: fix.position.lat,
          lng: fix.position.lng,
          name: 'My location',
          displayName: placemark.displayName,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _origin = AutocompleteResult(
          lat: fix.position.lat,
          lng: fix.position.lng,
          name: 'My location',
          displayName:
              'My location (${fix.position.lat.toStringAsFixed(4)}, ${fix.position.lng.toStringAsFixed(4)})',
        );
      });
    }
  }

  MhjMapsLatLng? get _originLatLng => _origin == null
      ? _gpsPosition
      : MhjMapsLatLng(lat: _origin!.lat, lng: _origin!.lng);

  MhjMapsLatLng? get _destLatLng => _destination == null
      ? null
      : MhjMapsLatLng(lat: _destination!.lat, lng: _destination!.lng);

  Future<void> calculateRoute() async {
    final o = _originLatLng;
    final d = _destLatLng;
    if (o == null || d == null) {
      setState(() => _error = 'Set origin and destination first.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final route = await _service.route(
        origin: o,
        destination: d,
        costing: _costing,
        alternates: 2,
      );
      if (!mounted) return;
      setState(() {
        _route = route;
        _loading = false;
      });
      _redraw(o, d, route);
      widget.onRouteCalculated?.call(route);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _redraw(MhjMapsLatLng o, MhjMapsLatLng d, RouteResult route) {
    final c = _controller;
    if (c == null) return;
    c.clearAll();
    c.addMarker(
      position: o,
      icon: const Icon(Icons.my_location, color: Colors.blue, size: 36),
    );
    c.addMarker(
      position: d,
      icon: const Icon(Icons.location_on, color: Colors.red, size: 40),
    );
    // Alternates first (grey dashed), main route on top.
    for (final alt in route.alternates ?? []) {
      c.drawDashedRoute(alt.polyline);
    }
    c.drawRoute(route.polyline, width: 5);
    c.fitRoute(route.polyline);
  }

  void _onMapTap(MhjMapsLatLng pos) async {
    if (!widget.tapToSetDestination) return;
    setState(() {
      _destination = AutocompleteResult(
        lat: pos.lat,
        lng: pos.lng,
        name: 'Pinned location',
        displayName:
            'Pinned (${pos.lat.toStringAsFixed(4)}, ${pos.lng.toStringAsFixed(4)})',
      );
    });
    // Try reverse-geocoding for a nicer label (non-blocking).
    try {
      final r = await _service.reverseGeocode(pos.lat, pos.lng);
      if (!mounted) return;
      setState(() {
        _destination = AutocompleteResult(
          lat: pos.lat,
          lng: pos.lng,
          name: r.displayName.split(',').first,
          displayName: r.displayName,
        );
      });
    } catch (_) {}
    if (_originLatLng != null) await calculateRoute();
  }

  void _clearRoute() {
    setState(() {
      _route = null;
      _destination = null;
      _error = null;
    });
    _controller?.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme?.isDark ?? true;
    return Stack(
      children: [
        MhjMapsMap(
          center: widget.initialCenter,
          zoom: widget.initialZoom,
          theme: widget.theme,
          tileProvider: widget.tileProvider,
          showZoomControls: widget.showZoomControls,
          showCompass: widget.showCompass,
          showScale: widget.showScale,
          showUserLocation: widget.showUserLocation,
          followUser: widget.followUser,
          showLocationButton: widget.showLocationButton,
          onMapCreated: (c) {
            _controller = c;
            widget.onMapCreated?.call(c);
          },
          onTap: _onMapTap,
          onLocationUpdate: (pos) {
            _gpsPosition = pos;
            widget.onLocationUpdate?.call(pos);
          },
        ),
        if (widget.showSearchBar)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white)
                      .withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: kElevationToShadow[4],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MhjMapsSearchField(
                      service: _service,
                      hintText: widget.originHint,
                      onSelected: (p) {
                        setState(() => _origin = p);
                        if (_destination != null) calculateRoute();
                      },
                    ),
                    const SizedBox(height: 6),
                    MhjMapsSearchField(
                      service: _service,
                      hintText: widget.destinationHint,
                      onSelected: (p) {
                        setState(() => _destination = p);
                        calculateRoute();
                      },
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.showRoutePanel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: (_route != null || _loading)
                    ? MhjMapsRoutePanel(
                        route: _route,
                        isLoading: _loading,
                        costing: _costing,
                        isDark: isDark,
                        onCostingChanged: (c) {
                          setState(() => _costing = c);
                          calculateRoute();
                        },
                        onClose: _clearRoute,
                      )
                    : SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: (_originLatLng != null &&
                                  _destLatLng != null &&
                                  !_loading)
                              ? calculateRoute
                              : null,
                          icon: const Icon(Icons.directions, size: 20),
                          label: const Text('GET DIRECTIONS',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
