//Blast Particle class for explosion effects
import 'dart:ui';

class BlastParticle {
  double currentRow;
  double currentCol;
  final double startRow;
  final double startCol;
  double velocityX;
  double velocityY;
  final Color color;
  final double size;
  double life;
  final double decay;

  BlastParticle({
    required this.startRow,
    required this.startCol,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.life,
    required this.decay,
  }) : currentRow = startRow,
       currentCol = startCol;

  void update() {
    if (life <= 0) return;

    // Update position
    currentRow += velocityY * 0.1;
    currentCol += velocityX * 0.1;

    // Apply gravity and drag
    velocityY += 0.15; // gravity
    velocityX *= 0.98; // air resistance
    velocityY *= 0.98;

    // Reduce life
    life -= decay;
    if (life < 0) life = 0;
  }

  Color get currentColor {
    return color.withValues(alpha: life);
  }
}