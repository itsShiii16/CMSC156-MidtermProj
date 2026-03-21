import 'piece.dart';
import 'board_state.dart';
import 'move.dart';

class CheckersGame {
  late BoardState _board;
  late PieceColor _currentPlayer;
  int? _selectedRow;
  int? _selectedCol;
  List<Move> _moveHistory = [];
  List<Move> _validMoves = [];
  bool _isGameOver = false;
  PieceColor? _winner;

  CheckersGame() {
    reset();
  }

  // Getters
  BoardState get board => _board;
  PieceColor get currentPlayer => _currentPlayer;
  bool get isGameOver => _isGameOver;
  PieceColor? get winner => _winner;
  List<List<Piece>> get boardState => _board.board;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  List<Move> get validMoves => _validMoves;
  List<Move> get moveHistory => _moveHistory;

  bool isSelected(int row, int col) {
    return _selectedRow == row && _selectedCol == col;
  }

  bool isValidMove(int row, int col) {
    return _validMoves.any((move) => move.toRow == row && move.toCol == col);
  }

  void reset() {
    _board = BoardState();
    _currentPlayer = PieceColor.black;
    _selectedRow = null;
    _selectedCol = null;
    _moveHistory = [];
    _validMoves = [];
    _isGameOver = false;
    _winner = null;
  }

  void selectSquare(int row, int col) {
    // If clicking on an empty square or opponent's piece
    if (_board.getPiece(row, col).isEmpty ||
        _board.getPiece(row, col).color != _currentPlayer) {
      // Check if this is a valid move destination
      if (isValidMove(row, col)) {
        _executeMove(row, col);
        return;
      }

      // If already selected, deselect
      if (_selectedRow == row && _selectedCol == col) {
        _selectedRow = null;
        _selectedCol = null;
        _validMoves = [];
        return;
      }

      // Deselect and don't select the new square
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
      return;
    }

    // If clicking on current player's piece
    if (_selectedRow == row && _selectedCol == col) {
      // Deselect
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
    } else {
      // Select new piece
      _selectedRow = row;
      _selectedCol = col;
      _validMoves = _getValidMoves(row, col);
    }
  }

  bool _playerHasAnyJumpsAvailable() {
    // Check if current player has any mandatory jumps available anywhere on the board
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board.getPiece(row, col).color == _currentPlayer) {
          List<Move> jumpMoves = _getJumpMoves(row, col, {});
          if (jumpMoves.isNotEmpty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List<Move> _getValidMoves(int row, int col) {
    Piece piece = _board.getPiece(row, col);
    if (piece.isEmpty || piece.color != _currentPlayer) {
      return [];
    }

    // Check if any jumps are available for the current player on the board
    bool playerHasJumps = _playerHasAnyJumpsAvailable();
    if (playerHasJumps) {
      // If jumps are available anywhere, only return jumps for this piece
      return _getJumpMoves(row, col, {});
    }

    // If no jumps available, return regular moves
    return _getRegularMoves(row, col);
  }

  List<Move> _getRegularMoves(int row, int col) {
    List<Move> moves = [];
    Piece piece = _board.getPiece(row, col);

    if (piece.isEmpty) return moves;

    // Direction offsets: up-left, up-right, down-left, down-right
    List<List<int>> directions = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1],
    ];

    for (var dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];

      // Kings can move in any diagonal direction
      // Regular pieces can only move forward
      if (!piece.isKing) {
        if (piece.color == PieceColor.black && dir[0] <= 0) continue;
        if (piece.color == PieceColor.white && dir[0] >= 0) continue;
      }

      if (_board.isValidSquare(newRow, newCol) &&
          _board.getPiece(newRow, newCol).isEmpty) {
        moves.add(Move(
          fromRow: row,
          fromCol: col,
          toRow: newRow,
          toCol: newCol,
        ));
      }
    }

