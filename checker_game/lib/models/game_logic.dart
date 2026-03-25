import 'piece.dart';
import 'board_state.dart';
import 'move.dart';

class CheckersGame {
  late BoardState _board;
  late PieceColor _currentPlayer;
  int? _selectedRow;
  int? _selectedCol;
  
  // Tracks the active piece if a multi-jump sequence is in progress
  int? _midJumpRow;
  int? _midJumpCol;
  
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

  // --- NEW GETTERS ADDED HERE ---
  int? get midJumpRow => _midJumpRow;
  int? get midJumpCol => _midJumpCol;

  bool isPieceLocked(int row, int col) {
    return _midJumpRow == row && _midJumpCol == col;
  }
  // ------------------------------

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
    _midJumpRow = null;
    _midJumpCol = null;
    _moveHistory = [];
    _validMoves = [];
    _isGameOver = false;
    _winner = null;
  }

  void selectSquare(int row, int col) {
    // If the player is in the middle of a multi-jump sequence
    if (_midJumpRow != null && _midJumpCol != null) {
      if (isValidMove(row, col)) {
        _executeMove(row, col);
      }
      // Ignore clicks on anything other than valid multi-jump destinations
      return;
    }

    // If clicking on an empty square or opponent's piece
    if (_board.getPiece(row, col).isEmpty ||
        _board.getPiece(row, col).color != _currentPlayer) {
      if (isValidMove(row, col)) {
        _executeMove(row, col);
        return;
      }

      // Deselect if clicking an invalid area
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
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board.getPiece(row, col).color == _currentPlayer) {
          if (_getSingleJumpMoves(row, col).isNotEmpty) {
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

    // Forced capture rule: if any jump is available on the board, 
    // only jump moves are valid.
    if (_playerHasAnyJumpsAvailable()) {
      return _getSingleJumpMoves(row, col);
    }

    return _getRegularMoves(row, col);
  }

  List<Move> _getRegularMoves(int row, int col) {
    List<Move> moves = [];
    Piece piece = _board.getPiece(row, col);

    if (piece.isEmpty) return moves;

    List<List<int>> directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];

    for (var dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];

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

  // Refactored to only look exactly one jump ahead
  List<Move> _getSingleJumpMoves(int row, int col) {
    List<Move> moves = [];
    Piece piece = _board.getPiece(row, col);

    if (piece.isEmpty) return moves;

    List<List<int>> directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];

    for (var dir in directions) {
      int jumpRow = row + dir[0] * 2;
      int jumpCol = col + dir[1] * 2;
      int captureRow = row + dir[0];
      int captureCol = col + dir[1];

      if (!piece.isKing) {
        if (piece.color == PieceColor.black && dir[0] <= 0) continue;
        if (piece.color == PieceColor.white && dir[0] >= 0) continue;
      }

      if (_board.isValidSquare(jumpRow, jumpCol)) {
        Piece targetSquare = _board.getPiece(jumpRow, jumpCol);
        Piece capturedPiece = _board.getPiece(captureRow, captureCol);

        if (targetSquare.isEmpty && !capturedPiece.isEmpty &&
            capturedPiece.color != piece.color) {
          
          moves.add(Move(
            fromRow: row,
            fromCol: col,
            toRow: jumpRow,
            toCol: jumpCol,
            capturedPositions: [captureRow, captureCol],
          ));
        }
      }
    }

    return moves;
  }

  void _executeMove(int toRow, int toCol) {
    if (_selectedRow == null || _selectedCol == null) return;

    Move move = _validMoves.firstWhere(
      (m) => m.toRow == toRow && m.toCol == toCol,
      orElse: () => Move(fromRow: -1, fromCol: -1, toRow: -1, toCol: -1),
    );

    if (move.fromRow == -1) return; 

    Piece piece = _board.getPiece(_selectedRow!, _selectedCol!);
    bool justPromoted = false;

    // Execute standard movement
    _board.setPiece(toRow, toCol, piece);
    _board.removePiece(_selectedRow!, _selectedCol!);

    // Handle single capture step
    if (move.isJump && move.capturedPositions != null) {
      int captureRow = move.capturedPositions![0];
      int captureCol = move.capturedPositions![1];
      _board.removePiece(captureRow, captureCol);
    }

    // Promote to king if reached the end
    if ((piece.color == PieceColor.black && toRow == 7) ||
        (piece.color == PieceColor.white && toRow == 0)) {
      if (!piece.isKing) {
        _board.setPiece(toRow, toCol, piece.promoteToKing());
        justPromoted = true;
      }
    }

    _moveHistory.add(move);

    // Reset selection state
    _selectedRow = null;
    _selectedCol = null;
    _validMoves = [];

    // Evaluate continuing jumps for the SAME piece
    if (move.isJump && !justPromoted) {
      List<Move> continuingJumps = _getSingleJumpMoves(toRow, toCol);
      if (continuingJumps.isNotEmpty) {
        // Lock the player into finishing the jump sequence
        _midJumpRow = toRow;
        _midJumpCol = toCol;
        _selectedRow = toRow;
        _selectedCol = toCol;
        _validMoves = continuingJumps;
        return; // Turn does not end
      }
    }

    // Turn officially ends
    _midJumpRow = null;
    _midJumpCol = null;
    _currentPlayer =
        _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;

    _checkGameOver();
  }

  void _checkGameOver() {
    if (_board.countPieces(_currentPlayer) == 0) {
      _isGameOver = true;
      _winner = _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;
      return;
    }

    bool hasValidMoves = false;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board.getPiece(row, col).color == _currentPlayer) {
          if (_getValidMoves(row, col).isNotEmpty) {
            hasValidMoves = true;
            break;
          }
        }
      }
      if (hasValidMoves) break;
    }

    if (!hasValidMoves) {
      _isGameOver = true;
      _winner = _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;
    }
  }

  void undoMove() {
    if (_moveHistory.isEmpty) return;

    // Keep a copy of the history, minus the move we are undoing
    List<Move> historyToReplay = List.from(_moveHistory);
    historyToReplay.removeLast();

    // Wipe the board back to default
    reset();

    // Replay moves perfectly, recreating the exact game state 
    // (including mid-jump states if they undo to the middle of a combo)
    for (Move m in historyToReplay) {
      _selectedRow = m.fromRow;
      _selectedCol = m.fromCol;
      // Temporarily inject the valid move so executeMove accepts it
      _validMoves = [m]; 
      _executeMove(m.toRow, m.toCol);
    }
  }
}