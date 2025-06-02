import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Path, Colors, Rect, Offset;
import 'base_boat_component.dart';

class JetSkiComponent extends BaseBoatComponent {
  @override
  double defaultSpeed = 120.0; // Jet skis are agile

  final Paint _bodyPaint = BasicPalette.yellow.paint()
    ..style = PaintingStyle.fill;
  final Paint _seatPaint = BasicPalette.darkGray.paint()
    ..style = PaintingStyle.fill;
  final Paint _handlebarPaint = BasicPalette.black.paint()
    ..style = PaintingStyle.fill;
  final Paint _borderPaint = BasicPalette.black.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  late Path _bodyPath;
  late Path _seatPath;
  late Path _handlebarPath;

  JetSkiComponent() : super() {
    // Smaller, more rounded front. Approx width 10, length 20. Nose at (0,-10)
    _bodyPath = Path()
      ..moveTo(0, -10) // Nose
      ..quadraticBezierTo(-6, -8, -5, 0) // Rounded front-left
      ..lineTo(-4, 8) // Side
      ..arcToPoint(
        Offset(4, 8),
        radius: Radius.circular(3),
        clockwise: false,
      ) // Rounded rear
      ..lineTo(5, 0) // Side
      ..quadraticBezierTo(6, -8, 0, -10) // Rounded front-right
      ..close();

    // Seat area
    _seatPath = Path()
      ..moveTo(0, -3)
      ..lineTo(-2, -2)
      ..lineTo(-1.5, 6)
      ..lineTo(1.5, 6)
      ..lineTo(2, -2)
      ..close();

    // Simple Handlebars (a small rectangle)
    _handlebarPath = Path()
      ..addRect(
        Rect.fromCenter(center: const Offset(0, -6.5), width: 5, height: 1.5),
      );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Approximate size based on path: Max X is ~5, Max Y is ~10
    // Width: ~10, Height: ~20
    size = Vector2(12, 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawPath(_bodyPath, _bodyPaint);
    canvas.drawPath(_bodyPath, _borderPaint);

    canvas.drawPath(_seatPath, _seatPaint);
    canvas.drawPath(_seatPath, _borderPaint);

    canvas.drawPath(_handlebarPath, _handlebarPaint);
    // No border for handlebars to keep them simple
  }
}
