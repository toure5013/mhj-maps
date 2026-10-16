import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/lat_lng.dart';
import '../models/tile_provider.dart';
import '../models/map_theme.dart';
import '../models/map_options.dart';
import '../services/location_service.dart';
import 'scale_bar.dart';

/// Controller to interact with a [MhjMapsMap] widget programmatically.
///
/// Obtained via the [MhjMapsMap.onMapCreated] callback.
///
/// ```dart
/// MhjMapsMapController? _controller;
///
/// MhjMapsMap(
///   center: MhjMapsLatLng(lat: 48.85, lng: 2.35),
///   onMapCreated: (controller) => _controller = controller,
/// )
///
/// // Later:
/// _controller?.addMarker(position: myPos, label: 'Hello');
/// _controller?.drawRoute(myPolyline, color: Colors.green);
/// ```
class MhjMapsMapController {
  late final MapController _mapController;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  final List<CircleMarker> _circles = [];
  final Function() _onUpdate;

  Marker? _userMarker;
  CircleMarker? _accuracyCircle;

  /// Default color for markers if none is specified.
  Color defaultMarkerColor = const Color(0xFF3b82f6);

  /// Default color for polylines if none is specified.
  Color defaultPolylineColor = const Color(0xFF00FF94);

  /// Default size for markers.
  double defaultMarkerSize = 40.0;

  /// Default width for polylines.
  double defaultPolylineStrokeWidth = 4.0;

  MhjMapsMapController({
    required Function() onUpdate,
  }) : _onUpdate = onUpdate {
    _mapController = MapController();
  }

  /// The underlying [MapController] for advanced use cases.
  MapController get mapController => _mapController;

  // ─── Markers ────────────────────────────────────────────────────────

  /// Adds a marker at the given position.
  void addMarker({
    required MhjMapsLatLng position,
    Widget? icon,
    String? label,
    double? width,
    double? height,
    Alignment alignment = Alignment.topCenter,
  }) {
    final w = width ?? defaultMarkerSize;
    final h = height ?? defaultMarkerSize;
    _markers.add(
      Marker(
        point: LatLng(position.lat, position.lng),
        width: w,
        height: h,
        alignment: alignment,
        child: icon ??
            Icon(Icons.location_on, color: defaultMarkerColor, size: w),
      ),
    );
    _onUpdate();
  }

  /// Adds a theme-aware marker at the given position.
  void addThemeMarker({
    required MhjMapsLatLng position,
    String? label,
  }) {
    addMarker(position: position, label: label);
  }

  /// Adds a custom widget marker at the given position.
  void addCustomMarker({
    required MhjMapsLatLng position,
    required Widget child,
    double width = 80,
    double height = 80,
    Alignment alignment = Alignment.topCenter,
  }) {
    _markers.add(
      Marker(
        point: LatLng(position.lat, position.lng),
        width: width,
        height: height,
        alignment: alignment,
        child: child,
      ),
    );
    _onUpdate();
  }

  /// Adds a marker using a local PNG/JPG asset or network URL.
  void addImageMarker({
    required MhjMapsLatLng position,
    required String imagePath,
    bool isNetwork = false,
    double width = 40,
    double height = 40,
    Alignment alignment = Alignment.center,
    BoxFit fit = BoxFit.contain,
  }) {
    final imageWidget = isNetwork
        ? Image.network(imagePath, width: width, height: height, fit: fit)
        : Image.asset(imagePath, width: width, height: height, fit: fit);

    addCustomMarker(
      position: position,
      width: width,
      height: height,
      alignment: alignment,
      child: imageWidget,
    );
  }

  /// Adds a marker using an SVG (local asset or network).
  void addSvgMarker({
    required MhjMapsLatLng position,
    required String svgPath,
    bool isNetwork = false,
    Color? color,
    double width = 40,
    double height = 40,
    Alignment alignment = Alignment.center,
  }) {
    final svgFilter =
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null;

    final svgWidget = isNetwork
        ? SvgPicture.network(
            svgPath,
            width: width,
            height: height,
            colorFilter: svgFilter,
          )
        : SvgPicture.asset(
            svgPath,
            width: width,
            height: height,
            colorFilter: svgFilter,
          );

    addCustomMarker(
      position: position,
      width: width,
      height: height,
      alignment: alignment,
      child: svgWidget,
    );
  }

