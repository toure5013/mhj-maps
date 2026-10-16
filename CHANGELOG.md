# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Google Maps style import** — new `GoogleMapStyle` model (`GoogleMapStyle.fromJson`)
  that parses Google Maps Styling Wizard JSON into `MapColors` + `LayerVisibility`,
  with built-in `GoogleMapStyle.silver()`, `.retro()` and `.dark()` factories.
- New `Silver`, `Retro` and `Dark Classic` presets in `MapStylePresets`.
- New `MhjMapsMapThemes.silver` (CartoDB Positron),
  `MhjMapsMapThemes.retro` (Stamen Terrain) and
  `MhjMapsMapThemes.darkClassic` (CartoDB Dark Matter) raster equivalents.

## [1.2.3] - 2026-04-11

### Changed
- Updated project metadata including homepage, repository links, and documentation URL.
- Refactored icon usage (removed Lucide icons) to improve performance and reduce weight.
- Improved markdown rendering logic in documentation components.
- Updated pathing for relative deployment.

## [1.2.0] - 2026-04-09

### Changed
- **Major Rebranding** — Renamed project from `Navigatr` to `MhjMaps`.
- Updated all service implementations and internal references to reflect the new name.

### Added
- Launched premium documentation site.

## [1.1.0] - 2026-04-07

### Added
- **Enhanced Markers** — Support for image and SVG markers.
- **Advanced Controls** — Expanded `MhjMapsMapController` with circle overlays and advanced camera controls.
- **New Themes** — Added 6 new premium map themes.
- **Expanded Providers** — Support for more tile providers and custom tile URLs.
- Introduced configurable default styles for markers and polylines.

### Fixed
- Improved null safety and API response parsing in `MhjMapsService`.
- Added User-Agent headers to API requests to comply with usage policies.

## [1.0.0] - 2026-04-04

### Added

- **MhjMapsMap Widget** — High-performance, customizable map widget powered by `flutter_map`.
  - `theme` parameter — Apply a complete visual theme in one line.
  - `tileProvider` parameter — Switch between 13+ free tile providers.
  - `onTap` / `onLongPress` — Tap and long-press callbacks with coordinates.
  - `onCameraMove` — Real-time camera position updates.
  - `showZoomControls` — Built-in zoom in/out overlay.
  - `additionalLayers` — Add custom layers on top of the map.
  - `minZoom` / `maxZoom` / `rotation` — Full camera control.

- **MhjMapsMapController** — Programmatic map control.
  - `addMarker()` / `addCustomMarker()` — Standard and custom widget markers.
  - `drawRoute()` / `drawDashedRoute()` — Solid and dashed polylines with borders.
  - `addCircle()` — Circle overlays for radius visualization.
  - `fitRoute()` / `fitMarkers()` — Auto-fit camera to content.
  - `zoomIn()` / `zoomOut()` / `rotateTo()` / `resetRotation()` — Camera methods.
  - `clearAll()` — Remove all overlays at once.

- **13 Built-in Map Themes** (`MhjMapsMapThemes`)
  - Light: `standard`, `cleanLight`, `voyager`, `blankCanvas`, `professional`, `whisper`
  - Dark: `darkElegant`, `darkSilent`
  - Specialty: `topographic`, `cycling`, `humanitarianMap`, `satellite`, `terrain`

- **13 Tile Providers** (`MhjMapsTileProvider`)
  - OpenStreetMap, CartoDB (Positron, Dark Matter, Voyager, No Labels variants),
    OpenTopoMap, CyclOSM, Humanitarian HOT, Esri (Street, Imagery, Topo, Light Gray)
  - `MhjMapsTileProvider.custom()` factory for any tile URL.

- **Routing** — Turn-by-turn routing via Valhalla.
  - Support for `auto`, `bicycle`, `pedestrian` costing modes.
  - Polyline decoding (precision 6).
  - Maneuver parsing with instructions.

- **Geocoding** — Forward and reverse geocoding via Nominatim.

- **Autocomplete** — Address suggestions via Photon.

- **Utilities**
  - `MhjMapsFormat.duration()` / `MhjMapsFormat.distance()` — Human-readable formatting.
  - `MhjMapsPolyline.decode()` — Encoded polyline decoder.

- **Models**
  - `MhjMapsLatLng`, `MhjMapsConfig`, `RouteResult`, `GeocodeResult`,
    `AutocompleteResult`, `Maneuver`, `MapStyle`, `MhjMapsMapOptions`,
    `MhjMapsBounds`, `MhjMapsInteractiveFlags`.
