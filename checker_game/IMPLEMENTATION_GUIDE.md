# Checkers Game Implementation Guide

## Quick Start

### To Play the Game:
1. Run the app: `flutter run`
2. Tap "Start Game" on the home screen
3. Select a piece (it will be highlighted in gold)
4. Valid moves appear in green
5. Tap a valid move to make it
6. Use "Back" to undo, "Reset" to restart

## Code Structure

```
lib/
├── models/
│   ├── piece.dart              # Piece representation
│   ├── board_state.dart        # Board management
│   ├── move.dart               # Move tracking
│   ├── game_logic.dart         # Core game engine
│   └── index.dart              # Barrel export
├── widgets/
│   ├── checker_board.dart      # Interactive board UI
│   └── [other widgets...]
├── screens/
│   ├── game_screen.dart        # Main game screen
│   └── [other screens...]
└── theme/
    └── app_colors.dart
```

## Key Implementation Details

### 1. Board Representation
- 8x8 grid using two-dimensional List<List<Piece>>
- Only dark squares (playable): positions where (row + col) % 2 == 1
- Pieces are immutable objects

### 2. Move Validation Algorithm
The game uses a two-phase approach:

**Phase 1: Check for Jumps**
```
If any jump available:
    Return list of jump moves
Else:
    Return list of regular moves
```

**Phase 2: Jump Detection**
- For each diagonal direction:
  - Check if 2 squares away is empty
  - Check if 1 square away has enemy piece
  - If yes: found a potential jump
  - Recursively check for multi-jumps from new position
  - Use visited states set to prevent infinite loops

### 3. Multi-Jump Handling
When a piece captures and can continue:
1. Current move is recorded with all captured positions
2. The same player's turn continues
3. Player MUST jump again if another jump is available
4. If no more jumps available, turn passes to opponent

### 4. King Promotion
```dart
if ((piece.color == PieceColor.black && toRow == 7) ||
    (piece.color == PieceColor.white && toRow == 0)) {
  piece = piece.promoteToKing();
}
```

### 5. Game State Management
The `CheckersGame` class maintains:
- Current board state
- Whose turn it is
- What's currently selected
- Valid moves for selection
- Complete move history
- Game over status

## How to Extend

### Add AI Opponent
Create a new class in `models/ai_logic.dart`:
```dart
class AILogic {
  static Move selectBestMove(CheckersGame game) {
    List<Move> allMoves = getAllPossibleMoves(game);
    // Implement AI strategy here
    return allMoves[0];
  }
}
```

### Add Game Animations
Modify `CheckerBoard` widget:
```dart
AnimatedBuilder(
  animation: _pieceAnimation,
  child: pieceWidget,
);
```

### Add Sound Effects
In `game_logic.dart`, add callbacks:
```dart
void Function()? onCapture;
void Function()? onKingPromote;

// Call in _executeMove:
if (move.isJump) onCapture?.call();
```

### Add Multiplayer Online
Modify `CheckersGame` to accept a network listener:
```dart
class CheckersGame {
  void Function(Move)? onRemoteMove;
  
  void applyRemoteMove(Move move) { ... }
}
```

## Testing Checklist

- [ ] Board initializes with 12 pieces per side
- [ ] Black starts first
- [ ] Regular pieces move only forward
- [ ] Regular pieces can't select backward moves
- [ ] King pieces move in all directions
- [ ] Jump captures opponent piece
- [ ] Multi-jump works correctly
- [ ] Promotion to king triggers at end row
- [ ] King shows visual indicator (gold star)
- [ ] Mandatory jump rule enforced
- [ ] Game ends when no pieces left
- [ ] Game ends when no valid moves left
- [ ] Undo restores previous state
- [ ] Reset clears all moves

## Performance Considerations

1. **Board Copying**: Used for temporary multi-jump calculation
   - Cost: O(64) = O(1) constant
   - Only done during move validation, not on every frame

2. **Valid Move Calculation**: O(32) worst case
   - Check each piece on board
   - Calculate 4 diagonal directions per piece
   - Not on every render, only when piece selected

3. **Move History**: Stored as list of Move objects
   - Used for undo functionality
   - Replayed for position restoration

## Common Bugs to Watch For

1. **Diagonal Constraint**: Pieces can only move on dark squares
   ```dart
   if (!board.isValidSquare(newRow, newCol)) return;
   ```

2. **Turn Management**: After selecting a piece, temporarily can show multi-jumps
   - Keep same player if more jumps available
   - Switch player only when no more jumps

3. **King Promotion**: Must happen AFTER moving, not during move calculation
   ```dart
   // In _executeMove, after moving piece:
   if (shouldPromoteToKing(toRow, toCol, piece)) {
     promote();
   }
   ```

4. **Board State Isolation**: Board copy must be complete
   ```dart
   BoardState copy = board.copy(); // Don't reference original
   ```

## Debugging Tips

1. Print current valid moves:
   ```dart
   print('Valid moves: ${game.validMoves}');
   ```

2. Check board state:
   ```dart
   for (int i = 0; i < 8; i++) {
     for (int j = 0; j < 8; j++) {
       print('[$i,$j]: ${game.board.getPiece(i, j)}');
     }
   }
   ```

3. Trace move execution:
   ```dart
   print('Moving from ($fromRow,$fromCol) to ($toRow,$toCol)');
   print('Captures: ${move.capturedPositions}');
   ```

4. Use breakpoints in:
   - `_getValidMoves()`: Check move calculation
   - `_executeMove()`: Check move application
   - `_checkGameOver()`: Check win condition

## Files Summary

| File | Purpose | Key Classes |
|------|---------|------------|
| piece.dart | Piece model | Piece, PieceColor, PieceType |
| board_state.dart | Board management | BoardState |
| move.dart | Move tracking | Move |
| game_logic.dart | Game engine | CheckersGame |
| checker_board.dart | UI rendering | CheckerBoard (Widget) |
| game_screen.dart | Game screen | GameScreen |

## Integration with Flutter UI

The `CheckerBoard` widget receives a callback:
```dart
CheckerBoard(
  interactive: true,
  onGameStateChanged: (game) {
    setState(() {
      _gameState = game;
      // Update UI based on game state
    });
  },
)
```

Parent widget uses the game state to display:
- Current player
- Game status (waiting / game over)
- Move history
- Undo/Reset buttons

## Version Info
- Flutter SDK: ^3.11.0
- Dart: ^3.11.0
- No external game libraries used

## Future Roadmap
- [ ] Single-player AI mode
- [ ] Online multiplayer
- [ ] Game replay viewer
- [ ] Tournament mode
- [ ] Move animations
- [ ] Sound effects
- [ ] Statistics tracking
- [ ] Custom themes
