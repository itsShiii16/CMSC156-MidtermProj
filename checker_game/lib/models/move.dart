class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final List<int>? capturedPositions; // List of [row, col] pairs for multiple jumps

  const Move({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    this.capturedPositions,
  });

  bool get isJump => capturedPositions != null && capturedPositions!.isNotEmpty;

  int get distance {
    int rowDiff = (toRow - fromRow).abs();
    int colDiff = (toCol - fromCol).abs();
    return rowDiff > colDiff ? rowDiff : colDiff;
  }

  @override
  String toString() => 'Move($fromRow,$fromCol -> $toRow,$toCol)${isJump ? ' [JUMP]' : ''}';
}
