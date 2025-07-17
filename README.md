# Racing Game

A simple racing game built with Flutter and Flame engine.

## Features

- **Player Car**: Blue car that can move left and right (displays "PLAYER")
- **Enemy Cars**: Randomly colored cars that spawn from the top (each displays a random English word)
- **Word Overlay**: All cars display English words for educational value
- **Collision Detection**: Game ends when player collides with enemy cars
- **Score System**: Points increase over time
- **Game Over**: Displays score and allows restart
- **Animated Road**: Moving road lines for visual effect

## How to Play

1. **Movement**: Tap on the left side of the screen to move your car left, tap on the right side to move right
2. **Objective**: Avoid hitting enemy cars to keep playing
3. **Scoring**: Your score increases as you survive longer
4. **Game Over**: When you hit an enemy car, the game ends
5. **Restart**: Tap anywhere on the screen after game over to restart

## Controls

- **Left Side Tap**: Move car left
- **Right Side Tap**: Move car right
- **Tap after Game Over**: Restart the game

## Game Components

### Player Car
- Blue car with windshield and wheels
- Displays "PLAYER" text overlay
- Moves within road boundaries
- Collision detection enabled

### Enemy Cars
- Random colors (red, green, orange, purple)
- Each displays a random English word (SPEED, FAST, RACE, DRIVE, etc.)
- Spawn from top of screen
- Move downward at constant speed
- Automatically removed when off-screen

### Word System
- 24 different English words can appear on enemy cars
- Words are racing/driving themed: SPEED, FAST, RACE, DRIVE, TURN, STOP, ROAD, CAR, MOVE, LANE, RUSH, ZOOM, GEAR, RIDE, DASH, JUMP, FUEL, BOOST, SHIFT, BRAKE, WHEEL, TRACK, SWIFT, QUICK
- Each enemy car gets a randomly selected word
- Words are displayed in white text on the car body

### Road
- Grey background with white edges
- Moving yellow center line
- Creates illusion of forward movement

### HUD
- Score display in top-left corner
- Game over message when collision occurs
- Restart instruction text

## Technical Details

- Built with Flutter SDK
- Uses Flame game engine (v1.30.1)
- Collision detection system
- Component-based architecture
- Supports multiple platforms (iOS, Android, macOS, Web)

## Running the Game

```bash
flutter run
```

Or for a specific platform:
```bash
flutter run -d macos
flutter run -d ios
flutter run -d android
flutter run -d chrome
```

## File Structure

```
lib/
├── main.dart                 # Main entry point with gesture detection
├── racing_game.dart          # Main game logic and state management
└── components/
    ├── player_car.dart       # Player car component
    ├── enemy_car.dart        # Enemy car component
    ├── road.dart             # Road background component
    └── hud.dart              # UI display component
```

## Game Rules

- Enemy cars spawn every 2.5 seconds (reduced for easier gameplay)
- Score increases by 10 points per enemy car spawn
- Player car moves at 200 pixels per second
- Enemy cars move at 100 pixels per second (reduced for easier gameplay)
- Game ends immediately upon collision
- No power-ups or special abilities

Enjoy the game!
