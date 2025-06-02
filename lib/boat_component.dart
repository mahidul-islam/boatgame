import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Path, Colors;

class BoatComponent extends PositionComponent {
  static const double defaultSpeed = 100.0; // pixels per second
  double _currentSpeed = 0; // Speed, 0 means not moving

  // Angle in degrees, 0 is up, positive clockwise.
  // This property will handle conversion to radians for PositionComponent.angle
  double _angleDegrees = 0;

  final Paint _paint = BasicPalette.white.paint()..style = PaintingStyle.fill;
  final Paint _borderPaint = BasicPalette.black.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  late Path _boatPath;

  bool get isMoving => _currentSpeed > 0;

  double get angleDegrees => _angleDegrees;
  set angleDegrees(double degrees) {
    _angleDegrees = degrees % 360;
    if (_angleDegrees < 0) _angleDegrees += 360;
    angle =
        _angleDegrees *
        (math.pi /
            180.0); // Update visual rotation (PositionComponent.angle is in radians)
  }

  BoatComponent() {
    // Triangle pointing upwards (0, -10) as front (nose)
    _boatPath = Path()
      ..moveTo(0, -10) // Front/nose
      ..lineTo(-7, 7) // Bottom-left
      ..lineTo(7, 7) // Bottom-right
      ..close();
    anchor = Anchor.center; // Rotate around the center of the shape
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Approximate size for potential collision detection or touch handling if needed
    // Width: -7 to 7 = 14. Height: -10 to 7 = 17.
    size = Vector2(14, 17);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Applies transformations (position, angle)
    canvas.drawPath(_boatPath, _paint);
    canvas.drawPath(_boatPath, _borderPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isMoving) {
      // PositionComponent.angle (this.angle) is already set in radians by the angleDegrees setter.
      // This is the visual angle, where 0 rad means the boat points "up".
      // For movement:
      // math_angle = 0 rad -> moves right (+X)
      // math_angle = PI/2 rad -> moves down (+Y)
      // visual_angle (this.angle) = 0 rad -> boat points up (-Y)
      // So, movement_angle_rad = visual_angle_rad - PI/2
      double movementAngleRadians = angle - (math.pi / 2.0);

      position.x += _currentSpeed * math.cos(movementAngleRadians) * dt;
      position.y += _currentSpeed * math.sin(movementAngleRadians) * dt;
    }
  }

  void startMoving() {
    _currentSpeed = defaultSpeed;
  }

  void stopMoving() {
    _currentSpeed = 0;
  }
}
