import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/tetris_game.dart';
import '../models/tetris_piece.dart';

class GameControls extends StatelessWidget {
  final TetrisGame game;

  const GameControls({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xFF2A4D7A).withValues(alpha: 0.3)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.keyboard_arrow_left,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  game.movePiece(Direction.left);
                },
                color: Colors.blue,
                size: MediaQuery.of(context).size.width * 0.10,
              ),
              _buildControlButton(
                icon: Icons.rotate_right,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  game.rotatePiece();
                },
                color: Colors.purple,
                size: MediaQuery.of(context).size.width * 0.13,
              ),
              _buildControlButton(
                icon: Icons.keyboard_arrow_right,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  game.movePiece(Direction.right);
                },
                color: Colors.blue,
                size: MediaQuery.of(context).size.width * 0.10,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLabel('MOVE', Colors.blue),
              _buildLabel('ROTATE', Colors.purple),
              _buildLabel('MOVE', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => HapticFeedback.lightImpact(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(size / 4),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.45,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: color.withValues(alpha: 0.7),
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        shadows: [
          Shadow(
            blurRadius: 5.0,
            color: color.withValues(alpha: 0.5),
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
    );
  }
}