  /// Removes all markers from the map.
  void clearMarkers() {
    _markers.clear();
    _onUpdate();
  }

  /// Returns the current number of markers.
  int get markerCount => _markers.length;

  /// Read-only markers (for persistence across rebuilds).
  List<Marker> get markers => List.unmodifiable(_markers);

  // ─── Routes / Polylines ─────────────────────────────────────────────

  /// Draws a route polyline on the map.
  void drawRoute(
    List<MhjMapsLatLng> polyline, {
    Color? color,
    double? width,
    bool isDotted = false,
    Color? borderColor,
    double borderWidth = 0,
  }) {
    _polylines.add(
      Polyline(
        points: polyline.map((e) => LatLng(e.lat, e.lng)).toList(),
        color: color ?? defaultPolylineColor,
        strokeWidth: width ?? defaultPolylineStrokeWidth,
        isDotted: isDotted,
        borderColor: borderColor ?? Colors.transparent,
        borderStrokeWidth: borderWidth,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
    );
    _onUpdate();
  }

  /// Draws a dashed route for walking / alternative routes.
  void drawDashedRoute(
    List<MhjMapsLatLng> polyline, {
    Color color = const Color(0xFF94a3b8),
    double width = 3.0,
  }) {
    drawRoute(polyline, color: color, width: width, isDotted: true);
  }

  /// Removes all polylines from the map.
  void clearRoute() {
    _polylines.clear();
    _onUpdate();
  }

  /// Read-only polylines.
  List<Polyline> get polylines => List.unmodifiable(_polylines);

  // ─── Circles ────────────────────────────────────────────────────────

  /// Adds a circle overlay on the map.
  void addCircle({
    required MhjMapsLatLng center,
    required double radiusMeters,
    Color color = const Color(0x303b82f6),
    Color borderColor = const Color(0xFF3b82f6),
    double borderWidth = 2,
  }) {
    _circles.add(
      CircleMarker(
        point: LatLng(center.lat, center.lng),
        radius: radiusMeters,
        useRadiusInMeter: true,
        color: color,
        borderColor: borderColor,
        borderStrokeWidth: borderWidth,
      ),
    );
    _onUpdate();
  }

  /// Removes all circles from the map.
  void clearCircles() {
    _circles.clear();
    _onUpdate();
  }

  // ─── User location ──────────────────────────────────────────────────

  /// Shows/updates the blue-dot user location + accuracy circle.
  void updateUserLocation(
    MhjMapsLatLng position, {
    double accuracyMeters = 20,
    double? headingDegrees,
    Widget? marker,
    Color accuracyColor = const Color(0xFF3b82f6),
  }) {
    _accuracyCircle = CircleMarker(
      point: LatLng(position.lat, position.lng),
      radius: accuracyMeters,
      useRadiusInMeter: true,
      color: accuracyColor.withValues(alpha: 0.15),
      borderColor: accuracyColor.withValues(alpha: 0.5),
      borderStrokeWidth: 1.5,
    );
    Widget dot = marker ??
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: accuracyColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: accuracyColor.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        );
    if (headingDegrees != null) {
      dot = Transform.rotate(
        angle: headingDegrees * (3.1415926535 / 180),
        child: dot,
      );
    }
    _userMarker = Marker(
      point: LatLng(position.lat, position.lng),
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: dot,
    );
    _onUpdate();
  }

  /// Hides the user location dot.
  void clearUserLocation() {
    _userMarker = null;
    _accuracyCircle = null;
    _onUpdate();
  }

  // ─── Camera Controls ────────────────────────────────────────────────

