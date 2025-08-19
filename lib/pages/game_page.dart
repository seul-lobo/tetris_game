import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/tetris_game.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_controls.dart';
import '../widgets/score_display.dart';
import '../utils/screen_utils.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  bool _showPauseMenu = false;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();

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
      context.read<TetrisGame>().startGame();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  void _togglePause(TetrisGame game) {
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

  void _showGameOverDialog(TetrisGame game) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(ScreenUtils.wp(6)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B1B3D), Color(0xFF4A1625)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_esports,
                  color: Colors.red,
                  size: ScreenUtils.getScaledSize(80),
                ),
                SizedBox(height: ScreenUtils.hp(2)),
                Text(
                  'GAME OVER',
                  style: ScreenUtils.getResponsiveTextStyle(
                    baseFontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ).copyWith(letterSpacing: 3),
                ),
                SizedBox(height: ScreenUtils.hp(3)),
                Container(
                  padding: EdgeInsets.all(ScreenUtils.wp(4)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'FINAL SCORE',
                        game.score.toString(),
                        Colors.cyan,
                      ),
                      SizedBox(height: ScreenUtils.hp(1)),
                      _buildStatRow(
                        'LEVEL REACHED',
                        game.level.toString(),
                        Colors.green,
                      ),
                      SizedBox(height: ScreenUtils.hp(1)),
                      _buildStatRow(
                        'LINES CLEARED',
                        game.linesCleared.toString(),
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                if (game.score >= game.highScore) ...[
                  SizedBox(height: ScreenUtils.hp(3)),
                  Container(
                    padding: EdgeInsets.all(ScreenUtils.wp(4)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.yellow.withValues(alpha: 0.3),
                          Colors.amber.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow, width: 2),
                    ),
                    child: Text(
                      '🏆 NEW HIGH SCORE! 🏆',
                      style: ScreenUtils.getResponsiveTextStyle(
                        baseFontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: ScreenUtils.hp(4)),
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
                    SizedBox(width: ScreenUtils.wp(3)),
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
          style: ScreenUtils.getResponsiveTextStyle(
            baseFontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: ScreenUtils.getResponsiveTextStyle(
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
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
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: ScreenUtils.hp(1.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: ScreenUtils.getScaledSize(20)),
          SizedBox(width: ScreenUtils.wp(2)),
          Text(
            text,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseMenu(TetrisGame game) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Container(
          margin: ScreenUtils.getResponsivePadding(),
          padding: EdgeInsets.all(ScreenUtils.wp(8)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2B1B3D), Color(0xFF4A1625)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_filled,
                color: Colors.white,
                size: ScreenUtils.getScaledSize(64),
              ),
              SizedBox(height: ScreenUtils.hp(2)),
              Text(
                'GAME PAUSED',
                style: ScreenUtils.getResponsiveTextStyle(
                  baseFontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ).copyWith(letterSpacing: 3),
              ),
              SizedBox(height: ScreenUtils.hp(5)),
              _buildPauseButton(
                'RESUME',
                Icons.play_arrow,
                Colors.green,
                () => _togglePause(game),
              ),
              SizedBox(height: ScreenUtils.hp(2)),
              _buildPauseButton('RESTART', Icons.refresh, Colors.orange, () {
                setState(() {
                  _showPauseMenu = false;
                });
                game.resetGame();
                game.startGame();
              }),
              SizedBox(height: ScreenUtils.hp(2)),
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
      height: ScreenUtils.hp(7),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
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
            Icon(icon, size: ScreenUtils.getScaledSize(24)),
            SizedBox(width: ScreenUtils.wp(3)),
            Text(
              text,
              style: ScreenUtils.getResponsiveTextStyle(
                baseFontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPieceGridInHeader(TetrisGame game) {
    if (game.nextPiece == null) return const SizedBox.shrink();

    final piece = game.nextPiece!;
    List<List<int>> positions = piece.tetrominos[piece.type]![0];

    // Find bounding box
    int minRow = positions.map((pos) => pos[0]).reduce((a, b) => a < b ? a : b);
    int maxRow = positions.map((pos) => pos[0]).reduce((a, b) => a > b ? a : b);
    int minCol = positions.map((pos) => pos[1]).reduce((a, b) => a < b ? a : b);
    int maxCol = positions.map((pos) => pos[1]).reduce((a, b) => a > b ? a : b);

    int pieceWidth = maxCol - minCol + 1;
    int pieceHeight = maxRow - minRow + 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 16, // 4x4 grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        mainAxisSpacing: 0.5,
        crossAxisSpacing: 0.5,
      ),
      itemBuilder: (context, index) {
        int row = index ~/ 4;
        int col = index % 4;

        // Center the piece perfectly in the 4x4 grid
        double centerOffsetRow = (4 - pieceHeight) / 2.0;
        double centerOffsetCol = (4 - pieceWidth) / 2.0;

        bool isPartOfPiece = positions.any((pos) {
          double pieceRow = (pos[0] - minRow) + centerOffsetRow;
          double pieceCol = (pos[1] - minCol) + centerOffsetCol;

          // Check if this grid cell contains the piece part (with tolerance for centering)
          return (pieceRow >= row && pieceRow < row + 1) &&
              (pieceCol >= col && pieceCol < col + 1);
        });

        return Container(
          decoration: BoxDecoration(
            color: isPartOfPiece
                ? piece.color.withValues(alpha: 0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border: isPartOfPiece
                ? Border.all(
                    color: piece.color.withValues(alpha: 0.7),
                    width: 0.5,
                  )
                : null,
            boxShadow: isPartOfPiece
                ? [
                    BoxShadow(
                      color: piece.color.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : null,
          ),
        );
      },
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
          child: Consumer<TetrisGame>(
            builder: (context, game, child) {
              if (game.isGameOver && !_showPauseMenu) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showGameOverDialog(game);
                });
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      // Header with ScoreDisplay, NextPiece, and Pause Button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtils.wp(4),
                          vertical: ScreenUtils.hp(1),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Score Display
                            Expanded(
                              flex: 2,
                              child: AnimatedBuilder(
                                animation: _scoreAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scoreAnimation.value,
                                    child: ScoreDisplay(game: game),
                                  );
                                },
                              ),
                            ),

                            // Next Piece Display in the middle
                            Container(
                              width: ScreenUtils.wp(20),
                              height: ScreenUtils.wp(20),
                              margin: EdgeInsets.symmetric(
                                horizontal: ScreenUtils.wp(2),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1A2A3E),
                                    Color(0xFF2A4D7A).withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: game.nextPiece != null
                                          ? _buildNextPieceGridInHeader(game)
                                          : Center(
                                              child: Icon(
                                                Icons.help_outline,
                                                color: Colors.white.withValues(
                                                  alpha: 0.3,
                                                ),
                                                size: 12,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Pause Button
                            IconButton(
                              onPressed: () => _togglePause(game),
                              icon: Icon(
                                game.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: ScreenUtils.getScaledSize(28),
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    (game.isPlaying
                                            ? Colors.orange
                                            : Colors.green)
                                        .withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main content - Grid takes maximum space
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.wp(4),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: ScreenUtils.hp(1),
                              ), // Reduced top spacing
                              // Game Grid - takes all available space
                              Expanded(
                                child: Center(
                                  child: GameGrid(
                                    game: game,
                                    rows: 15, // All 15 rows visible
                                    cellSize: ScreenUtils.getOptimalCellSize(),
                                  ),
                                ),
                              ),

                              // Small spacing before controls
                            ],
                          ),
                        ),
                      ),

                      // Game Controls - Fixed at Bottom
                      Container(
                        padding: EdgeInsets.only(bottom: ScreenUtils.hp(1)),
                        child: GameControls(game: game),
                      ),
                    ],
                  ),
                  if (_showPauseMenu) _buildPauseMenu(game),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