    return moves;
  }

  List<Move> _getJumpMoves(int row, int col, Set<String> visitedStates) {
    List<Move> moves = [];
    Piece piece = _board.getPiece(row, col);

    if (piece.isEmpty) return moves;

    // Direction offsets
    List<List<int>> directions = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1],
    ];

    for (var dir in directions) {
      int jumpRow = row + dir[0] * 2;
      int jumpCol = col + dir[1] * 2;
      int captureRow = row + dir[0];
      int captureCol = col + dir[1];

      // Kings can jump in any direction
      // Regular pieces can only jump forward
      if (!piece.isKing) {
        if (piece.color == PieceColor.black && dir[0] <= 0) continue;
        if (piece.color == PieceColor.white && dir[0] >= 0) continue;
      }

      if (_board.isValidSquare(jumpRow, jumpCol)) {
        Piece targetSquare = _board.getPiece(jumpRow, jumpCol);
        Piece capturedPiece = _board.getPiece(captureRow, captureCol);

        if (targetSquare.isEmpty && !capturedPiece.isEmpty &&
            capturedPiece.color != piece.color) {
          // Valid jump found
          String stateKey = '$jumpRow,$jumpCol';
          if (!visitedStates.contains(stateKey)) {
            Set<String> newVisited = {...visitedStates, stateKey};

            // Tentatively make the jump
            BoardState tempBoard = _board.copy();
            _board.setPiece(jumpRow, jumpCol, piece);
            _board.removePiece(row, col);
            _board.removePiece(captureRow, captureCol);

            // Check for additional jumps
            List<Move> multiJumps =
                _getJumpMoves(jumpRow, jumpCol, newVisited);

            if (multiJumps.isNotEmpty) {
              // Multiple jumps available
              for (var multiMove in multiJumps) {
                moves.add(Move(
                  fromRow: row,
                  fromCol: col,
                  toRow: multiMove.toRow,
                  toCol: multiMove.toCol,
                  capturedPositions: [
                    captureRow,
                    captureCol,
                    ...(multiMove.capturedPositions ?? [])
                  ],
                ));
              }
            } else {
              // Single jump
              moves.add(Move(
                fromRow: row,
                fromCol: col,
                toRow: jumpRow,
                toCol: jumpCol,
                capturedPositions: [captureRow, captureCol],
              ));
            }

            // Restore the board
            _board = tempBoard;
          }
        }
      }
    }

    return moves;
  }

  void _executeMove(int toRow, int toCol) {
    if (_selectedRow == null || _selectedCol == null) return;

    Move? move = _validMoves.firstWhere(
      (m) => m.toRow == toRow && m.toCol == toCol,
      orElse: () => Move(
        fromRow: -1,
        fromCol: -1,
        toRow: -1,
        toCol: -1,
      ),
    );

    if (move.fromRow == -1) return; // Invalid move

    Piece piece = _board.getPiece(_selectedRow!, _selectedCol!);

    // Move the piece
    _board.setPiece(toRow, toCol, piece);
    _board.removePiece(_selectedRow!, _selectedCol!);

    // Handle captures
    if (move.isJump && move.capturedPositions != null) {
      for (int i = 0; i < move.capturedPositions!.length; i += 2) {
        int captureRow = move.capturedPositions![i];
        int captureCol = move.capturedPositions![i + 1];
        _board.removePiece(captureRow, captureCol);
      }
    }

    // Promote to king if reached the end
    if ((piece.color == PieceColor.black && toRow == 7) ||
        (piece.color == PieceColor.white && toRow == 0)) {
      _board.setPiece(toRow, toCol, piece.promoteToKing());
    }

    // Record move
    _moveHistory.add(move);

    // Update game state
    _selectedRow = null;
    _selectedCol = null;
    _validMoves = [];

    // Check if current player must continue jumping
    if (move.isJump) {
      List<Move> continuingJumps = _getJumpMoves(toRow, toCol, {});
      if (continuingJumps.isNotEmpty) {
        _selectedRow = toRow;
        _selectedCol = toCol;
        _validMoves = continuingJumps;
        return; // Same player continues
      }
    }

    // Switch player
    _currentPlayer =
        _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;

    // Check if game is over
    _checkGameOver();
  }

  void _checkGameOver() {
    // Check if current player has any pieces left
    if (_board.countPieces(_currentPlayer) == 0) {
      _isGameOver = true;
      _winner =
          _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;
      return;
    }

    // Check if current player has any valid moves
    bool hasValidMoves = false;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board.getPiece(row, col).color == _currentPlayer) {
          List<Move> moves = _getValidMoves(row, col);
          if (moves.isNotEmpty) {
            hasValidMoves = true;
            break;
          }
        }
      }
      if (hasValidMoves) break;
    }

    if (!hasValidMoves) {
      _isGameOver = true;
      _winner =
          _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;
    }
  }

  void undoMove() {
    if (_moveHistory.isEmpty) return;

    _moveHistory.removeLast();
    _board.reset();

    // Replay all moves except the last one
    for (Move move in _moveHistory) {
      _replayMove(move);
    }

    // Restore game state
    _currentPlayer =
        _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;
    _selectedRow = null;
    _selectedCol = null;
    _validMoves = [];
    _isGameOver = false;
    _winner = null;
  }

  void _replayMove(Move move) {
    Piece piece = _board.getPiece(move.fromRow, move.fromCol);
    _board.setPiece(move.toRow, move.toCol, piece);
    _board.removePiece(move.fromRow, move.fromCol);

    if (move.isJump && move.capturedPositions != null) {
      for (int i = 0; i < move.capturedPositions!.length; i += 2) {
        int captureRow = move.capturedPositions![i];
        int captureCol = move.capturedPositions![i + 1];
        _board.removePiece(captureRow, captureCol);
      }
    }

    if ((piece.color == PieceColor.black && move.toRow == 7) ||
        (piece.color == PieceColor.white && move.toRow == 0)) {
      _board.setPiece(move.toRow, move.toCol, piece.promoteToKing());
    }
  }
}