  /// Fits the camera so the given polyline fits inside the viewport.
  void fitRoute(
    List<MhjMapsLatLng> polyline, {
    EdgeInsets padding = const EdgeInsets.all(50.0),
  }) {
    if (polyline.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      polyline.map((e) => LatLng(e.lat, e.lng)).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: padding,
      ),
    );
  }

  /// Fits the map to show all current markers.
  void fitMarkers({EdgeInsets padding = const EdgeInsets.all(50.0)}) {
    if (_markers.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      _markers.map((m) => m.point).toList(),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: padding,
      ),
    );
  }

  /// Moves the camera to a specific position.
  void moveTo(MhjMapsLatLng position, {double zoom = 13.0}) {
    _mapController.move(LatLng(position.lat, position.lng), zoom);
  }

  /// Animated move (simple two-step: move keeps flutter_map animation).
  void animateTo(MhjMapsLatLng position, {double? zoom}) {
    final z = zoom ?? _mapController.camera.zoom;
    _mapController.move(LatLng(position.lat, position.lng), z);
  }

  /// Zooms in by one level.
  void zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  /// Zooms out by one level.
  void zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  /// Rotates the map to the given angle in degrees.
  void rotateTo(double degrees) {
    _mapController.rotate(degrees);
  }

  /// Resets the map rotation to north.
  void resetRotation() {
    _mapController.rotate(0);
  }

  /// Current zoom level.
  double get currentZoom {
    try {
      return _mapController.camera.zoom;
    } catch (_) {
      return 13.0;
    }
  }

  /// Current center of the map.
  MhjMapsLatLng get currentCenter {
    try {
      return MhjMapsLatLng(
        lat: _mapController.camera.center.latitude,
        lng: _mapController.camera.center.longitude,
      );
    } catch (_) {
      return const MhjMapsLatLng(lat: 0, lng: 0);
    }
  }

  // ─── Bulk Operations ────────────────────────────────────────────────

  /// Clears all overlays (markers, polylines, circles).
  void clearAll() {
    _markers.clear();
    _polylines.clear();
    _circles.clear();
    _onUpdate();
  }
}

/// A high-performance, customizable map widget powered by OpenStreetMap.
///
/// ## Basic Usage
/// ```dart
/// MhjMapsMap(
///   center: MhjMapsLatLng(lat: 48.8566, lng: 2.3522),
///   zoom: 13,
/// )
/// ```
///
/// ## With live user location + follow
/// ```dart
/// MhjMapsMap(
///   center: paris,
///   showUserLocation: true,
///   followUser: true,
///   showLocationButton: true,
///   showScale: true,
///   onLocationUpdate: (pos) => print(pos),
/// )
/// ```
class MhjMapsMap extends StatefulWidget {
  /// Initial center of the map.
  final MhjMapsLatLng center;

  /// Initial zoom level (default: 13.0).
  final double zoom;

  /// Minimum zoom level (default: 1.0).
  final double minZoom;

  /// Maximum zoom level (default: 19.0).
  final double maxZoom;

  /// Initial rotation in degrees.
  final double rotation;

  /// Tile URL template. Overridden by [tileProvider] or [theme].
  final String? tileUrl;

  /// Attribution text. Overridden by [tileProvider] or [theme].
  final String? attribution;

  /// A tile provider configuration. Takes priority over [tileUrl].
  final MhjMapsTileProvider? tileProvider;

  /// A complete theme combining tiles + styling. Takes highest priority.
  final MhjMapsMapTheme? theme;

  /// Whether to show zoom controls overlay.
  final bool showZoomControls;

  /// Whether to show attribution.
  final bool showAttribution;

  /// Whether to show a compass.
  final bool showCompass;

  /// Whether to show a scale bar.
  final bool showScale;

  /// Whether to show the user's location (requires location permissions).
  final bool showUserLocation;

  /// When true, camera follows the user on every GPS fix.
  final bool followUser;

  /// Whether to show a "locate me" floating button.
  final bool showLocationButton;

  /// Custom user-location dot. Defaults to a blue dot.
  final Widget? userMarker;

  /// Color of the accuracy circle + default dot.
  final Color accuracyColor;

  /// Whether the map is interactive (scroll/zoom).
  final bool interactive;

