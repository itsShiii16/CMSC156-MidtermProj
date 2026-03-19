# Checkers Game Logic Implementation

## Overview
This document describes the complete game logic implementation for the checkers game. The implementation follows standard American Checkers rules.

## Architecture

### Models

#### `Piece` (piece.dart)
Represents a single checker piece on the board.

**Properties:**
- `color`: PieceColor enum (white, black, empty)
- `type`: PieceType enum (regular, king)

**Methods:**
- `isEmpty`: Returns true if the piece is empty
- `isKing`: Returns true if the piece is a king
- `promoteToKing()`: Returns a new piece promoted to king

#### `BoardState` (board_state.dart)
Manages the 8x8 checkerboard and all pieces on it.

**Key Methods:**
- `getPiece(row, col)`: Get piece at specific position
- `setPiece(row, col, piece)`: Set piece at position
- `removePiece(row, col)`: Remove piece from position
- `isValidSquare(row, col)`: Check if position is a dark square
- `countPieces(color)`: Count pieces of a specific color
- `copy()`: Create a deep copy of the board state

#### `Move` (move.dart)
Represents a move from one square to another.

**Properties:**
- `fromRow`, `fromCol`: Starting position
- `toRow`, `toCol`: Destination position
- `capturedPositions`: List of captured piece positions (for multi-jumps)
- `isJump`: True if move captures pieces

#### `CheckersGame` (game_logic.dart)
Main game logic engine. This is the core of the implementation.

**Public Properties:**
- `board`: Current board state
- `currentPlayer`: Whose turn it is (PieceColor.black or white)
- `isGameOver`: True if game has ended
- `winner`: The winning player (if game is over)
- `selectedRow`, `selectedCol`: Currently selected piece position
- `validMoves`: List of valid moves for selected piece
- `moveHistory`: All moves made so far

**Key Methods:**

##### `selectSquare(int row, int col)`
Called when user taps a board square. Handles:
- Selecting own pieces
- Moving to valid destination
- Deselecting pieces

##### `_getValidMoves(int row, int col) -> List<Move>`
Returns all valid moves for a piece at given position.
- First checks for jumps (mandatory in checkers)
- If no jumps available, returns regular moves
- Follows the "must jump" rule

##### `_getRegularMoves(int row, int col) -> List<Move>`
Returns regular (non-capture) moves.
- Regular pieces: can only move forward diagonally
- King pieces: can move in any diagonal direction

##### `_getJumpMoves(int row, int col, Set<String> visitedStates) -> List<Move>`
Returns capture moves with multi-jump support.
- Checks all 4 diagonal directions
- Validates jump is over enemy piece to empty square
- Recursively checks for additional jumps (multi-jump)
- Prevents infinite loops with visited states tracking

##### `_executeMove(int toRow, int toCol)`
Executes a move on the board.
- Moves piece to destination
- Removes captured pieces
- Promotes to king if reached end row
- Checks for forced continuation jumps
- Switches to next player if move complete

**Important Detail:** Multi-jumps keep the current player's turn active if more jumps are available after the current jump.

##### `_checkGameOver()`
Checks win/loss conditions:
1. Current player has no pieces left → opponent wins
2. Current player has no valid moves → opponent wins

##### `undoMove()`
Reverts the last move and restores game state.

## Game State Initialization

The board is initialized with:
- **Black pieces** (top): Rows 0, 1, 2 on all dark squares
- **White pieces** (bottom): Rows 5, 6, 7 on all dark squares
- **Black starts first**

## Movement Rules

### Regular Pieces
- Move diagonally forward only (1 square)
- Capture diagonally forward only (jump over opponent piece)
- Cannot move backward

### King Pieces
- Move diagonally in any direction (1 square)
- Capture diagonally in any direction (2 squares)
- Identified with gold star icon

### Capture Rules
- Mandatory capture: If a jump is available, it must be taken
- Multi-jump: If after jumping a piece can jump again, it must continue
- Captured pieces are removed immediately

### King Promotion
- When a regular piece reaches the opposite end (row 0 for white, row 7 for black), it becomes a king
- Kings are the only pieces that can move backward

## UI Integration

### CheckerBoard Widget
The `CheckerBoard` stateful widget provides:
- Visual representation of board
- Piece rendering with selection highlighting
- Valid move highlighting (green squares)
- Tap detection for piece selection and movement
- Callback to notify parent of game state changes

### GameScreen
Manages:
- Overall UI layout with player names
- Current turn display
- Game over notifications
- Move history display
- Undo button ("Back")
- Reset button
- Auto-rotate toggle (for local multiplayer)

## Usage Example

```dart
// Create a new game
CheckersGame game = CheckersGame();

// Select a piece
game.selectSquare(5, 1);  // Select white piece
List<Move> validMoves = game.validMoves;  // Get possible moves

// Make a move
game.selectSquare(4, 0);  // Move to valid destination

// Check game status
if (game.isGameOver) {
  print('${game.winner} wins!');
}

// Undo last move
game.undoMove();
```

## Testing

The widget can be tested by:
1. Running `flutter run` to launch the app
2. Navigating to the game screen
3. Selecting pieces (shown in gold)
4. Tapping valid moves (shown in green)
5. Capturing opponent pieces by jumping
6. Reaching the opposite end to promote to king (gold star appears)
7. Using "Back" button to undo moves
8. Using "Reset" button to restart the game

## Future Enhancements

Possible improvements:
- AI opponent implementation
- Game replay/review with forward/back navigation
- Animation of piece movement
- Sound effects (capture, move, win)
- Network multiplayer support
- Game statistics tracking
- More difficult checkers variants

## Technical Notes

- Board positions use 0-indexed arrays (0-7 for both row and col)
- Dark squares (playable squares) satisfy: `(row + col) % 2 == 1`
- The game uses immutable patterns where appropriate (Piece class)
- Board copying ensures move calculation doesn't affect game state
- Move history enables time-travel debugging and undo functionality
