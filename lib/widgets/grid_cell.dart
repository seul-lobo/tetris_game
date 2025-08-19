// PERFORMANCE: Separate widget for individual cells to minimize rebuilds
import 'package:flutter/material.dart';
import 'package:tetris_game/game/tetris_game.dart';

class GridCell extends StatelessWidget {
  final TetrisGame game;
  final int row;
  final int col;
  final bool isAnimating;

  const GridCell({
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