  /// Gesture flags (see [MhjMapsInteractiveFlags]). Ignored if !interactive.
  final int interactiveFlags;

  /// Constrains the camera center inside these bounds.
  final MhjMapsBounds? maxBounds;

  /// Whether to use large zoom buttons.
  final bool useLargeZoomButtons;

  /// Background color behind tiles.
  final Color? backgroundColor;

  /// Default stroke width for polylines.
  final double defaultPolylineStrokeWidth;

  /// Default size for markers.
  final double defaultMarkerSize;

  /// Callback when the map is created and the controller is ready.
  final Function(MhjMapsMapController controller)? onMapCreated;

  /// Callback when the user taps on the map.
  final Function(MhjMapsLatLng position)? onTap;

  /// Callback when the user long-presses on the map.
  final Function(MhjMapsLatLng position)? onLongPress;

  /// Callback when the camera position changes.
  final Function(MhjMapsLatLng center, double zoom)? onCameraMove;

  /// Callback on every GPS fix when location is enabled.
  final Function(MhjMapsLatLng position)? onLocationUpdate;

  /// Additional layers to render on top of the map.
  final List<Widget>? additionalLayers;

  const MhjMapsMap({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.minZoom = 1.0,
    this.maxZoom = 19.0,
    this.rotation = 0.0,
    this.tileUrl,
    this.attribution,
    this.tileProvider,
    this.theme,
    this.showZoomControls = false,
    this.showAttribution = true,
    this.showCompass = false,
    this.showScale = false,
    this.showUserLocation = false,
    this.followUser = false,
    this.showLocationButton = false,
    this.userMarker,
    this.accuracyColor = const Color(0xFF3b82f6),
    this.interactive = true,
    this.interactiveFlags = MhjMapsInteractiveFlags.all,
    this.maxBounds,
    this.useLargeZoomButtons = false,
    this.backgroundColor = const Color(0xFFE8E8E8),
    this.defaultPolylineStrokeWidth = 4.0,
    this.defaultMarkerSize = 40.0,
    this.onMapCreated,
    this.onTap,
    this.onLongPress,
    this.onCameraMove,
    this.onLocationUpdate,
    this.additionalLayers,
  });

  @override
  State<MhjMapsMap> createState() => _MhjMapsMapState();
}

class _MhjMapsMapState extends State<MhjMapsMap> {
  late MhjMapsMapController _controller;
  MhjMapsLocationService? _locationService;
  StreamSubscription<MhjMapsLocationData>? _locationSub;
  double _currentZoom = 13;
  MhjMapsLatLng _currentCenter = const MhjMapsLatLng(lat: 0, lng: 0);
  bool _following = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.zoom;
    _currentCenter = widget.center;
    _following = widget.followUser;
    _controller = MhjMapsMapController(onUpdate: () {
      if (mounted) setState(() {});
    });

