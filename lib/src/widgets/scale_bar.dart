import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Scale bar overlay (additional layer widget).
///
/// Computes metric scale from [zoom] + [latitude]:
/// `metersPerPixel = 156543.03392 * cos(lat) / 2^zoom`.
class MhjMapsScaleBar extends StatelessWidget {
  final double zoom;
  final double latitude;
  final bool isDark;
  final double maxWidth;

  const MhjMapsScaleBar({
    super.key,
    required this.zoom,
    required this.latitude,
    this.isDark = false,
    this.maxWidth = 120,
  });

  (double widthPx, String label) _scale() {
    final metersPerPx =
        156543.03392 * math.cos(latitude * math.pi / 180) / math.pow(2, zoom);
    const candidates = [5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000];
    double best = candidates.first.toDouble();
    for (final c in candidates) {
      final w = c / metersPerPx;
      if (w <= maxWidth) {
        best = c.toDouble();
      } else {
        break;
      }
    }
    final label = best >= 1000
        ? '${(best / 1000).toStringAsFixed(best % 1000 == 0 ? 0 : 1)} km'
        : '${best.toInt()} m';
    return (best / metersPerPx, label);
  }

  @override
  Widget build(BuildContext context) {
    final (w, label) = _scale();
    final color = isDark ? Colors.white70 : Colors.black87;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Container(
            width: w.clamp(20.0, maxWidth),
            height: 4,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: color, width: 2),
                right: BorderSide(color: color, width: 2),
                bottom: BorderSide(color: color, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
