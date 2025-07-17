import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/player_car.dart';
import 'components/enemy_car.dart';
import 'components/road.dart';
import 'components/hud.dart';

class RacingGame extends FlameGame with HasCollisionDetection {
  late PlayerCar _playerCar;
  late Road _road;
  late HUD _hud;
  double _spawnTimer = 0.0;
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
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver) return;

    // Update spawn timer
    _spawnTimer += dt;

    // Every 2.5 seconds, spawn a new enemy car
    if (_spawnTimer > 2.5) {
      _spawnTimer = 0.0;
      _spawnEnemyCar();
      _score += 10;
    }
  }

  void _spawnEnemyCar() {
    // Randomly choose lane positions
    final lanes = [80.0, 160.0, 240.0];
    double xPosition = lanes[_random.nextInt(lanes.length)];
    
    final colors = [Colors.red, Colors.green, Colors.orange, Colors.purple];
    Color color = colors[_random.nextInt(colors.length)];

    // Create enemy car and add it to the game
    add(EnemyCar(startPosition: Vector2(xPosition, -100.0), carColor: color));
  }

  void handleTap(Vector2 tapPosition) {
    if (_gameOver) {
      // Restart game
      restartGame();
      return;
    }

    // Move player car left or right based on tap position
    if (tapPosition.x < size.x / 2) {
      _playerCar.moveLeft(0.1);
    } else {
      _playerCar.moveRight(0.1);
    }
  }

  void gameOver() {
    _gameOver = true;
  }

  void restartGame() {
    // Reset game state
    _gameOver = false;
    _score = 0;
    _spawnTimer = 0.0;

    // Remove all enemy cars
    children.whereType<EnemyCar>().toList().forEach((car) => car.removeFromParent());

    // Reset player car position
    _playerCar.position = Vector2(
      size.x / 2 - _playerCar.size.x / 2,
      size.y - _playerCar.size.y - 50,
    );
  }

  int get score => _score;
  bool get isGameOver => _gameOver;
}
