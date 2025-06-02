import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, Path, Colors, Rect, Offset;
import 'base_boat_component.dart';

class RaftComponent extends BaseBoatComponent {
  @override
  double defaultSpeed = 50.0; // Rafts are slow

  final Paint _woodPaint = PaletteEntry(const Color(0xFFBA8C63)).paint()
    ..style = PaintingStyle.fill; // Brownish wood
  final Paint _linePaint = BasicPalette.black.paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  late Path _raftBody;
  final List<Path> _logLines = [];

  RaftComponent() : super() {
    // Simple rectangular raft shape
    // Dimensions: width 20, height 18. Center at (0,0)
    double raftWidth = 20;
    double raftHeight = 18;
    _raftBody = Path()
      ..addRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: raftWidth,
          height: raftHeight,
        ),
      );

    // Lines to simulate logs or planks
    int numLogs = 4;
    double logSpacing = raftHeight / numLogs;
    for (int i = 0; i < numLogs - 1; i++) {
      // Draw lines between logs
      double yPos = -raftHeight / 2 + (i + 1) * logSpacing;
      Path line = Path();
      line.moveTo(-raftWidth / 2, yPos);
      line.lineTo(raftWidth / 2, yPos);
      _logLines.add(line);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Width: 20, Height: 18
    size = Vector2(20, 18);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawPath(_raftBody, _woodPaint);
    canvas.drawPath(_raftBody, _linePaint); // Border for the raft

    for (final line in _logLines) {
      canvas.drawPath(line, _linePaint);
    }
  }
}
