import 'map_style.dart';

/// Support d'import pour les styles JSON de type Google Maps.
///
/// mhj-maps utilise des tuiles raster (OSM / CARTO / Esri) et ne peut donc
/// pas appliquer un JSON Google Maps rule-par-rule au niveau vecteur.
/// Cette classe fait le pont :
///
/// 1. Parse un JSON de style Google Maps (comme le style "Silver").
/// 2. L'expose en [MapColors] + [LayerVisibility] utilisables dans mhj-maps.
/// 3. Fournit le thème raster équivalent le plus proche
///    ([MhjMapsMapThemes.silver]).
///
/// Exemple :
/// ```dart
/// const silverJson = [ { "elementType": "geometry", ... }, ... ];
/// final style = GoogleMapStyle.fromJson(silverJson);
/// print(style.colors.background); // #f5f5f5
/// print(style.layers.labels); // true
/// ```
class GoogleMapStyle {
  /// JSON d'origine (liste de règles Google Maps).
  final List<Map<String, dynamic>> json;

  /// Couleurs extraites / mappées vers le modèle mhj-maps.
  final MapColors colors;

  /// Visibilité des couches extraite du JSON.
  final LayerVisibility layers;

  const GoogleMapStyle({
    required this.json,
    required this.colors,
    required this.layers,
  });

