import 'dart:math'
    as math; // Keep for PI if needed, though Path uses radians directly
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Path, Colors, Rect, RRect, Radius;
import 'base_boat_component.dart'; // Import the base class

class SpeedBoatComponent extends BaseBoatComponent {
  @override
  double defaultSpeed = 150.0; // Speed boats are faster

  final Paint _bodyPaint = BasicPalette.red.paint()..style = PaintingStyle.fill;
  final Paint _deckPaint = BasicPalette.lightGray.paint()
    ..style = PaintingStyle.fill;
  final Paint _windshieldPaint = BasicPalette.cyan.withAlpha(150).paint()
    ..style = PaintingStyle.fill;
  final Paint _borderPaint = BasicPalette.black.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  late Path _bodyPath;
  late Path _deckPath;
  late Path _windshieldPath;

  SpeedBoatComponent() : super() {
    // More elongated and pointed shape
    // Dimensions: approx width 16, length 30. Nose at (0, -15)
    _bodyPath = Path()
      ..moveTo(0, -15) // Front tip (nose)
      ..lineTo(-6, -10) // Upper front sides
      ..lineTo(-8, 5) // Mid sides
      ..lineTo(-6, 15) // Rear corners
      ..lineTo(6, 15) // Rear
      ..lineTo(8, 5) // Mid sides
      ..lineTo(6, -10) // Upper front sides
      ..close();

    // Deck area (slightly smaller than body)
    _deckPath = Path()
      ..moveTo(0, -12)
      ..lineTo(-4, -8)
      ..lineTo(-6, 3)
      ..lineTo(-4, 12)
      ..lineTo(4, 12)
      ..lineTo(6, 3)
      ..lineTo(4, -8)
      ..close();

    // Simple windshield
    // Centered around (0, -5), width 8, height 3
    _windshieldPath = Path()
      ..addRRect(RRect.fromLTRBR(-4, -7, 4, -4, const Radius.circular(1.0)));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Width: -8 to 8 = 16. Height: -15 to 15 = 30.
    size = Vector2(16, 30);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Applies transformations (position, angle)

    // Draw in order: body, deck, windshield
    canvas.drawPath(_bodyPath, _bodyPaint);
    canvas.drawPath(_bodyPath, _borderPaint); // Border for body

    canvas.drawPath(_deckPath, _deckPaint);
    canvas.drawPath(_deckPath, _borderPaint); // Border for deck

    canvas.drawPath(_windshieldPath, _windshieldPaint);
    canvas.drawPath(_windshieldPath, _borderPaint); // Border for windshield
  }
}
