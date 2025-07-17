import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../racing_game.dart';

class SteeringWheel extends PositionComponent with HasGameRef<RacingGame> {
  static const double _wheelRadius = 60.0;
  static const double _knobRadius = 8.0;

  double _rotation = 0.0; // Current rotation in radians
  double _maxRotation =
      pi /
      6; // Maximum rotation (30 degrees) - further reduced for even easier control
  double _targetRotation = 0.0;

  late CircleComponent _wheelRim;
  late CircleComponent _wheelKnob;
  late RectangleComponent _wheelSpoke1;
  late RectangleComponent _wheelSpoke2;

  @override
  Future<void> onLoad() async {
    size = Vector2(_wheelRadius * 2, _wheelRadius * 2);

    // Position the steering wheel at bottom right
    position = Vector2(
      gameRef.size.x - size.x - 20,
      gameRef.size.y - size.y - 20,
    );

    // Create wheel rim
    _wheelRim = CircleComponent(
      radius: _wheelRadius,
      paint: Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
      position: Vector2(_wheelRadius, _wheelRadius),
      anchor: Anchor.center,
    );
    add(_wheelRim);

    // Create wheel spokes
    _wheelSpoke1 = RectangleComponent(
      size: Vector2(_wheelRadius * 1.6, 4),
      paint: Paint()..color = Colors.grey[700]!,
      position: Vector2(_wheelRadius, _wheelRadius),
      anchor: Anchor.center,
    );
    add(_wheelSpoke1);

    _wheelSpoke2 = RectangleComponent(
      size: Vector2(4, _wheelRadius * 1.6),
      paint: Paint()..color = Colors.grey[700]!,
      position: Vector2(_wheelRadius, _wheelRadius),
      anchor: Anchor.center,
    );
    add(_wheelSpoke2);

    // Create steering knob (thumb grip)
    _wheelKnob = CircleComponent(
      radius: _knobRadius,
      paint: Paint()..color = Colors.red,
      position: Vector2(_wheelRadius, _wheelRadius - _wheelRadius * 0.7),
      anchor: Anchor.center,
    );
    add(_wheelKnob);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smoothly interpolate to target rotation (slower for more control)
    _rotation = _rotation + (_targetRotation - _rotation) * dt * 6;

    // Update visual rotation
    _wheelSpoke1.angle = _rotation;
    _wheelSpoke2.angle = _rotation;

    // Update knob position based on rotation
    final knobX = _wheelRadius + cos(_rotation - pi / 2) * _wheelRadius * 0.7;
    final knobY = _wheelRadius + sin(_rotation - pi / 2) * _wheelRadius * 0.7;
    _wheelKnob.position = Vector2(knobX, knobY);

    // Send steering input to player car
    final steeringInput = _rotation / _maxRotation;
    gameRef.updateSteering(steeringInput.clamp(-1.0, 1.0));

    // Auto-center when not being controlled (gentler)
    if (_targetRotation.abs() > 0.01) {
      _targetRotation *= 0.98; // Gentler damping factor
    } else {
      _targetRotation = 0.0;
    }
  }

  void handleTouch(Vector2 touchPosition) {
    // Convert global touch position to local
    final localTouch = touchPosition - position;
    final center = Vector2(_wheelRadius, _wheelRadius);

    // Calculate angle from center to touch point
    final deltaX = localTouch.x - center.x;
    final deltaY = localTouch.y - center.y;

    // Check if touch is within wheel area (larger touch area for easier control)
    final distance = sqrt(deltaX * deltaX + deltaY * deltaY);
    if (distance > _wheelRadius + 40) return; // Larger touch area

    // Simple left/right control based on touch position
    if (localTouch.x < center.x - 20) {
      // Touch on left side - turn left (reduced intensity)
      _targetRotation = -_maxRotation * 0.6;
    } else if (localTouch.x > center.x + 20) {
      // Touch on right side - turn right (reduced intensity)
      _targetRotation = _maxRotation * 0.6;
    } else {
      // Touch in center - neutral
      _targetRotation = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw steering wheel background
    final wheelBg = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(_wheelRadius, _wheelRadius),
      _wheelRadius + 10,
      wheelBg,
    );

    // Draw steering angle indicator
    final indicatorPaint = Paint()
      ..color = _rotation.abs() > 0.05
          ? (_rotation > 0 ? Colors.green : Colors.red)
          : Colors.grey
      ..strokeWidth = 4;

    final indicatorLength = 20.0;
    final indicatorAngle = _rotation;
    final startX =
        _wheelRadius + cos(indicatorAngle - pi / 2) * (_wheelRadius + 15);
    final startY =
        _wheelRadius + sin(indicatorAngle - pi / 2) * (_wheelRadius + 15);
    final endX =
        _wheelRadius +
        cos(indicatorAngle - pi / 2) * (_wheelRadius + 15 + indicatorLength);
    final endY =
        _wheelRadius +
        sin(indicatorAngle - pi / 2) * (_wheelRadius + 15 + indicatorLength);

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), indicatorPaint);

    // Draw center dot
    canvas.drawCircle(
      Offset(_wheelRadius, _wheelRadius),
      4,
      Paint()..color = Colors.white,
    );

    // Draw left/right guidance text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Left side
    textPainter.text = const TextSpan(
      text: 'L',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(_wheelRadius - 30, _wheelRadius - 6));

    // Right side
    textPainter.text = const TextSpan(
      text: 'R',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(_wheelRadius + 25, _wheelRadius - 6));
  }

  double get steeringInput => _rotation / _maxRotation;
}
