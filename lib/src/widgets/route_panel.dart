import 'package:flutter/material.dart';
import '../models/route_result.dart';
import '../services/mhj_maps_service.dart';

/// Route summary + turn-by-turn panel (additional layer widget).
///
/// Shows duration/distance, costing switcher and maneuvers list:
///
/// ```dart
/// MhjMapsRoutePanel(
///   route: route,
///   costing: 'auto',
///   onCostingChanged: (c) => _recalc(c),
/// )
/// ```
class MhjMapsRoutePanel extends StatelessWidget {
  final RouteResult? route;
  final bool isLoading;
  final String costing;
  final ValueChanged<String>? onCostingChanged;
  final VoidCallback? onClose;
  final bool showManeuvers;
  final bool isDark;

  const MhjMapsRoutePanel({
    super.key,
    this.route,
    this.isLoading = false,
    this.costing = MhjMapsCosting.auto,
    this.onCostingChanged,
    this.onClose,
    this.showManeuvers = true,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final fg = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white60 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: kElevationToShadow[8],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sub.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (route == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Choose origin & destination to plan a route.',
                  style: TextStyle(color: sub, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route!.durationText,
                            style: TextStyle(
                                color: fg,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text(route!.distanceText,
                            style: TextStyle(color: sub, fontSize: 14)),
                      ],
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: Icon(Icons.close, color: sub),
                      onPressed: onClose,
                    ),
                ],
              ),
              if (onCostingChanged != null) ...[
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: MhjMapsCosting.auto,
                        icon: Icon(Icons.directions_car, size: 16),
                        label: Text('Auto')),
                    ButtonSegment(
                        value: MhjMapsCosting.bicycle,
                        icon: Icon(Icons.directions_bike, size: 16),
                        label: Text('Bike')),
                    ButtonSegment(
                        value: MhjMapsCosting.pedestrian,
                        icon: Icon(Icons.directions_walk, size: 16),
                        label: Text('Walk')),
                  ],
                  selected: {costing},
                  onSelectionChanged: (s) => onCostingChanged!(s.first),
                ),
              ],
              if (showManeuvers &&
                  route!.maneuvers != null &&
                  route!.maneuvers!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: route!.maneuvers!.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = route!.maneuvers![i];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 14,
                          child: Text('${i + 1}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                        title: Text(m.instruction,
                            style:
                                TextStyle(color: fg, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        trailing: Text(m.distanceText,
                            style: TextStyle(color: sub, fontSize: 11)),
                      );
                    },
                  ),
                ),
              ],
              if (route!.alternates != null &&
                  route!.alternates!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${route!.alternates!.length} alternate(s) available',
                  style: TextStyle(color: sub, fontSize: 11),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
