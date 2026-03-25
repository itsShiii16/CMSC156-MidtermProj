enum PieceColor { white, black, empty }

enum PieceType { regular, king }

class Piece {
  final String id; // <-- 1. Added ID for animation tracking
  final PieceColor color;
  final PieceType type;

  const Piece({
    required this.id, // <-- 2. ID is now required
    required this.color,
    this.type = PieceType.regular,
  });

  bool get isEmpty => color == PieceColor.empty;

  bool get isKing => type == PieceType.king;

  // Create an empty piece
  // All empty squares can share the 'empty' ID since they don't animate
  const Piece.empty() 
      : id = 'empty', 
        color = PieceColor.empty, 
        type = PieceType.regular;

  // Promote to king
  Piece promoteToKing() {
    return Piece(
      id: id, // <-- 3. Keep the exact same ID so the slide animation doesn't break!
      color: color,
      type: PieceType.king,
    );
  }

  @override
  String toString() => '${color.name}_${type.name}_$id';
}