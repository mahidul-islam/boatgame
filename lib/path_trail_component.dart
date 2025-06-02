import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart' show Canvas, Paint, Path, Offset, Colors;

class PathTrailComponent extends Component {
  final List<Offset> _trailPoints = [];
  // Faint gray line for the trail
  final Paint _trailPaint = BasicPalette.gray.withAlpha(180).paint()
    ..strokeWidth = 2.0;
  static const int maxTrailPoints =
      150; // Limit number of points for performance

  void addPoint(Vector2 point) {
    _trailPoints.add(point.toOffset());
    if (_trailPoints.length > maxTrailPoints) {
      _trailPoints.removeAt(0); // Remove oldest point
    }
  }

  void clear() {
    _trailPoints.clear();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_trailPoints.length > 1) {
      final path = Path();
      path.moveTo(_trailPoints.first.dx, _trailPoints.first.dy);
      for (int i = 1; i < _trailPoints.length; i++) {
        path.lineTo(_trailPoints[i].dx, _trailPoints[i].dy);
      }
      canvas.drawPath(path, _trailPaint);
    }
  }
}
