import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../racing_game.dart';

class HUD extends PositionComponent with HasGameRef<RacingGame> {
  late TextComponent _scoreText;
  late TextComponent _gameOverText;
  late TextComponent _tapToRestartText;

  @override
  Future<void> onLoad() async {
    // Score text
    _scoreText = TextComponent(
      text: 'Score: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
    _scoreText.position = Vector2(20, 50);
    add(_scoreText);

    // Game over text
    _gameOverText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
    _gameOverText.position = Vector2(
      gameRef.size.x / 2 - 120,
      gameRef.size.y / 2 - 100,
    );
    add(_gameOverText);

    // Tap to restart text
    _tapToRestartText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
    _tapToRestartText.position = Vector2(
      gameRef.size.x / 2 - 80,
      gameRef.size.y / 2 - 50,
    );
    add(_tapToRestartText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update score display
    _scoreText.text = 'Score: ${gameRef.score}';
    
    // Show game over text if the game is over
    if (gameRef.isGameOver) {
      _gameOverText.text = 'GAME OVER';
      _tapToRestartText.text = 'Tap to Restart';
    } else {
      _gameOverText.text = '';
      _tapToRestartText.text = '';
    }
  }
}
