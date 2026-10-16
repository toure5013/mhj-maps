import 'tile_provider.dart';

/// Pre-built map themes combining tile providers with style configurations.
///
/// Each theme provides a complete, ready-to-use map appearance.
///
/// ```dart
/// MhjMapsMap(
///   center: MhjMapsLatLng(lat: 48.85, lng: 2.35),
///   theme: MhjMapsMapThemes.darkElegant,
/// )
/// ```
class MhjMapsMapThemes {
  MhjMapsMapThemes._();

  // ─── Light Themes ───────────────────────────────────────────────────

  /// Default OSM look — familiar and detailed.
  static const MhjMapsMapTheme standard = MhjMapsMapTheme(
    id: 'standard',
    name: 'Standard',
    description: 'Classic OpenStreetMap style with full details.',
    tileProvider: MhjMapsTileProvider.openStreetMap,
    polylineColor: '#3b82f6',
    markerColor: '#3b82f6',
    isDark: false,
    category: MapThemeCategory.general,
  );

  /// Clean, light cartography — perfect for data overlays.
  static const MhjMapsMapTheme cleanLight = MhjMapsMapTheme(
    id: 'clean_light',
    name: 'Clean Light',
    description: 'Minimalist light basemap ideal for data visualization.',
    tileProvider: MhjMapsTileProvider.cartoPositron,
    polylineColor: '#6366f1',
    markerColor: '#6366f1',
    isDark: false,
    category: MapThemeCategory.minimal,
  );

  /// Colorful and detailed — good for navigation apps.
  static const MhjMapsMapTheme voyager = MhjMapsMapTheme(
    id: 'voyager',
    name: 'Voyager',
    description: 'Colorful, detailed map for exploration and navigation.',
    tileProvider: MhjMapsTileProvider.cartoVoyager,
    polylineColor: '#2563eb',
    markerColor: '#ef4444',
    isDark: false,
    category: MapThemeCategory.navigation,
  );

  /// Clean base without text — great for custom overlays.
  static const MhjMapsMapTheme blankCanvas = MhjMapsMapTheme(
    id: 'blank_canvas',
    name: 'Blank Canvas',
    description: 'No labels, clean canvas for custom overlays.',
    tileProvider: MhjMapsTileProvider.cartoPositronNoLabels,
    polylineColor: '#000000',
    markerColor: '#ef4444',
    isDark: false,
    category: MapThemeCategory.minimal,
  );

  /// Esri professional street map.
  static const MhjMapsMapTheme professional = MhjMapsMapTheme(
    id: 'professional',
    name: 'Professional',
    description: 'Esri World Street Map — professional cartography.',
    tileProvider: MhjMapsTileProvider.esriWorldStreet,
    polylineColor: '#0ea5e9',
    markerColor: '#0ea5e9',
    isDark: false,
    category: MapThemeCategory.general,
  );

  /// Esri light gray — ultra minimal.
  static const MhjMapsMapTheme whisper = MhjMapsMapTheme(
    id: 'whisper',
    name: 'Whisper',
    description: 'Ultra-minimal gray basemap for subtle backgrounds.',
    tileProvider: MhjMapsTileProvider.esriLightGray,
    polylineColor: '#1e293b',
    markerColor: '#e11d48',
    isDark: false,
    category: MapThemeCategory.minimal,
  );

  // ─── Dark Themes ────────────────────────────────────────────────────

  /// Sleek dark map — modern and premium.
  static const MhjMapsMapTheme darkElegant = MhjMapsMapTheme(
    id: 'dark_elegant',
    name: 'Dark Elegant',
    description: 'Premium dark basemap for modern applications.',
    tileProvider: MhjMapsTileProvider.cartoDarkMatter,
    polylineColor: '#00FF94',
    markerColor: '#00FF94',
    isDark: true,
    category: MapThemeCategory.dark,
  );

  /// Dark map without labels.
  static const MhjMapsMapTheme darkSilent = MhjMapsMapTheme(
    id: 'dark_silent',
    name: 'Dark Silent',
    description: 'Dark basemap without labels — sleek and minimal.',
    tileProvider: MhjMapsTileProvider.cartoDarkMatterNoLabels,
    polylineColor: '#818cf8',
    markerColor: '#fbbf24',
    isDark: true,
    category: MapThemeCategory.dark,
  );

  // ─── Specialty Themes ───────────────────────────────────────────────

  /// Topographic — shows elevation and contour lines.
  static const MhjMapsMapTheme topographic = MhjMapsMapTheme(
    id: 'topographic',
    name: 'Topographic',
    description: 'Contour lines and elevation data for outdoor use.',
    tileProvider: MhjMapsTileProvider.openTopoMap,
    polylineColor: '#dc2626',
    markerColor: '#dc2626',
    isDark: false,
    category: MapThemeCategory.outdoor,
  );

