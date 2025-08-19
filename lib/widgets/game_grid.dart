import 'package:flutter/material.dart';
import 'package:tetris_game/widgets/blast_effect.dart';
import 'package:tetris_game/widgets/grid_cell.dart';
import '../game/tetris_game.dart';

class GameGrid extends StatefulWidget {
  final TetrisGame game;
  final int rows;
  final double cellSize;

  const GameGrid({
    super.key,
    required this.game,
    this.rows = 10,
    this.cellSize = 30.0,
  });

  @override
  State<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends State<GameGrid> with TickerProviderStateMixin {
  late AnimationController _lineAnimationController;
  late AnimationController _backgroundController;
  late AnimationController _blastController; //Blast animation controller
  late Animation<double> _backgroundAnimation;
  late Animation<double> _blastAnimation; //Blast animation

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

    //Blast animation controller
    _blastController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    //Blast animation with custom curve
    _blastAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blastController, curve: Curves.easeOutQuart),
    );

    //Listen for line clear animations
    widget.game.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (widget.game.rowsToAnimate.isNotEmpty && !widget.game.isBlasting) {
      //Start both the original line animation and the new blast animation
      _lineAnimationController.forward().then((_) {
        _lineAnimationController.reverse();
      });

      //Start blast animation
      _blastController.reset();
      _blastController.forward();
    }
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameStateChanged);
    _lineAnimationController.dispose();
    _backgroundController.dispose();
    _blastController.dispose(); //Dispose blast controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (16.0 * 2);
    final gridHeight = widget.cellSize * widget.rows;

    return Center(
      child: Container(
        width: availableWidth,
        height: gridHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.cyan.withValues(alpha: 0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              //Animated background with score-based color shifts
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _getBackgroundColors(),
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  );
                },
              ),

              //Optimized grid with reduced rebuilds
              _buildOptimizedGrid(),

              //Particle effects overlay for special events
              if (widget.game.rowsToAnimate.isNotEmpty) _buildParticleOverlay(),

              //Blast effect overlay
              if (widget.game.isBlasting) _buildBlastEffectOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: TetrisGame.gridWidth * TetrisGame.gridHeight, // 10 * 15 = 150
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: TetrisGame.gridWidth, // 10 columns
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ TetrisGame.gridWidth;
        final col = index % TetrisGame.gridWidth;

        return GridCell(
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
                Colors.white.withValues(
                  alpha: 0.1 * _lineAnimationController.value,
                ),
                Colors.transparent,
                Colors.white.withValues(
                  alpha: 0.1 * _lineAnimationController.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Blast effect overlay with particle system
  Widget _buildBlastEffectOverlay() {
    return AnimatedBuilder(
      animation: _blastAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width - 32,
            widget.cellSize * widget.rows,
          ),
          painter: BlastEffectPainter(
            particles: widget.game.blastParticles,
            cellSize: widget.cellSize,
            progress: _blastAnimation.value,
            gridWidth: TetrisGame.gridWidth,
            containerWidth: MediaQuery.of(context).size.width - 32,
          ),
        );
      },
    );
  }

  List<Color> _getBackgroundColors() {
    //Dynamic background based on score/level
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
