import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../racing_game.dart';
import 'enemy_car.dart';

class PlayerCar extends RectangleComponent
    with HasGameRef<RacingGame>, CollisionCallbacks {
  static const double _steeringSpeed =
      150.0; // Further reduced for easier control
  static const double _steeringDamping =
      0.95; // Even more damping for smoother stops
  static const double _maxSteeringAngle = 0.25; // Even smaller visual angle

  late double _leftBound;
  late double _rightBound;
  final String word = 'PLAYER';

  // Power steering properties
  double _steeringInput = 0.0; // -1.0 to 1.0
  double _currentVelocity = 0.0;
  double _steeringAngle = 0.0;
  bool _isSteeringLeft = false;
  bool _isSteeringRight = false;

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
    _isSteeringLeft = true;
    _isSteeringRight = false;
    _steeringInput = -1.0;
  }

  void moveRight(double dt) {
    _isSteeringLeft = false;
    _isSteeringRight = true;
    _steeringInput = 1.0;
  }

  void stopSteering() {
    _isSteeringLeft = false;
    _isSteeringRight = false;
    _steeringInput = 0.0;
  }

  // Public getters for steering state
  bool get isSteeringLeft => _isSteeringLeft;
  bool get isSteeringRight => _isSteeringRight;
  double get steeringAngle => _steeringAngle;

  @override
  void update(double dt) {
    super.update(dt);

    // Apply simplified power steering physics
    if (_steeringInput != 0.0) {
      // Direct velocity control for more responsive steering
      _currentVelocity = _steeringInput * _steeringSpeed;
    } else {
      // Apply stronger damping when no input for quicker stops
      _currentVelocity *= _steeringDamping;
      if (_currentVelocity.abs() < 5.0) {
        _currentVelocity = 0.0; // Stop small movements
      }
    }

    // Update steering angle for visual feedback
    _steeringAngle = (_currentVelocity / _steeringSpeed) * _maxSteeringAngle;

    // Apply movement
    position.x += _currentVelocity * dt;

    // Keep car within bounds
    if (position.x < _leftBound) {
      position.x = _leftBound;
      _currentVelocity = 0.0;
    }
    if (position.x > _rightBound) {
      position.x = _rightBound;
      _currentVelocity = 0.0;
    }
  }

  @override
  bool onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
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

    // Apply steering rotation to the entire car
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_steeringAngle * 0.3); // Subtle car rotation
    canvas.translate(-size.x / 2, -size.y / 2);

    // Draw car body
    final carRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(carRect, const Radius.circular(15)),
      paint,
    );

    // Draw word
    final textPainter = TextPainter(
      text: TextSpan(
        text: word,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2 + 10,
      ),
    );

    // Draw windshield
    final windshieldPaint = Paint()..color = Colors.lightBlue;
    final windshieldRect = Rect.fromLTWH(8, 8, size.x - 16, 30);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windshieldRect, const Radius.circular(4)),
      windshieldPaint,
    );

    // Draw steering wheel
    final steeringWheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(size.x / 2, 25);
    canvas.rotate(_steeringAngle);
    canvas.drawCircle(const Offset(0, 0), 8, steeringWheelPaint);
    canvas.drawLine(
      const Offset(-6, 0),
      const Offset(6, 0),
      steeringWheelPaint,
    );
    canvas.drawLine(
      const Offset(0, -6),
      const Offset(0, 6),
      steeringWheelPaint,
    );
    canvas.restore();

    // Draw wheels
    final wheelPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(10, 20), 8, wheelPaint);
    canvas.drawCircle(Offset(size.x - 10, 20), 8, wheelPaint);
    canvas.drawCircle(Offset(10, size.y - 20), 8, wheelPaint);
    canvas.drawCircle(Offset(size.x - 10, size.y - 20), 8, wheelPaint);

    // Draw power steering indicator
    if (_steeringInput != 0.0) {
      final indicatorPaint = Paint()
        ..color = _isSteeringLeft ? Colors.red : Colors.green
        ..style = PaintingStyle.fill;

      if (_isSteeringLeft) {
        canvas.drawRect(
          Rect.fromLTWH(-5, size.y / 2 - 10, 3, 20),
          indicatorPaint,
        );
      } else if (_isSteeringRight) {
        canvas.drawRect(
          Rect.fromLTWH(size.x + 2, size.y / 2 - 10, 3, 20),
          indicatorPaint,
        );
      }
    }

    canvas.restore();
  }
}
