import 'dart:math' as math;
import 'package:boatgame/base_boat_component.dart';
import 'package:boatgame/jet_ski_component.dart';
import 'package:boatgame/raft_component.dart';
import 'package:boatgame/speed_boat_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors, ValueNotifier, Color;
import 'boat_component.dart';
import 'path_trail_component.dart';
import 'river_component.dart';

enum InputMode { manual, drag }

class AngleGame extends FlameGame with DragCallbacks {
  late BaseBoatComponent boat;
  late RiverComponent river;
  late PathTrailComponent pathTrail;

  Vector2 initialBoatPosition = Vector2.zero();
  final double riverWidthFraction = 0.4;

  InputMode currentInputMode = InputMode.manual;
  ValueNotifier<double> currentAngleNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<InputMode> currentInputModeNotifier = ValueNotifier<InputMode>(
    InputMode.manual,
  );

  @override
  Color backgroundColor() => Colors.lightBlue.shade50;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    double gameWidth = size.x;
    double gameHeight = size.y;
    double actualRiverWidth = gameWidth * riverWidthFraction;

    river = RiverComponent(
      position: Vector2((gameWidth - actualRiverWidth) / 2, 0),
      size: Vector2(actualRiverWidth, gameHeight),
    );
    add(river);

    pathTrail = PathTrailComponent();
    add(pathTrail);

    boat = SpeedBoatComponent();
    // boat = RaftComponent();
    // boat = JetSkiComponent();
    initialBoatPosition = Vector2(gameWidth / 2, gameHeight / 2);
    add(boat);

    resetGame();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (boat.isMoving) {
      pathTrail.addPoint(boat.position);
    }
  }

  void setBoatAngleAndStart(double degrees) {
    boat.angleDegrees = degrees;
    boat.startMoving();
    currentAngleNotifier.value = boat.angleDegrees;
  }

  void setBoatAngle(double degrees) {
    boat.angleDegrees = degrees;
    currentAngleNotifier.value = boat.angleDegrees;
  }

  void startBoatMovement() {
    boat.startMoving();
  }

  void resetGame() {
    boat.position.setFrom(initialBoatPosition);
    boat.angleDegrees = 0;
    boat.stopMoving();
    pathTrail.clear();
    pathTrail.addPoint(boat.position);
    currentAngleNotifier.value = boat.angleDegrees;
  }

  void toggleInputMode() {
    if (currentInputMode == InputMode.manual) {
      currentInputMode = InputMode.drag;
    } else {
      currentInputMode = InputMode.manual;
    }
    currentInputModeNotifier.value = currentInputMode;
    boat.stopMoving();
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (currentInputMode == InputMode.drag) {
      boat.stopMoving();
      pathTrail.clear();
      pathTrail.addPoint(boat.position);

      // For DragStartEvent, `event.canvasPosition` should be available and correct. [2]
      _updateAngleFromDrag(event.canvasPosition);
    }
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (currentInputMode == InputMode.drag) {
      // For DragUpdateEvent in Flame ~1.2.x/1.3.x, `event.canvasEndPosition`
      // represents the current position of this drag update segment. [10]
      _updateAngleFromDrag(event.canvasEndPosition);
    }
    super.onDragUpdate(event);
  }

  void _updateAngleFromDrag(Vector2 dragPositionOnCanvas) {
    Vector2 dragVector = dragPositionOnCanvas - boat.position;
    if (dragVector.length2 > 0) {
      double angleRad = math.atan2(dragVector.y, dragVector.x);
      double visualAngleRad = angleRad + (math.pi / 2.0);

      double newAngleDegrees = visualAngleRad * (180.0 / math.pi);
      newAngleDegrees %= 360;
      if (newAngleDegrees < 0) newAngleDegrees += 360;

      boat.angleDegrees = newAngleDegrees;
      currentAngleNotifier.value = boat.angleDegrees;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (currentInputMode == InputMode.drag) {
      boat.startMoving();
    }
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    if (currentInputMode == InputMode.drag) {
      boat.stopMoving();
    }
    super.onDragCancel(event);
  }
}
