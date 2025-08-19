import 'package:flutter/material.dart';
import 'dart:math';
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
  late AnimationController _blastController; // NEW: Blast animation controller
  late Animation<double> _backgroundAnimation;
  late Animation<double> _blastAnimation; // NEW: Blast animation

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

    // NEW: Blast animation controller
    _blastController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    // NEW: Blast animation with custom curve
    _blastAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blastController, curve: Curves.easeOutQuart),
    );

    // Listen for line clear animations
    widget.game.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (widget.game.rowsToAnimate.isNotEmpty && !widget.game.isBlasting) {
      // Start both the original line animation and the new blast animation
      _lineAnimationController.forward().then((_) {
        _lineAnimationController.reverse();
      });

      // NEW: Start blast animation
      _blastController.reset();
      _blastController.forward();
    }
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameStateChanged);
    _lineAnimationController.dispose();
    _backgroundController.dispose();
    _blastController.dispose(); // NEW: Dispose blast controller
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
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  );
                },
              ),

              // ENHANCEMENT: Optimized grid with reduced rebuilds
              _buildOptimizedGrid(),

              // ENHANCEMENT: Particle effects overlay for special events
              if (widget.game.rowsToAnimate.isNotEmpty) _buildParticleOverlay(),

              // NEW: Blast effect overlay
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
        final row =
            index ~/ TetrisGame.gridWidth; // Fix: use gridWidth not gridHeight
        final col = index % TetrisGame.gridWidth;

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

  // NEW: Blast effect overlay with particle system
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

// NEW: Blast Effect Painter for particle system
class BlastEffectPainter extends CustomPainter {
  final List<BlastParticle> particles;
  final double cellSize;
  final double progress;
  final int gridWidth;
  final double containerWidth;

  BlastEffectPainter({
    required this.particles,
    required this.cellSize,
    required this.progress,
    required this.gridWidth,
    required this.containerWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = containerWidth / gridWidth;

    for (var particle in particles) {
      if (particle.life <= 0) continue;

      final paint = Paint()
        ..color = particle.currentColor
        ..style = PaintingStyle.fill;

      // Calculate pixel position from grid position
      final x = particle.currentCol * cellWidth + cellWidth * 0.5;
      final y = particle.currentRow * cellSize + cellSize * 0.5;

      // Only draw if particle is within visible bounds
      if (x < -50 || x > size.width + 50 || y < -50 || y > size.height + 50) {
        continue;
      }

      // Draw particle with size based on life and original size
      final radius = particle.size * cellSize * particle.life;

      // Add a glowing effect with multiple layers
      final glowPaint1 = Paint()
        ..color = particle.color.withValues(alpha: particle.life * 0.6)
        ..style = PaintingStyle.fill;

      final glowPaint2 = Paint()
        ..color = particle.color.withValues(alpha: particle.life * 0.3)
        ..style = PaintingStyle.fill;

      // Draw layered glow effect
      canvas.drawCircle(Offset(x, y), radius * 4, glowPaint2);
      canvas.drawCircle(Offset(x, y), radius * 2, glowPaint1);
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add sparkle effect for white particles
      if (particle.color == Colors.white && particle.life > 0.3) {
        final sparklePaint = Paint()
          ..color = Colors.yellow.withValues(alpha: particle.life * 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

        // Draw a rotating star shape
        _drawStar(canvas, Offset(x, y), radius * 1.2, sparklePaint, progress);
      }

      // Add streak effect for fast-moving particles
      if (particle.velocityX.abs() > 2 || particle.velocityY.abs() > 2) {
        final streakPaint = Paint()
          ..color = particle.color.withValues(alpha: particle.life * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.5;

        final streakEnd = Offset(
          x - particle.velocityX * 3,
          y - particle.velocityY * 3,
        );

        canvas.drawLine(Offset(x, y), streakEnd, streakPaint);
      }
    }
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    double rotation,
  ) {
    const int points = 6;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) + (rotation * 2 * pi);
      final r = i.isEven ? radius : radius * 0.4;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
            : Border.all(
                color: Colors.grey[700]!.withValues(alpha: 0.2),
                width: 0.5,
              ),
        boxShadow: isAnimating
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: (cellColor ?? Colors.white).withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ]
            : cellColor != null
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