  /// Cycling optimized.
  static const MhjMapsMapTheme cycling = MhjMapsMapTheme(
    id: 'cycling',
    name: 'Cycling',
    description: 'Optimized for cyclists with bike lanes and routes.',
    tileProvider: MhjMapsTileProvider.cyclOSM,
    polylineColor: '#16a34a',
    markerColor: '#16a34a',
    isDark: false,
    category: MapThemeCategory.outdoor,
  );

  /// Humanitarian map — emphasis on essential infrastructure.
  static const MhjMapsMapTheme humanitarianMap = MhjMapsMapTheme(
    id: 'humanitarian',
    name: 'Humanitarian',
    description: 'Emphasizes critical infrastructure and humanitarian data.',
    tileProvider: MhjMapsTileProvider.humanitarian,
    polylineColor: '#dc2626',
    markerColor: '#dc2626',
    isDark: false,
    category: MapThemeCategory.general,
  );

  /// Satellite imagery.
  static const MhjMapsMapTheme satellite = MhjMapsMapTheme(
    id: 'satellite',
    name: 'Satellite',
    description: 'High-resolution satellite imagery from Esri.',
    tileProvider: MhjMapsTileProvider.esriWorldImagery,
    polylineColor: '#fbbf24',
    markerColor: '#fbbf24',
    isDark: true,
    category: MapThemeCategory.satellite,
  );

  /// Esri topographic.
  static const MhjMapsMapTheme terrain = MhjMapsMapTheme(
    id: 'terrain',
    name: 'Terrain',
    description: 'Esri topographic map with terrain details.',
    tileProvider: MhjMapsTileProvider.esriWorldTopo,
    polylineColor: '#2563eb',
    markerColor: '#ef4444',
    isDark: false,
    category: MapThemeCategory.outdoor,
  );

  /// High contrast black and white theme.
  static const MhjMapsMapTheme highContrast = MhjMapsMapTheme(
    id: 'high_contrast',
    name: 'High Contrast',
    description: 'B&W theme for maximum readability.',
    tileProvider: MhjMapsTileProvider.stamenToner,
    polylineColor: '#ff0000',
    markerColor: '#000000',
    isDark: false,
    category: MapThemeCategory.monochrome,
  );

  /// Nature-focused theme with green tones.
  static const MhjMapsMapTheme forest = MhjMapsMapTheme(
    id: 'forest',
    name: 'Forest',
    description: 'Emphasis on terrain and natural features.',
    tileProvider: MhjMapsTileProvider.stamenTerrain,
    polylineColor: '#065f46',
    markerColor: '#059669',
    isDark: false,
    category: MapThemeCategory.outdoor,
  );

  /// Wikimedia powered educational map.
  static const MhjMapsMapTheme educational = MhjMapsMapTheme(
    id: 'educational',
    name: 'Educational',
    description: 'Clear, informative map from Wikimedia.',
    tileProvider: MhjMapsTileProvider.wikimedia,
    polylineColor: '#d946ef',
    markerColor: '#a21caf',
    isDark: false,
    category: MapThemeCategory.general,
  );

  /// Specialized cycling map.
  static const MhjMapsMapTheme cyclePro = MhjMapsMapTheme(
    id: 'cycle_pro',
    name: 'Cycle Pro',
    description: 'Advanced cycling routes and topography.',
    tileProvider: MhjMapsTileProvider.openCycleMap,
    polylineColor: '#ea580c',
    markerColor: '#c2410c',
    isDark: false,
    category: MapThemeCategory.outdoor,
  );

  /// Icy/Cold themed map.
  static const MhjMapsMapTheme arctic = MhjMapsMapTheme(
    id: 'arctic',
    name: 'Arctic',
    description: 'Cold, blue-toned map for a fresh look.',
    tileProvider: MhjMapsTileProvider.esriLightGray,
    polylineColor: '#0ea5e9',
    markerColor: '#7dd3fc',
    isDark: false,
    category: MapThemeCategory.minimal,
  );

  /// Silver — équivalent raster du style Google Maps "Silver".
  ///
  /// Reproduit ton JSON : fond #f5f5f5, routes #ffffff, eau #c9c9c9,
  /// parcs #e5e5e5, labels #616161, icônes masquées.
  /// Basé sur CartoDB Positron (le rendu raster le plus proche),
  /// avec itinéraires bleus pour garder le contraste.
  ///
  /// ```dart
  /// MhjMapsMap(
  ///   center: MhjMapsLatLng(lat: 48.85, lng: 2.35),
  ///   theme: MhjMapsMapThemes.silver,
  /// )
  /// ```
  static const MhjMapsMapTheme silver = MhjMapsMapTheme(
    id: 'silver',
    name: 'Silver',
    description: 'Google-style silver: light gray, white roads, muted water.',
    tileProvider: MhjMapsTileProvider.cartoPositron,
    polylineColor: '#3b82f6',
    markerColor: '#616161',
    isDark: false,
    category: MapThemeCategory.minimal,
  );

