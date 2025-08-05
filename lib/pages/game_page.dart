import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/tetris_game.dart';
import '../widgets/game_grid.dart';
import '../widgets/next_piece_display.dart';
import '../widgets/game_controls.dart';
import '../widgets/score_display.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late TetrisGame game;
  bool _showPauseMenu = false;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    game = TetrisGame();

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0D1421),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      game.startGame();
    });

    game.addListener(_onGameStateChanged);
  }

  int _previousScore = 0;

  void _onGameStateChanged() {
    if (game.score > _previousScore) {
      _scoreAnimationController.forward().then((_) {
        _scoreAnimationController.reverse();
      });
      _previousScore = game.score;
    }
  }

  @override
  void dispose() {
    game.removeListener(_onGameStateChanged);
    game.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _togglePause() {
    HapticFeedback.mediumImpact();
    if (game.isPlaying) {
      game.pauseGame();
      setState(() {
        _showPauseMenu = true;
      });
    } else {
      game.resumeGame();
      setState(() {
        _showPauseMenu = false;
      });
    }
  }

  void _showGameOverDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B1B3D), Color(0xFF4A1625)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_esports, color: Colors.red, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'FINAL SCORE',
                        game.score.toString(),
                        Colors.cyan,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        'LEVEL REACHED',
                        game.level.toString(),
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        'LINES CLEARED',
                        game.linesCleared.toString(),
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                if (game.score >= game.highScore) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.withOpacity(0.3),
                          Colors.amber.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: const Text(
                      '🏆 NEW HIGH SCORE! 🏆',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogButton(
                        'PLAY AGAIN',
                        Icons.refresh,
                        Colors.green,
                        () {
                          Navigator.of(context).pop();
                          game.resetGame();
                          game.startGame();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDialogButton(
                        'MENU',
                        Icons.home,
                        Colors.red,
                        () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B1B3D), Color(0xFF4A1625)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_filled,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'GAME PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 40),
              _buildPauseButton(
                'RESUME',
                Icons.play_arrow,
                Colors.green,
                () => _togglePause(),
              ),
              const SizedBox(height: 16),
              _buildPauseButton('RESTART', Icons.refresh, Colors.orange, () {
                setState(() {
                  _showPauseMenu = false;
                });
                game.resetGame();
                game.startGame();
              }),
              const SizedBox(height: 16),
              _buildPauseButton(
                'MENU',
                Icons.home,
                Colors.red,
                () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 2),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1421),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: game,
            builder: (context, child) {
              if (game.isGameOver && !_showPauseMenu) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showGameOverDialog();
                });
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      // Header with ScoreDisplay on left and Pause on right
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _scoreAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scoreAnimation.value,
                                  child: ScoreDisplay(game: game),
                                );
                              },
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: _togglePause,
                              icon: Icon(
                                game.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    (game.isPlaying
                                            ? Colors.orange
                                            : Colors.green)
                                        .withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Main content with flexible layout
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Full-width GameGrid with larger boxes and reduced rows
                              SizedBox(
                                width: double.infinity,
                                child: GameGrid(
                                  game: game,
                                  rows: 12,
                                  boxSize:
                                      MediaQuery.of(context).size.width * 0.09,
                                ),
                              ),
                              SizedBox(height: 10),
                              // NextPieceDisplay spanning width with drop buttons
                              SizedBox(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: NextPieceDisplay(game: game),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Game Controls - Fixed at Bottom
                      Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: GameControls(game: game),
                      ),
                    ],
                  ),
                  if (_showPauseMenu) _buildPauseMenu(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
