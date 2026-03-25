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

  // Extracted directions to save memory and avoid recreating the list on every click
  static const List<List<int>> _directions = [
    [-1, -1], [-1, 1], [1, -1], [1, 1]
  ];

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

  int? get midJumpRow => _midJumpRow;
  int? get midJumpCol => _midJumpCol;

  bool isPieceLocked(int row, int col) {
    return _midJumpRow == row && _midJumpCol == col;
  }

  // Checks if a piece is a candidate for a mandatory jump
  bool isPieceMustJump(int row, int col) {
    if (_midJumpRow != null && _midJumpCol != null) {
      return isPieceLocked(row, col);
    }
    
    if (_board.getPiece(row, col).color == _currentPlayer) {
      return _getSingleJumpMoves(row, col).isNotEmpty;
    }
    
    return false;
  }

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
    if (_midJumpRow != null && _midJumpCol != null) {
      if (isValidMove(row, col)) {
        _executeMove(row, col);
      }
      return;
    }

    if (_board.getPiece(row, col).isEmpty ||
        _board.getPiece(row, col).color != _currentPlayer) {
      if (isValidMove(row, col)) {
        _executeMove(row, col);
        return;
      }

      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
      return;
    }

    if (_selectedRow == row && _selectedCol == col) {
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];
    } else {
      _selectedRow = row;
      _selectedCol = col;
      _validMoves = _getValidMoves(row, col);
    }
  }

  bool _playerHasAnyJumpsAvailable() {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board.getPiece(row, col).color == _currentPlayer) {
          if (_getSingleJumpMoves(row, col).isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  List<Move> _getValidMoves(int row, int col) {
    Piece piece = _board.getPiece(row, col);
    if (piece.isEmpty || piece.color != _currentPlayer) return [];

    if (_playerHasAnyJumpsAvailable()) {
      return _getSingleJumpMoves(row, col);
    }

    return _getRegularMoves(row, col);
  }

  List<Move> _getRegularMoves(int row, int col) {
    List<Move> moves = [];
    Piece piece = _board.getPiece(row, col);

    if (piece.isEmpty) return moves;

    for (var dir in _directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];

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

  List<Move> _getSingleJumpMoves(int row, int col) {
    List<Move> moves = [];
    Piece piece = _board.getPiece(row, col);

    if (piece.isEmpty) return moves;

    for (var dir in _directions) {
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

    _board.setPiece(toRow, toCol, piece);
    _board.removePiece(_selectedRow!, _selectedCol!);

    if (move.isJump && move.capturedPositions != null) {
      int captureRow = move.capturedPositions![0];
      int captureCol = move.capturedPositions![1];
      _board.removePiece(captureRow, captureCol);
    }

    if ((piece.color == PieceColor.black && toRow == 7) ||
        (piece.color == PieceColor.white && toRow == 0)) {
      if (!piece.isKing) {
        _board.setPiece(toRow, toCol, piece.promoteToKing());
        justPromoted = true;
      }
    }

    _moveHistory.add(move);

    _selectedRow = null;
    _selectedCol = null;
    _validMoves = [];

    if (move.isJump && !justPromoted) {
      List<Move> continuingJumps = _getSingleJumpMoves(toRow, toCol);
      if (continuingJumps.isNotEmpty) {
        _midJumpRow = toRow;
        _midJumpCol = toCol;
        _selectedRow = toRow;
        _selectedCol = toCol;
        _validMoves = continuingJumps;
        return; 
      }
    }

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

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board.getPiece(row, col).color == _currentPlayer) {
          if (_getValidMoves(row, col).isNotEmpty) return; // Exit early if a move exists
        }
      }
    }

    // If loop finishes without returning, player has no moves left
    _isGameOver = true;
    _winner = _currentPlayer == PieceColor.black ? PieceColor.white : PieceColor.black;
  }

  void undoMove() {
    if (_moveHistory.isEmpty) return;

    List<Move> historyToReplay = List.from(_moveHistory);
    historyToReplay.removeLast();

    reset();

    for (Move m in historyToReplay) {
      _selectedRow = m.fromRow;
      _selectedCol = m.fromCol;
      _validMoves = [m]; 
      _executeMove(m.toRow, m.toCol);
    }
  }
}