  /// Retro — équivalent raster du style Google Maps "Retro".
  ///
  /// Fond papier #ebe3cd, routes crème #f5f1e6, highways jaunes #f8c967,
  /// eau #b9d3c2, parcs #a5b076. Basé sur Stamen Terrain
  /// (tons chauds les plus proches en raster), avec itinéraires orange
  /// #e98d58 pour garder le contraste.
  ///
  /// ```dart
  /// MhjMapsMap(
  ///   center: MhjMapsLatLng(lat: 48.85, lng: 2.35),
  ///   theme: MhjMapsMapThemes.retro,
  /// )
  /// ```
  static const MhjMapsMapTheme retro = MhjMapsMapTheme(
    id: 'retro',
    name: 'Retro',
    description: 'Google-style retro: warm paper, cream roads, yellow highways.',
    tileProvider: MhjMapsTileProvider.stamenTerrain,
    polylineColor: '#e98d58',
    markerColor: '#523735',
    isDark: false,
    category: MapThemeCategory.artistic,
  );

  /// Dark Classic — équivalent raster du style Google Maps "Dark".
  ///
  /// Fond #212121, routes #2c2c2c, eau noire #000000, labels #757575,
  /// icônes et parcelles masquées. Basé sur CartoDB Dark Matter
  /// (le rendu raster le plus proche), avec itinéraires gris clair
  /// pour rester lisibles sur fond sombre.
  ///
  /// ```dart
  /// MhjMapsMap(
  ///   center: MhjMapsLatLng(lat: 48.85, lng: 2.35),
  ///   theme: MhjMapsMapThemes.darkClassic,
  /// )
  /// ```
  static const MhjMapsMapTheme darkClassic = MhjMapsMapTheme(
    id: 'dark_classic',
    name: 'Dark Classic',
    description: 'Google-style dark: charcoal map with light gray routes.',
    tileProvider: MhjMapsTileProvider.cartoDarkMatter,
    polylineColor: '#bdbdbd',
    markerColor: '#bdbdbd',
    isDark: true,
    category: MapThemeCategory.dark,
  );

  /// Deep space / neon theme.
  static const MhjMapsMapTheme midnight = MhjMapsMapTheme(
    id: 'midnight',
    name: 'Midnight',
    description: 'Deep black with neon highlights for night driving.',
    tileProvider: MhjMapsTileProvider.cartoDarkMatter,
    polylineColor: '#00ccff',
    markerColor: '#f43f5e',
    isDark: true,
    category: MapThemeCategory.night,
  );

  /// Returns all available built-in themes.
  static List<MhjMapsMapTheme> get all => [
        standard,
        cleanLight,
        silver,
        retro,
        voyager,
        blankCanvas,
        professional,
        whisper,
        darkElegant,
        darkSilent,
        darkClassic,
        topographic,
        cycling,
        humanitarianMap,
        satellite,
        terrain,
        highContrast,
        forest,
        educational,
        cyclePro,
        arctic,
        midnight,
      ];

  /// Returns themes filtered by category.
  static List<MhjMapsMapTheme> byCategory(MapThemeCategory category) =>
      all.where((t) => t.category == category).toList();

  /// Light themes only.
  static List<MhjMapsMapTheme> get light =>
      all.where((t) => !t.isDark).toList();

  /// Dark themes only.
  static List<MhjMapsMapTheme> get dark =>
      all.where((t) => t.isDark).toList();
}

/// A complete map theme combining tiles + styling.
class MhjMapsMapTheme {
  /// Unique identifier.
  final String id;

  /// Human-readable name.
  final String name;

  /// Short description of the theme.
  final String description;

  /// The tile provider (defines the basemap look).
  final MhjMapsTileProvider tileProvider;

  /// Default polyline color (hex string).
  final String polylineColor;

  /// Default marker color (hex string).
  final String markerColor;

  /// Whether the theme is dark.
  final bool isDark;

  /// Category for filtering.
  final MapThemeCategory category;

  const MhjMapsMapTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.tileProvider,
    this.polylineColor = '#3b82f6',
    this.markerColor = '#3b82f6',
    this.isDark = false,
    this.category = MapThemeCategory.general,
  });

  MhjMapsMapTheme copyWith({
    String? id,
    String? name,
    String? description,
    MhjMapsTileProvider? tileProvider,
    String? polylineColor,
    String? markerColor,
    bool? isDark,
    MapThemeCategory? category,
  }) {
    return MhjMapsMapTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tileProvider: tileProvider ?? this.tileProvider,
      polylineColor: polylineColor ?? this.polylineColor,
      markerColor: markerColor ?? this.markerColor,
      isDark: isDark ?? this.isDark,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'MhjMapsMapTheme($name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MhjMapsMapTheme &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Categories for organizing map themes.
enum MapThemeCategory {
  /// General purpose maps.
  general,

  /// Dark-themed maps.
  dark,

  /// Minimal / clean maps for data overlays.
  minimal,

  /// Outdoor / topographic / cycling maps.
  outdoor,

  /// Satellite imagery.
  satellite,

  /// Navigation-oriented maps.
  navigation,

  /// High contrast / B&W maps.
  monochrome,

  /// Artistic / stylized maps.
  artistic,

  /// Optimized for night use.
  night,
}