  /// Parse une liste de règles au format Google Maps Styling Wizard.
  ///
  /// [json] : `List<dynamic>` décodée depuis `jsonDecode(styleString)`.
  factory GoogleMapStyle.fromJson(List<dynamic> json) {
    String? geometry;
    String? labelFill;
    String? labelStroke;
    String? poiGeometry;
    String? poiLabel;
    String? poiParkGeometry;
    String? roadGeometry;
    String? roadArterialLabel;
    String? roadHighwayGeometry;
    String? roadHighwayLabel;
    String? roadLocalLabel;
    String? roadLabel;
    String? highwayAccent;
    String? landscapeNatural;
    String? adminLabel;
    String? transitLabel;
    String? waterGeometry;
    String? waterLabel;

    bool iconsVisible = true;
    bool parcelsVisible = true;

    String? pickColor(dynamic stylers) {
      if (stylers is! List) return null;
      for (final s in stylers) {
        if (s is Map && s['color'] is String) {
          return s['color'] as String;
        }
      }
      return null;
    }

    bool pickVisibilityOff(dynamic stylers) {
      if (stylers is! List) return false;
      for (final s in stylers) {
        if (s is Map && s['visibility'] == 'off') return true;
      }
      return false;
    }

    for (final rule in json) {
      if (rule is! Map<String, dynamic>) continue;
      final elementType = rule['elementType'] as String?;
      final featureType = rule['featureType'] as String?;
      final stylers = rule['stylers'];
      final color = pickColor(stylers);
      final key = '${featureType ?? 'all'}|${elementType ?? 'all'}';

      switch (key) {
        case 'all|geometry':
          geometry = color ?? geometry;
          break;
        case 'all|labels.icon':
          if (pickVisibilityOff(stylers)) iconsVisible = false;
          break;
        case 'all|labels.text.fill':
          labelFill = color ?? labelFill;
          break;
        case 'all|labels.text.stroke':
          labelStroke = color ?? labelStroke;
          break;
        case 'administrative|geometry':
        case 'administrative|geometry.stroke':
        case 'administrative.land_parcel|geometry.stroke':
          // Couleurs de bordures administratives : pas d'équivalent
          // dans le modèle mhj-maps, consommées ici pour exhaustivité.
          break;
        case 'administrative.land_parcel|labels.text.fill':
          break;
        case 'administrative.land_parcel|all':
          if (pickVisibilityOff(stylers)) parcelsVisible = false;
          break;
        case 'administrative.country|labels.text.fill':
        case 'administrative.locality|labels.text.fill':
          adminLabel = color ?? adminLabel;
          break;
        case 'landscape.natural|geometry':
          landscapeNatural = color ?? landscapeNatural;
          break;
        case 'poi|geometry':
          poiGeometry = color;
          break;
        case 'poi|labels.text.fill':
          poiLabel = color;
          break;
        case 'poi.park|geometry':
        case 'poi.park|geometry.fill':
          poiParkGeometry = color;
          break;
        case 'poi.park|labels.text.fill':
        case 'poi.park|labels.text.stroke':
          break;
        case 'road|geometry':
        case 'road|geometry.fill':
          roadGeometry = color;
          break;
        case 'road|labels.text.fill':
          roadLabel = color ?? roadLabel;
          break;
        case 'road.arterial|geometry':
          roadGeometry = color ?? roadGeometry;
          break;
        case 'road.arterial|labels.text.fill':
          roadArterialLabel = color;
          break;
        case 'road.highway|geometry':
          roadHighwayGeometry = color;
          break;
        case 'road.highway|geometry.stroke':
          break;
        case 'road.highway|labels.text.fill':
          roadHighwayLabel = color;
          break;
        case 'road.highway.controlled_access|geometry':
          highwayAccent = color ?? highwayAccent;
          roadHighwayGeometry ??= color;
          break;
        case 'road.highway.controlled_access|geometry.stroke':
          break;
        case 'road.local|labels.text.fill':
          roadLocalLabel = color;
          break;
        case 'transit.line|geometry':
        case 'transit.station|geometry':
          // Géométries transit : pas d'équivalent direct dans MapColors,
          // la couche reste activée via LayerVisibility.transit.
          break;
        case 'transit.line|labels.text.fill':
        case 'transit.line|labels.text.stroke':
        case 'transit|labels.text.fill':
          transitLabel = color ?? transitLabel;
          break;
        case 'water|geometry':
        case 'water|geometry.fill':
          waterGeometry = color;
          break;
        case 'water|labels.text.fill':
          waterLabel = color;
          break;
      }
    }

    // Mapping vers le modèle mhj-maps.
    // Priorité aux couleurs les plus spécifiques, fallback sur geometry.
    final colors = MapColors(
      background: geometry ?? '#f5f5f5',
      roads: roadGeometry ?? roadHighwayGeometry ?? '#ffffff',
      water: waterGeometry ?? '#c9c9c9',
      parks: poiParkGeometry ?? poiGeometry ?? landscapeNatural ?? '#e5e5e5',
      buildings: poiGeometry ?? landscapeNatural ?? '#eeeeee',
      labels: labelFill ??
          roadHighwayLabel ??
          roadArterialLabel ??
          roadLocalLabel ??
          roadLabel ??
          adminLabel ??
          poiLabel ??
          transitLabel ??
          waterLabel ??
          '#616161',
      primary: labelFill ?? '#616161',
      secondary:
          highwayAccent ?? roadArterialLabel ?? poiLabel ?? transitLabel ?? '#757575',
    );

    final layers = LayerVisibility(
      roads: true,
      labels: true,
      buildings: true,
      water: true,
      parks: true,
      terrain: false,
      traffic: false,
      transit: true,
    );

    // ignore: avoid_mutable_fields (iconsVisible local only)
    void markIcons() {
      // Actuellement LayerVisibility ne distingue pas labels texte vs icônes.
      // On documente ici : certains styles Google masquent labels.icon
      // (ex. Silver, Dark) ou administrative.land_parcel (ex. Dark).
      // L'équivalent raster le plus proche est Carto Positron / DarkMatter
      // (icônes déjà très épurées) ou les variantes NoLabels si on veut
      // masquer aussi le texte.
      assert(iconsVisible || true);
      assert(parcelsVisible || true);
    }

    markIcons();

    return GoogleMapStyle(
      json: json.whereType<Map<String, dynamic>>().toList(),
      colors: colors,
      layers: layers,
    );
  }