    // Defer onMapCreated to avoid build-time setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyThemeDefaults();
      widget.onMapCreated?.call(_controller);
      if (widget.showUserLocation || widget.followUser) _startLocation();
    });
  }

  @override
  void didUpdateWidget(covariant MhjMapsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _applyThemeDefaults();
    }
    if (widget.followUser != oldWidget.followUser) {
      _following = widget.followUser;
    }
    final needLoc = widget.showUserLocation || widget.followUser;
    final hadLoc = oldWidget.showUserLocation || oldWidget.followUser;
    if (needLoc && !hadLoc) {
      _startLocation();
    } else if (!needLoc && hadLoc) {
      _stopLocation();
      _controller.clearUserLocation();
    }
  }

  @override
  void dispose() {
    _stopLocation();
    _locationService?.dispose();
    super.dispose();
  }

  void _applyThemeDefaults() {
    if (widget.theme != null) {
      _controller.defaultPolylineColor = _hexToColor(widget.theme!.polylineColor);
      _controller.defaultMarkerColor = _hexToColor(widget.theme!.markerColor);
    }
    _controller.defaultPolylineStrokeWidth = widget.defaultPolylineStrokeWidth;
    _controller.defaultMarkerSize = widget.defaultMarkerSize;
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _startLocation() async {
    _locationService ??= MhjMapsLocationService();
    final ok = await _locationService!.requestPermission();
    if (!ok || !mounted) return;
    final current = await _locationService!.getCurrentPosition();
    if (current != null && mounted) _onFix(current);
    await _locationSub?.cancel();
    await _locationService!.startTracking();
    _locationSub = _locationService!.stream.listen(_onFix);
  }

  Future<void> _stopLocation() async {
    await _locationSub?.cancel();
    _locationSub = null;
    await _locationService?.stopTracking();
  }

  void _onFix(MhjMapsLocationData fix) {
    if (!mounted) return;
    _controller.updateUserLocation(
      fix.position,
      accuracyMeters: fix.accuracyMeters,
      headingDegrees: fix.headingDegrees,
      marker: widget.userMarker,
      accuracyColor: widget.accuracyColor,
    );
    widget.onLocationUpdate?.call(fix.position);
    if (_following && mounted) {
      _controller.animateTo(fix.position);
    }
  }

  Future<void> _locateMe() async {
    setState(() => _locating = true);
    _locationService ??= MhjMapsLocationService();
    final fix = await _locationService!.getCurrentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (fix == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Location unavailable')),
      );
      return;
    }
    _onFix(fix);
    // Enable follow until user drags manually (unless forced by prop).
    setState(() => _following = true);
    _controller.moveTo(fix.position, zoom: _currentZoom < 14 ? 16 : _currentZoom);
    if (!widget.showUserLocation) {
      // Keep tracking so the dot stays live after "locate me".
      await _locationSub?.cancel();
      await _locationService!.startTracking();
      _locationSub = _locationService!.stream.listen(_onFix);
    }
  }

  // Resolve the tile configuration from theme > tileProvider > tileUrl > default
  String get _resolvedTileUrl {
    if (widget.theme != null) return widget.theme!.tileProvider.urlTemplate;
    if (widget.tileProvider != null) return widget.tileProvider!.urlTemplate;
    return widget.tileUrl ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  String get _resolvedAttribution {
    if (widget.theme != null) return widget.theme!.tileProvider.attribution;
    if (widget.tileProvider != null) return widget.tileProvider!.attribution;
    return widget.attribution ?? '© OpenStreetMap contributors';
  }

  List<String> get _resolvedSubdomains {
    if (widget.theme != null) return widget.theme!.tileProvider.subdomains;
    if (widget.tileProvider != null) return widget.tileProvider!.subdomains;
    return const [];
  }

  int get _resolvedMaxZoom {
    if (widget.theme != null) return widget.theme!.tileProvider.maxZoom;
    if (widget.tileProvider != null) return widget.tileProvider!.maxZoom;
    return 19;
  }

  CameraConstraint? get _cameraConstraint {
    final b = widget.maxBounds;
    if (b == null) return null;
    return CameraConstraint.containCenter(
      bounds: LatLngBounds(
        LatLng(b.southWest.lat, b.southWest.lng),
        LatLng(b.northEast.lat, b.northEast.lng),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme?.isDark ?? false;
    final userMarkers = <Marker>[
      if (_controller._userMarker != null) _controller._userMarker!,
    ];
    final accuracyCircles = <CircleMarker>[
      if (_controller._accuracyCircle != null) _controller._accuracyCircle!,
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller._mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.center.lat, widget.center.lng),
            initialZoom: widget.zoom,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            initialRotation: widget.rotation,
            interactionOptions: InteractionOptions(
              flags: widget.interactive
                  ? widget.interactiveFlags
                  : MhjMapsInteractiveFlags.none,
            ),
            cameraConstraint: _cameraConstraint ?? const CameraConstraint.unconstrained(),
            backgroundColor: widget.backgroundColor ??
                (isDark ? const Color(0xFF1a1a2e) : const Color(0xFFE8E8E8)),
            onTap: widget.onTap != null
                ? (tapPosition, point) {
                    widget.onTap!(MhjMapsLatLng(
                      lat: point.latitude,
                      lng: point.longitude,
                    ));
                  }
                : null,
            onLongPress: widget.onLongPress != null
                ? (tapPosition, point) {
                    widget.onLongPress!(MhjMapsLatLng(
                      lat: point.latitude,
                      lng: point.longitude,
                    ));
                  }
                : null,
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture && !widget.followUser) {
                // Manual drag breaks temporary follow (locate-me mode).
                if (_following) setState(() => _following = false);
              }
              try {
                final zoom = camera.zoom;
                if (zoom != null) _currentZoom = zoom;
                final center = camera.center;
                if (center != null) {
                  _currentCenter = MhjMapsLatLng(
                    lat: center.latitude,
                    lng: center.longitude,
                  );
                }
              } catch (_) {}
              if (mounted &&
                  (widget.onCameraMove != null || widget.showScale)) {
                setState(() {});
              }
              widget.onCameraMove?.call(_currentCenter, _currentZoom);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _resolvedTileUrl,
              userAgentPackageName: 'dev.mhj_maps.flutter',
              subdomains: _resolvedSubdomains,
              maxZoom: _resolvedMaxZoom.toDouble(),
            ),
            CircleLayer(circles: [
              ..._controller._circles,
              ...accuracyCircles,
            ]),
            PolylineLayer(polylines: _controller._polylines),
            MarkerLayer(markers: [
              ..._controller._markers,
              ...userMarkers,
            ]),
            if (widget.additionalLayers != null) ...widget.additionalLayers!,
            if (widget.showAttribution && _resolvedAttribution.isNotEmpty)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    _resolvedAttribution,
                    onTap: () {},
                  ),
                ],
              ),
          ],
        ),
        // Zoom controls overlay
        if (widget.showZoomControls)
          Positioned(
            right: 16,
            bottom: widget.showAttribution ? 40 : 16,
            child: Column(
              children: [
                _ZoomButton(
                  icon: Icons.add,
                  onPressed: _controller.zoomIn,
                  isDark: isDark,
                  large: widget.useLargeZoomButtons,
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: Icons.remove,
                  onPressed: _controller.zoomOut,
                  isDark: isDark,
                  large: widget.useLargeZoomButtons,
                ),
              ],
            ),
          ),
        // Compass
        if (widget.showCompass)
          Positioned(
            left: 16,
            top: 16,
            child: _CompassButton(
              onPressed: _controller.resetRotation,
              isDark: isDark,
            ),
          ),
        // Scale bar
        if (widget.showScale)
          Positioned(
            left: 12,
            bottom: widget.showAttribution ? 32 : 12,
            child: MhjMapsScaleBar(
              zoom: _currentZoom,
              latitude: _currentCenter.lat,
              isDark: isDark,
            ),
          ),
        // Locate-me button
        if (widget.showLocationButton)
          Positioned(
            right: 16,
            bottom: widget.showZoomControls
                ? (widget.showAttribution ? 150 : 126)
                : (widget.showAttribution ? 40 : 16),
            child: _LocateButton(
              isDark: isDark,
              locating: _locating,
              following: _following || widget.followUser,
              onPressed: _locateMe,
            ),
          ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;
  final bool large;

  const _ZoomButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = large ? 56.0 : 40.0;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(large ? 12 : 8),
      color: isDark ? const Color(0xFF2a2a3e) : Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: large ? 28 : 20,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _CompassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _CompassButton({
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: isDark ? const Color(0xFF2a2a3e) : Colors.white,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.explore,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _LocateButton extends StatelessWidget {
  final bool isDark;
  final bool locating;
  final bool following;
  final VoidCallback onPressed;

  const _LocateButton({
    required this.isDark,
    required this.locating,
    required this.following,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: following
          ? const Color(0xFF3b82f6)
          : (isDark ? const Color(0xFF2a2a3e) : Colors.white),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: locating
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  following ? Icons.my_location : Icons.location_searching,
                  size: 22,
                  color: following
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
        ),
      ),
    );
  }
}
