import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../racing_game.dart';
import 'enemy_car.dart';

class PlayerCar extends RectangleComponent with HasGameRef<RacingGame>, CollisionCallbacks {
  static const double _speed = 200.0;
  late double _leftBound;
  late double _rightBound;
  final String word = 'PLAYER';

  @override
  Future<void> onLoad() async {
    size = Vector2(60, 100);
    position = Vector2(
      gameRef.size.x / 2 - size.x / 2,
      gameRef.size.y - size.y - 50,
    );
    
    paint = Paint()..color = Colors.blue;
    
    // Add collision hitbox
    add(RectangleHitbox());
    
    // Set movement boundaries
    _leftBound = 50;
    _rightBound = gameRef.size.x - size.x - 50;
  }

  void moveLeft(double dt) {
    position.x -= _speed * dt;
    if (position.x < _leftBound) {
      position.x = _leftBound;
    }
  }

  void moveRight(double dt) {
    position.x += _speed * dt;
    if (position.x > _rightBound) {
      position.x = _rightBound;
    }
  }

  @override
  bool onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is EnemyCar) {
      // Handle collision with enemy car
      gameRef.gameOver();
      return true;
    }
    return false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw car body
    final carRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(carRect, const Radius.circular(8)),
      paint,
    );
    
    // Draw word
    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2, size.y / 2 - textPainter.height / 2),
    );

    // Draw windshield
    final windshieldPaint = Paint()..color = Colors.lightBlue;
    final windshieldRect = Rect.fromLTWH(8, 8, size.x - 16, 30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windshieldRect, const Radius.circular(4)),
      windshieldPaint,
    );
    
    // Draw wheels
    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(10, 20), 8, wheelPaint);
    canvas.drawCircle(Offset(size.x - 10, 20), 8, wheelPaint);
    canvas.drawCircle(Offset(10, size.y - 20), 8, wheelPaint);
    canvas.drawCircle(Offset(size.x - 10, size.y - 20), 8, wheelPaint);
  }
}
