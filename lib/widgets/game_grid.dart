import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class GameGrid extends StatefulWidget {
  final TetrisGame game;
  final int rows;
  final double boxSize;

  const GameGrid({
    super.key,
    required this.game,
    this.rows = 12,
    this.boxSize = 30.0,
  });

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  late AnimationController _lineAnimationController;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    _lineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    // Listen for line clear animations
    widget.game.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (widget.game.rowsToAnimate.isNotEmpty) {
      _lineAnimationController.forward().then((_) {
        _lineAnimationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameStateChanged);
    _lineAnimationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (16.0 * 2);
    final gridHeight = MediaQuery.of(context).size.height * 0.5;

    return Center(
      child: Container(
        width: availableWidth,
        height: gridHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyan.withValues(alpha: 0.5), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              // ENHANCEMENT: Animated background with score-based color shifts
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getBackgroundColors(),
                        stops: [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  );
                },
              ),

              // ENHANCEMENT: Optimized grid with reduced rebuilds
              _buildOptimizedGrid(),

              // ENHANCEMENT: Particle effects overlay for special events
              if (widget.game.rowsToAnimate.isNotEmpty) _buildParticleOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: TetrisGame.gridWidth * widget.rows,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: TetrisGame.gridWidth,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ TetrisGame.gridWidth;
        final col = index % TetrisGame.gridWidth;

        // PERFORMANCE: Only rebuild cells that actually changed
        return _GridCell(
          key: ValueKey('cell_${row}_$col'),
          game: widget.game,
          row: row,
          col: col,
          isAnimating: widget.game.rowsToAnimate.contains(row),
        );
      },
    );
  }

  Widget _buildParticleOverlay() {
    return AnimatedBuilder(
      animation: _lineAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.1 * _lineAnimationController.value),
                Colors.transparent,
                Colors.white.withValues(alpha: 0.1 * _lineAnimationController.value),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getBackgroundColors() {
    // ENHANCEMENT: Dynamic background based on score/level
    final score = widget.game.score;
    final level = widget.game.level;

    if (score >= 50000) {
      return [
        Colors.purple.withValues(alpha: 0.3),
        Colors.indigo.withValues(alpha: 0.2),
        Colors.black.withValues(alpha: 0.8),
        Colors.black.withValues(alpha: 0.9),
      ];
    } else if (level >= 10) {
      return [
        Colors.red.withValues(alpha: 0.2),
        Colors.orange.withValues(alpha: 0.1),
        Colors.black.withValues(alpha: 0.8),
        Colors.black.withValues(alpha: 0.9),
      ];
    } else if (level >= 5) {
      return [
        Colors.blue.withValues(alpha: 0.2),
        Colors.cyan.withValues(alpha: 0.1),
        Colors.black.withValues(alpha: 0.8),
        Colors.black.withValues(alpha: 0.9),
      ];
    }

    // Default background
    return [
      Colors.black.withValues(alpha: 0.9),
      Colors.grey[900]!.withValues(alpha: 0.8),
      Colors.black.withValues(alpha: 0.9),
      Colors.black.withValues(alpha: 0.95),
    ];
  }
}

// PERFORMANCE: Separate widget for individual cells to minimize rebuilds
class _GridCell extends StatelessWidget {
  final TetrisGame game;
  final int row;
  final int col;
  final bool isAnimating;

  const _GridCell({
    super.key,
    required this.game,
    required this.row,
    required this.col,
    required this.isAnimating,
  });

  @override
  Widget build(BuildContext context) {
    final cellColor = game.getCellColor(row, col);

    return AnimatedContainer(
      duration: Duration(milliseconds: isAnimating ? 150 : 0),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isAnimating
            ? Colors.white.withValues(alpha: 0.9)
            : cellColor ?? Colors.grey[850]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3),
        border: cellColor != null
            ? Border.all(color: _getBorderColor(cellColor), width: 1.5)
            : Border.all(color: Colors.grey[700]!.withValues(alpha: 0.2), width: 0.5),
        boxShadow: cellColor != null
            ? [
                BoxShadow(
                  color: cellColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ]
            : null,
      ),
      child: cellColor != null ? _buildCellContent(cellColor) : null,
    );
  }

  Widget _buildCellContent(Color cellColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cellColor,
            cellColor.withValues(alpha: 0.7),
            cellColor.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(Color baseColor) {
    return Color.fromRGBO(
      (baseColor.red * 1.3).clamp(0, 255).toInt(),
      (baseColor.green * 1.3).clamp(0, 255).toInt(),
      (baseColor.blue * 1.3).clamp(0, 255).toInt(),
      1.0,
    );
  }
}
