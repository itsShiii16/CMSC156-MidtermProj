import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_colors.dart';
import '../widgets/checker_board.dart';
import '../widgets/profile_chip.dart';
import '../widgets/auto_rotate_toggle.dart';
import '../models/index.dart';
import '../services/settings_service.dart';

class GameScreen extends StatefulWidget {
  final String player1Name;
  final String player2Name;

  const GameScreen({
    super.key,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late bool _isAutoRotateOn;
  bool _hasShownGameOverFlow = false;
  final Random _random = Random();
  late PieceColor _player1Color;
  int _boardResetVersion = 0;
  CheckersGame? _gameState;
  List<String> _gameLog = [];
  Set<String> _undoHighlightedSquares = {};
  Timer? _undoHighlightTimer;

  @override
  void initState() {
    super.initState();
    final settingsService = SettingsService();
    _isAutoRotateOn = settingsService.autoRotateDefault;
    _startNewGame();
  }

  PieceColor get _player2Color =>
      _player1Color == PieceColor.black ? PieceColor.white : PieceColor.black;

  String _colorLabel(PieceColor color) {
    return color == PieceColor.black ? 'Black' : 'White';
  }

  String _playerNameByColor(PieceColor color) {
    return color == _player1Color ? widget.player1Name : widget.player2Name;
  }

  String _playerLabelByColor(PieceColor color) {
    return '${_playerNameByColor(color)} (${_colorLabel(color)})';
  }

  void _startNewGame() {
    _player1Color = _random.nextBool() ? PieceColor.black : PieceColor.white;
    _resetCurrentGame();
  }

  void _resetCurrentGame() {
    // Reset game state while preserving player colors
    _gameState = CheckersGame();
    _gameLog = [];
    _undoHighlightedSquares = {};
    _hasShownGameOverFlow = false;
    _boardResetVersion++;
  }

  String _squareKey(int row, int col) => '$row,$col';

  Set<String> _getSquaresFromMove(Move move) {
    final squares = <String>{
      _squareKey(move.fromRow, move.fromCol),
      _squareKey(move.toRow, move.toCol),
    };

    if (move.capturedPositions != null) {
      for (int i = 0; i < move.capturedPositions!.length; i += 2) {
        squares.add(_squareKey(move.capturedPositions![i], move.capturedPositions![i + 1]));
      }
    }

    return squares;
  }

  void _showUndoHighlights(Set<String> highlightedSquares) {
    _undoHighlightTimer?.cancel();
    _undoHighlightedSquares = highlightedSquares;
    _undoHighlightTimer = Timer(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() {
        _undoHighlightedSquares = {};
      });
    });
  }

  String _toBoardSquare(int row, int col) {
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final rank = 8 - row;
    return '${files[col]}$rank';
  }

  void _onGameStateChanged(CheckersGame game) {
    setState(() {
      _gameState = game;
      _updateGameLog();
    });

    if (game.isGameOver) {
      _maybeShowEndGameFlow();
    } else {
      _hasShownGameOverFlow = false;
    }
  }

  void _maybeShowEndGameFlow() {
    if (_hasShownGameOverFlow || _gameState == null || !_gameState!.isGameOver) {
      return;
    }

    final winnerColor = _gameState!.winner;
    if (winnerColor == null) return;

    _hasShownGameOverFlow = true;
    final winnerName = _playerNameByColor(winnerColor);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final action = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('$winnerName Wins!'),
            content: const Text('What would you like to do next?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'quit'),
                child: const Text('Quit'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, 'playAgain'),
                child: const Text('Play Again'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      if (action == 'playAgain') {
        setState(() {
          _resetCurrentGame();
        });
      } else if (action == 'quit') {
        Navigator.pop(context);
      }
    });
  }

  void _updateGameLog() {
    _gameLog = [];
    if (_gameState != null) {
      for (int i = 0; i < _gameState!.moveHistory.length; i++) {
        Move move = _gameState!.moveHistory[i];
        final movingColor = i.isEven ? PieceColor.black : PieceColor.white;
        final player = _playerLabelByColor(movingColor);
        final from = _toBoardSquare(move.fromRow, move.fromCol);
        final to = _toBoardSquare(move.toRow, move.toCol);
        final action = move.isJump ? 'captures' : 'to';
        String moveStr = '${i + 1}. $player: $from $action $to';
        _gameLog.add(moveStr);
      }
    }
  }

  void _undoMove() {
    if (_gameState != null && _gameState!.moveHistory.isNotEmpty) {
      final undoneMove = _gameState!.moveHistory.last;
      final undoSquares = _getSquaresFromMove(undoneMove);

      setState(() {
        _gameState!.undoMove();
        _updateGameLog();
        _showUndoHighlights(undoSquares);
      });
    }
  }

  void _resetGame() {
    _undoHighlightTimer?.cancel();
    setState(() {
      _resetCurrentGame();
    });
  }

  void _confirmQuit() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quit Game?'),
          content: const Text('Are you sure you want to quit? The current game will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redNotif,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Quit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _undoHighlightTimer?.cancel();
    super.dispose();
  }

  String _getCurrentPlayerName() {
    if (_gameState == null) return '';
    final currentColor = _gameState!.currentPlayer;
    return _playerLabelByColor(currentColor);
  }

  String _getGameStatus() {
    if (_gameState == null) return '';
    if (_gameState!.isGameOver) {
      final winnerColor = _gameState!.winner;
      if (winnerColor == null) return 'Game Over';
      String winner = _playerLabelByColor(winnerColor);
      return 'Game Over - $winner Wins!';
    }
    return 'Current: ${_getCurrentPlayerName()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.screenFrame),
          onPressed: _confirmQuit,
        ),
        title: const Text(
          'Play in Person',
          style: TextStyle(
              color: AppColors.screenFrame, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProfileChip(name: _playerLabelByColor(_player2Color)),
                const SizedBox(height: 8),
                Text(
                  _getGameStatus(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.screenFrame,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              color: AppColors.beige,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CheckerBoard(
                    key: ValueKey(_boardResetVersion),
                    interactive: true,
                    onGameStateChanged: _onGameStateChanged,
                    autoRotate: _isAutoRotateOn,
                    undoHighlightedSquares: _undoHighlightedSquares,
                  ),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ProfileChip(name: _playerLabelByColor(_player1Color)),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Group 1: The two arrow icon AND the toggle switch
                Row(
                  children: [
                    const Icon(Icons.swap_vert, size: 32),
                    const SizedBox(width: 16),
                    AutoRotateToggle(
                      value: _isAutoRotateOn,
                      onChanged: (newValue) {
                        setState(() {
                          _isAutoRotateOn = newValue;
                        });
                      },
                    ),
                  ],
                ),
                
                // Group 2: The Back and Reset controls
                Row(
                  children: [
                    GestureDetector(
                      onTap: _undoMove,
                      child: Column(
                        children: const [
                          Icon(Icons.chevron_left, size: 32),
                          Text('Back', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: _resetGame,
                      child: Column(
                        children: const [
                          Icon(Icons.refresh, size: 32),
                          Text('Reset', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Keep this footer mounted at all times so board size stays stable.
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: AppColors.screenFrame.withOpacity(0.04),
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.08)),
              ),
            ),
            child: _gameLog.isEmpty
                ? const SizedBox.expand()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _gameLog.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.screenFrame.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _gameLog[index],
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.screenFrame.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}