import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../racing_game.dart';

class EnemyCar extends RectangleComponent with HasGameRef<RacingGame>, CollisionCallbacks {
  static const double _speed = 100.0;
  late Color carColor;
  late String word;
  
  static final List<String> _words = [
    'SPEED', 'FAST', 'RACE', 'DRIVE', 'TURN', 'STOP', 'ROAD', 'CAR',
    'MOVE', 'LANE', 'RUSH', 'ZOOM', 'GEAR', 'RIDE', 'DASH', 'JUMP',
    'FUEL', 'BOOST', 'SHIFT', 'BRAKE', 'WHEEL', 'TRACK', 'SWIFT', 'QUICK'
  ];
  
  static final Random _random = Random();

  EnemyCar({required Vector2 startPosition, required this.carColor}) {
    position = startPosition;
    word = _words[_random.nextInt(_words.length)];
  }

  @override
  Future<void> onLoad() async {
    size = Vector2(60, 100);
    paint = Paint()..color = carColor;
    
    // Add collision hitbox
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Move car down
    position.y += _speed * dt;
    
    // Remove car if it goes off screen
    if (position.y > gameRef.size.y) {
      removeFromParent();
    }
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
          fontSize: 10,
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
    final windshieldPaint = Paint()..color = carColor.withOpacity(0.7);
    final windshieldRect = Rect.fromLTWH(8, size.y - 38, size.x - 16, 30);
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
