import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/player_car.dart';
import 'components/enemy_car.dart';
import 'components/road.dart';
import 'components/hud.dart';
import 'components/steering_wheel.dart';

class RacingGame extends FlameGame with HasCollisionDetection {
  late PlayerCar _playerCar;
  late Road _road;
  late HUD _hud;
  late SteeringWheel _steeringWheel;
  double _spawnTimer = 2.5; // Start at 2.5 so first car spawns after 2 seconds
  final Random _random = Random();
  int _score = 0;
  bool _gameOver = false;

  @override
  Future<void> onLoad() async {
    // Add road to the game
    _road = Road();
    add(_road);

    // Initialize and add player car to the game
    _playerCar = PlayerCar();
    add(_playerCar);

    // Add HUD
    _hud = HUD();
    add(_hud);

    // Add steering wheel
    _steeringWheel = SteeringWheel();
    add(_steeringWheel);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver) return;

    // Update spawn timer
    _spawnTimer += dt;

    // Every 4.5 seconds, spawn a new enemy car (balanced difficulty)
    if (_spawnTimer > 4.5) {
      _spawnTimer = 0.0;
      _spawnEnemyCar();
      _score += 10;
    }
  }

  void _spawnEnemyCar() {
    // Randomly choose lane positions
    final lanes = [80.0, 160.0, 240.0];
    double xPosition = lanes[_random.nextInt(lanes.length)];

    // Check if there's already a car too close in this lane
    final existingCars = children.whereType<EnemyCar>();
    bool tooClose = false;

    for (final car in existingCars) {
      // Check if car is in the same lane and too close to the top (moderate distance)
      if ((car.position.x - xPosition).abs() < 50 && car.position.y < 280) {
        tooClose = true;
        break;
      }
    }

    // If too close, try a different lane or skip this spawn
    if (tooClose) {
      // Try other lanes
      final availableLanes = lanes.where((lane) {
        return !existingCars.any(
          (car) => (car.position.x - lane).abs() < 50 && car.position.y < 280,
        );
      }).toList();

      if (availableLanes.isEmpty) {
        return; // Skip this spawn if all lanes are occupied
      }

      xPosition = availableLanes[_random.nextInt(availableLanes.length)];
    }

    final colors = [Colors.red, Colors.green, Colors.orange, Colors.purple];
    Color color = colors[_random.nextInt(colors.length)];

    // Create enemy car and add it to the game (spawn much further up)
    add(EnemyCar(startPosition: Vector2(xPosition, -200.0), carColor: color));
  }

  void handleTap(Vector2 tapPosition) {
    if (_gameOver) {
      // Restart game
      restartGame();
      return;
    }

    // Check if tap is on steering wheel first
    _steeringWheel.handleTouch(tapPosition);
  }

  void handlePanStart(Vector2 startPosition) {
    if (_gameOver) return;

    // Handle steering wheel touch first
    _steeringWheel.handleTouch(startPosition);
  }

  void handlePanUpdate(Vector2 currentPosition) {
    if (_gameOver) return;

    // Handle steering wheel touch
    _steeringWheel.handleTouch(currentPosition);
  }

  void handlePanEnd() {
    if (_gameOver) return;

    // Stop steering when pan ends
    _playerCar.stopSteering();
  }

  void updateSteering(double steeringInput) {
    // Update player car based on steering wheel input with better sensitivity
    if (steeringInput < -0.05) {
      // Lower threshold for more responsive steering
      _playerCar.moveLeft(0.016);
    } else if (steeringInput > 0.05) {
      // Lower threshold for more responsive steering
      _playerCar.moveRight(0.016);
    } else {
      _playerCar.stopSteering();
    }
  }

  void gameOver() {
    _gameOver = true;
  }

  void restartGame() {
    // Reset game state
    _gameOver = false;
    _score = 0;
    _spawnTimer = 2.5; // Reset to 2.5 so first car spawns quickly after restart

    // Remove all enemy cars
    children.whereType<EnemyCar>().toList().forEach(
      (car) => car.removeFromParent(),
    );

    // Reset player car position
    _playerCar.position = Vector2(
      size.x / 2 - _playerCar.size.x / 2,
      size.y - _playerCar.size.y - 50,
    );
  }

  int get score => _score;
  bool get isGameOver => _gameOver;
}
