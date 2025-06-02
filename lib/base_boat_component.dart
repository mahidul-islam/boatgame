import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint; // Only import what's needed

abstract class BaseBoatComponent extends PositionComponent {
  double currentSpeed = 0; // Speed, 0 means not moving
  abstract double defaultSpeed; // To be defined by subclasses

  double _angleDegrees = 0;

  bool get isMoving => currentSpeed > 0;

  double get angleDegrees => _angleDegrees;
  set angleDegrees(double degrees) {
    _angleDegrees = degrees % 360;
    if (_angleDegrees < 0) _angleDegrees += 360;
    angle = _angleDegrees * (math.pi / 180.0);
  }

  BaseBoatComponent() {
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isMoving) {
      double movementAngleRadians = angle - (math.pi / 2.0);
      position.x += currentSpeed * math.cos(movementAngleRadians) * dt;
      position.y += currentSpeed * math.sin(movementAngleRadians) * dt;
    }
  }

  void startMoving() {
    currentSpeed = defaultSpeed;
  }

  void stopMoving() {
    currentSpeed = 0;
  }

  // Abstract method for subclasses to define their shape and paint
  @override
  void render(Canvas canvas);
}
