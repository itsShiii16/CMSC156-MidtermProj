import 'piece.dart';

class BoardState {
  late List<List<Piece>> _board;

  BoardState() {
    _initializeBoard();
  }

  // Copy constructor
  BoardState.fromBoard(List<List<Piece>> board) {
    _board = [
      for (int i = 0; i < 8; i++)
        [
          for (int j = 0; j < 8; j++)
            board[i][j]
        ]
    ];
  }

void _initializeBoard() {
    _board = List.generate(8, (i) => List.generate(8, (j) => const Piece.empty()));

    int whiteIdCounter = 0;
    // Place white pieces (bottom rows: 5, 6, 7)
    for (int row = 5; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 == 1) {
          _board[row][col] = Piece(id: 'w_${whiteIdCounter++}', color: PieceColor.white);
        }
      }
    }

    int blackIdCounter = 0;
    // Place black pieces (top rows: 0, 1, 2)
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 8; col++) {
        if ((row + col) % 2 == 1) {
          _board[row][col] = Piece(id: 'b_${blackIdCounter++}', color: PieceColor.black);
        }
      }
    }
  }
  
  Piece getPiece(int row, int col) {
    if (row < 0 || row >= 8 || col < 0 || col >= 8) {
      return const Piece.empty();
    }
    return _board[row][col];
  }

  void setPiece(int row, int col, Piece piece) {
    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
      _board[row][col] = piece;
    }
  }

  void removePiece(int row, int col) {
    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
      _board[row][col] = const Piece.empty();
    }
  }

  bool isValidPosition(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool isValidSquare(int row, int col) {
    return isValidPosition(row, col) && (row + col) % 2 == 1;
  }

  List<List<Piece>> get board => _board;

  int countPieces(PieceColor color) {
    int count = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (_board[row][col].color == color) {
          count++;
        }
      }
    }
    return count;
  }

  void reset() {
    _initializeBoard();
  }

  // Create a deep copy of the board
  BoardState copy() {
    return BoardState.fromBoard(_board);
  }
}
