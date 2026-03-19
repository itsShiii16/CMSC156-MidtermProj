import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/checker_board.dart';
import '../widgets/profile_chip.dart';
import '../widgets/auto_rotate_toggle.dart';
import '../models/index.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isAutoRotateOn = true;
  CheckersGame? _gameState;
  List<String> _gameLog = [];

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
  }

  void _updateGameLog() {
    _gameLog = [];
    if (_gameState != null) {
      for (int i = 0; i < _gameState!.moveHistory.length; i++) {
        Move move = _gameState!.moveHistory[i];
        final player = i.isEven ? 'Black' : 'White';
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
      setState(() {
        _gameState!.undoMove();
        _updateGameLog();
      });
    }
  }

  void _resetGame() {
    setState(() {
      _gameState = CheckersGame();
      _gameLog = [];
    });
  }

  String _getCurrentPlayerName() {
    if (_gameState == null) return '';
    return _gameState!.currentPlayer == PieceColor.black
        ? 'Opponent (Black)'
        : 'G4bbiru (White)';
  }

  String _getGameStatus() {
    if (_gameState == null) return '';
    if (_gameState!.isGameOver) {
      String winner =
          _gameState!.winner == PieceColor.black ? 'Black (Opponent)' : 'White (G4bbiru)';
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
          onPressed: () => Navigator.pop(context),
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
                const ProfileChip(name: 'Opponent'),
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
                    interactive: true,
                    onGameStateChanged: _onGameStateChanged,
                    autoRotate: _isAutoRotateOn,
                  ),
                ),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ProfileChip(name: 'G4bbiru'),
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