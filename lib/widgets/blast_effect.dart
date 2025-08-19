// NEW: Blast Effect Painter for particle system
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris_game/widgets/blast_particles.dart';

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