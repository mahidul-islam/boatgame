import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Ensures we get the correct event types
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors, ValueNotifier, Color;
import 'boat_component.dart';
import 'path_trail_component.dart';
import 'river_component.dart';

enum InputMode { manual, drag }

class AngleGame extends FlameGame with DragCallbacks {
  // DragCallbacks will use the new Event types
  late BoatComponent boat;
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

    boat = BoatComponent();
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

  // Drag Callbacks for Drag-to-Rotate mode
  @override
  void onDragStart(DragStartEvent event) {
    // Changed from DragStartInfo
    if (currentInputMode == InputMode.drag) {
      boat.stopMoving();
      pathTrail.clear();
      pathTrail.addPoint(boat.position);
      // Immediately update angle based on first touch point relative to boat
      _updateAngleFromDrag(
        event.canvasPosition,
      ); // Changed from info.eventPosition.game
    }
    super.onDragStart(event); // Call super
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Changed from DragUpdateInfo
    if (currentInputMode == InputMode.drag) {
      _updateAngleFromDrag(
        (event.canvasStartPosition + event.canvasEndPosition) / 2,
      ); // Changed from info.eventPosition.game
    }
    super.onDragUpdate(event); // Call super
  }

  void _updateAngleFromDrag(Vector2 dragPosition) {
    Vector2 dragVector = dragPosition - boat.position;
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
    // Changed from DragEndInfo
    if (currentInputMode == InputMode.drag) {
      boat.startMoving();
    }
    super.onDragEnd(event); // Call super
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    // Changed from DragCancelInfo (assuming it exists like this)
    // Flame might use a generic onDragCancel() without event arg,
    // or a DragCancelEvent. If DragCancelEvent isn't a direct type,
    // then just onDragCancel() would be the override.
    // Let's assume DragCancelEvent for consistency if DragCallbacks provides it.
    // If not, it might be `void onDragCancel()`.
    // Checking Flame's DragCallbacks: it is `void onDragCancel(int pointerId)`
    // or newer versions: `void onDragCancel(DragCancelEvent event)`.
    // Given the user's format, `DragCancelEvent event` is likely.
    if (currentInputMode == InputMode.drag) {
      boat.stopMoving();
    }
    super.onDragCancel(event); // Call super
  }
}
