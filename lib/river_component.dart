import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Rect, Offset, Colors;

class RiverComponent extends PositionComponent {
  final Paint _riverPaint = BasicPalette.lightBlue
      .paint(); // Light blue for river
  final Paint _flowLinePaint = BasicPalette.blue.withAlpha(60).paint()
    ..strokeWidth = 1.5;

  final List<_FlowLine> _flowLines = [];

  RiverComponent({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initFlowLines();
  }

  void _initFlowLines() {
    _flowLines.clear();
    const int lineColumnCount = 2; // Number of columns of flow lines
    const int linesPerColumn = 8; // Number of lines in each column vertically

    final double columnSpacing = size.x / (lineColumnCount + 1);
    final double verticalSpacing = size.y / linesPerColumn;
    const double lineLength = 20.0;

    for (int col = 0; col < lineColumnCount; col++) {
      double xPos = columnSpacing * (col + 1);
      for (int i = 0; i < linesPerColumn; i++) {
        // Stagger lines in columns for a more natural look
        double yPos =
            (i * verticalSpacing) + (col.isEven ? 0 : verticalSpacing / 2);
        _flowLines.add(
          _FlowLine(
            start: Offset(xPos, yPos),
            end: Offset(xPos, yPos + lineLength),
            boundsHeight: size.y, // Pass component height for wrap-around logic
          ),
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(
      canvas,
    ); // Essential for applying component's position and size
    // Draw river background (local coordinates 0,0 to size.x, size.y)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _riverPaint);

    // Draw flow lines (coordinates are local to this component)
    for (final line in _flowLines) {
      canvas.drawLine(line.currentStart, line.currentEnd, _flowLinePaint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var line in _flowLines) {
      line.update(dt);
    }
  }
}

// Helper class for individual flow lines, remains internal to river_component.dart
class _FlowLine {
  Offset start; // Initial relative start position within the river component
  Offset end; // Initial relative end position
  double boundsHeight; // Height of the river component for wrap-around
  double speed = 25.0; // pixels per second for flow animation

  Offset currentStart;
  Offset currentEnd;

  _FlowLine({
    required this.start,
    required this.end,
    required this.boundsHeight,
  }) : currentStart = start,
       currentEnd = end;

  void update(double dt) {
    currentStart = currentStart.translate(0, speed * dt);
    currentEnd = currentEnd.translate(0, speed * dt);

    // Wrap around logic when line moves past the bottom of the river component
    if (currentStart.dy > boundsHeight) {
      final double lineLength = end.dy - start.dy;
      // Reset to top, considering how much it overshot to maintain smooth flow
      currentStart = Offset(start.dx, currentStart.dy % boundsHeight);
      currentEnd = Offset(end.dx, currentStart.dy + lineLength);
    }
  }
}
