library mhj_maps;

// Models
export 'src/models/lat_lng.dart';
export 'src/models/route_result.dart';
export 'src/models/geocode_result.dart';
export 'src/models/autocomplete_result.dart';
export 'src/models/maneuver.dart';
export 'src/models/mhj_maps_config.dart';
export 'src/models/map_style.dart';
export 'src/models/google_map_style.dart';
export 'src/models/map_style_presets.dart';
export 'src/models/tile_provider.dart';
export 'src/models/map_theme.dart';
export 'src/models/map_options.dart';

// Services
export 'src/services/mhj_maps_service.dart';
export 'src/services/location_service.dart';

// Widgets
export 'src/widgets/mhj_maps_map.dart';
export 'src/widgets/mhj_maps_view.dart';
export 'src/widgets/mhj_maps_search_field.dart';
export 'src/widgets/route_panel.dart';
export 'src/widgets/scale_bar.dart';

// Utilities
export 'src/utils/format_utils.dart';
export 'src/utils/polyline_decoder.dart';
export 'src/utils/geo_utils.dart';

import 'src/services/mhj_maps_service.dart';
import 'src/models/mhj_maps_config.dart';

/// The main entry point for the MhjMaps SDK.
///
/// Provides geocoding, routing, and autocomplete services using free
/// OpenStreetMap infrastructure — zero API keys, zero cost.
///
/// ```dart
/// final nav = MhjMaps();
///
/// // Geocode
/// final result = await nav.geocode('Paris, France');
///
/// // Route
/// final route = await nav.route(
///   origin: MhjMapsLatLng(lat: 48.85, lng: 2.35),
///   destination: MhjMapsLatLng(lat: 45.76, lng: 4.83),
/// );
///
/// // Autocomplete
/// final suggestions = await nav.autocomplete('Par');
/// ```
class MhjMaps extends MhjMapsService {
  MhjMaps({super.config = const MhjMapsConfig()});
}
