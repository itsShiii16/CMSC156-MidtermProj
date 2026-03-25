import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/index.dart';
import 'pulsing_highlight.dart';

class CheckerBoard extends StatefulWidget {
  final bool interactive;
  final Function(CheckersGame)? onGameStateChanged;
  final bool autoRotate;
  final Set<String> undoHighlightedSquares;

  const CheckerBoard({
    super.key,
    this.interactive = false,
    this.onGameStateChanged,
    this.autoRotate = true,
    this.undoHighlightedSquares = const {},
  });

  @override
  State<CheckerBoard> createState() => _CheckerBoardState();
}

class _CheckerBoardState extends State<CheckerBoard> {
  late CheckersGame _game;

  @override
  void initState() {
    super.initState();
    _game = CheckersGame();
  }

  void _onSquareTapped(int row, int col) {
    if (!widget.interactive || _game.isGameOver) return;

    setState(() {
      _game.selectSquare(row, col);
      widget.onGameStateChanged?.call(_game);
    });
  }

  @override
  Widget build(BuildContext context) {
    double rotationAngle = widget.autoRotate && _game.currentPlayer == PieceColor.black
        ? 3.14159 
        : 0;

    return Transform.rotate(
      angle: rotationAngle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double squareSize = constraints.maxWidth / 8;

          return Stack(
            children: [
              // LAYER 1: The Background Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  bool isDark = (row + col) % 2 == 1;

                  bool isSelected = _game.isSelected(row, col);
                  bool isValidMoveDestination = _game.isValidMove(row, col);
                  bool isUndoHighlighted = widget.undoHighlightedSquares.contains('$row,$col');

                  Color backgroundColor = isDark ? AppColors.boardDark : AppColors.boardLight;

                  if (isSelected) {
                    backgroundColor = AppColors.gold.withOpacity(0.5);
                  } else if (isValidMoveDestination) {
                    backgroundColor = AppColors.greenOn.withOpacity(0.4);
                  } else if (isUndoHighlighted) {
                    backgroundColor = AppColors.gold.withOpacity(0.28);
                  }

                  final String? fileLabel = row == 7 ? String.fromCharCode(97 + col) : null;
                  final String? rankLabel = col == 0 ? '${8 - row}' : null;

                  return GestureDetector(
                    onTap: () => _onSquareTapped(row, col),
                    child: Container(
                      color: backgroundColor,
                      child: Stack(
                        children: [
                          if (fileLabel != null)
                            Positioned(
                              right: 3,
                              bottom: 2,
                              child: Transform.rotate(
                                angle: rotationAngle,
                                child: Text(
                                  fileLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: (isDark ? AppColors.whitePiece : AppColors.screenFrame)
                                        .withOpacity(0.42),
                                  ),
                                ),
                              ),
                            ),
                          if (rankLabel != null)
                            Positioned(
                              left: 3,
                              top: 2,
                              child: Transform.rotate(
                                angle: rotationAngle,
                                child: Text(
                                  rankLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: (isDark ? AppColors.whitePiece : AppColors.screenFrame)
                                        .withOpacity(0.42),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // LAYER 2: The Animated Pieces Overlay
              ..._buildAnimatedPieces(squareSize),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildAnimatedPieces(double squareSize) {
    List<Widget> pieces = [];
    bool isMidJumpSequence = _game.midJumpRow != null;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        Piece piece = _game.board.getPiece(row, col);
        
        if (!piece.isEmpty) {
          bool isSelected = _game.isSelected(row, col);
          
          // --- UPDATED LOGIC HERE ---
          // Ask the game if this piece is forced to jump (either first jump or mid-combo)
          bool mustJump = _game.isPieceMustJump(row, col);
          
          // We still need to know if it's the explicitly locked piece for the dimming effect
          bool isLockedPiece = _game.isPieceLocked(row, col);

          Widget pieceWidget = _buildPieceWidget(piece, isSelected);

          // Now it pulses if it MUST jump
          pieceWidget = PulsingHighlight(
            isPulsing: mustJump,
            highlightColor: AppColors.gold,
            child: pieceWidget,
          );

          // Dimming effect remains unchanged (only dims others during a mid-jump combo)
          if (isMidJumpSequence && !isLockedPiece) {
            pieceWidget = Opacity(opacity: 0.4, child: pieceWidget);
          }

          pieces.add(
            AnimatedPositioned(
              key: ValueKey(piece.id), 
              duration: const Duration(milliseconds: 300), 
              curve: Curves.easeInOutCubic,
              top: row * squareSize,
              left: col * squareSize,
              width: squareSize,
              height: squareSize,
              child: GestureDetector(
                onTap: () => _onSquareTapped(row, col),
                child: Center(child: pieceWidget),
              ),
            ),
          );
        }
      }
    }
    return pieces;
  }

  Widget _buildPieceWidget(Piece piece, bool isSelected) {
    Color pieceColor = piece.color == PieceColor.white
        ? AppColors.whitePiece
        : AppColors.blackPiece;

    double radius = isSelected ? 18 : 16;
    Color borderColor =
        piece.color == PieceColor.white ? Colors.black : Colors.white;
    double borderWidth = piece.isKing ? 3 : 1;

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          backgroundColor: pieceColor,
          radius: radius,
          child: piece.isKing
              ? Icon(
                  Icons.star,
                  color: AppColors.gold,
                  size: radius,
                )
              : null,
        ),
        if (piece.isKing)
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
          )
      ],
    );
  }
}