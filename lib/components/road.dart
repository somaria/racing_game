import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../racing_game.dart';

class Road extends Component with HasGameRef<RacingGame> {
  static const double _lineSpeed = 200.0;
  late List<Vector2> _roadLines;
  late double _lineSpacing;

  @override
  Future<void> onLoad() async {
    _lineSpacing = 80.0;
    _roadLines = [];
    
    // Create initial road lines
    for (double y = -_lineSpacing; y < gameRef.size.y + _lineSpacing; y += _lineSpacing) {
      _roadLines.add(Vector2(gameRef.size.x / 2, y));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move road lines down
    for (int i = 0; i < _roadLines.length; i++) {
      _roadLines[i].y += _lineSpeed * dt;
      
      // Reset line position if it goes off screen
      if (_roadLines[i].y > gameRef.size.y + _lineSpacing) {
        _roadLines[i].y = -_lineSpacing;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw road background
    final roadPaint = Paint()..color = Colors.grey[600]!;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      roadPaint,
    );
    
    // Draw road edges
    final edgePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(40, 0, 10, gameRef.size.y),
      edgePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(gameRef.size.x - 50, 0, 10, gameRef.size.y),
      edgePaint,
    );
    
    // Draw center line
    final linePaint = Paint()..color = Colors.yellow;
    linePaint.strokeWidth = 4;
    
    for (final linePos in _roadLines) {
      canvas.drawLine(
        Offset(linePos.x, linePos.y),
        Offset(linePos.x, linePos.y + 40),
        linePaint,
      );
    }
  }
}