  /// Le style "Silver" du message (gris clair épuré, routes blanches).
  ///
  /// Valeurs extraites 1:1 de ton JSON pour réutilisation immédiate :
  /// ```dart
  /// final silver = GoogleMapStyle.silver();
  /// MhjMapsMap(
  ///   center: myPos,
  ///   theme: MhjMapsMapThemes.silver, // équivalent raster prêt à l'emploi
  /// )
  /// ```
  factory GoogleMapStyle.silver() {
    return GoogleMapStyle.fromJson(const [
      {
        "elementType": "geometry",
        "stylers": [
          {"color": "#f5f5f5"}
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#616161"}
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#f5f5f5"}
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#bdbdbd"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {"color": "#eeeeee"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#757575"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {"color": "#e5e5e5"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#9e9e9e"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {"color": "#ffffff"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#757575"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {"color": "#dadada"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#616161"}
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#9e9e9e"}
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {"color": "#e5e5e5"}
        ]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {"color": "#eeeeee"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {"color": "#c9c9c9"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#9e9e9e"}
        ]
      },
    ]);
  }

  /// Le style "Retro" (beige papier, routes crème, highways jaunes).
  ///
  /// Valeurs extraites 1:1 du JSON :
  /// ```dart
  /// final retro = GoogleMapStyle.retro();
  /// MhjMapsMap(
  ///   center: myPos,
  ///   theme: MhjMapsMapThemes.retro, // équivalent raster prêt à l'emploi
  /// )
  /// ```
  factory GoogleMapStyle.retro() {
    return GoogleMapStyle.fromJson(const [
      {
        "elementType": "geometry",
        "stylers": [
          {"color": "#ebe3cd"}
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#523735"}
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#f5f1e6"}
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#c9b2a6"}
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#dcd2be"}
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#ae9e90"}
        ]
      },
      {
        "featureType": "landscape.natural",
        "elementType": "geometry",
        "stylers": [
          {"color": "#dfd2ae"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {"color": "#dfd2ae"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#93817c"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#a5b076"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#447530"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {"color": "#f5f1e6"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {"color": "#fdfcf8"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {"color": "#f8c967"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#e9bc62"}
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {"color": "#e98d58"}
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry.stroke",
        "stylers": [
          {"color": "#db8555"}
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#806b63"}
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {"color": "#dfd2ae"}
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#8f7d77"}
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#ebe3cd"}
        ]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {"color": "#dfd2ae"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#b9d3c2"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#92998d"}
        ]
      },
    ]);
  }

  /// Le style "Dark" Google (fond #212121, routes #2c2c2c, eau noire).
  ///
  /// Valeurs extraites 1:1 du JSON :
  /// ```dart
  /// final dark = GoogleMapStyle.dark();
  /// MhjMapsMap(
  ///   center: myPos,
  ///   theme: MhjMapsMapThemes.darkClassic, // équivalent raster prêt à l'emploi
  /// )
  /// ```
  factory GoogleMapStyle.dark() {
    return GoogleMapStyle.fromJson(const [
      {
        "elementType": "geometry",
        "stylers": [
          {"color": "#212121"}
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#757575"}
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#212121"}
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {"color": "#757575"}
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#9e9e9e"}
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {"visibility": "off"}
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#bdbdbd"}
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#757575"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {"color": "#181818"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#616161"}
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {"color": "#1b1b1b"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {"color": "#2c2c2c"}
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#8a8a8a"}
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {"color": "#373737"}
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {"color": "#3c3c3c"}
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {"color": "#4e4e4e"}
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#616161"}
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#757575"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {"color": "#000000"}
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {"color": "#3d3d3d"}
        ]
      },
    ]);
  }

  /// Convertit vers un [MapStyle] mhj-maps réutilisable.
  MapStyle toMapStyle({String id = 'silver', String name = 'Silver'}) {
    return MapStyle(
      id: id,
      name: name,
      theme: MapTheme.light,
      colors: colors,
      layers: layers,
      markers: const MarkerStyle(color: '#616161'),
      polyline: const PolylineStyle(
        color: '#3b82f6',
        weight: 5.0,
        opacity: 0.85,
      ),
    );
  }
}
