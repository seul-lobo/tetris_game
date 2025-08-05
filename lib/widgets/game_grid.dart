import 'package:flutter/material.dart';
import '../game/tetris_game.dart';

class GameGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (16.0 * 2); // Accounting for padding
    final cellSize = boxSize; // Use provided boxSize for larger cells
    final gridHeight =
        MediaQuery.of(context).size.height * 0.5; // Adjust height as needed

    return Center(
      child: Container(
        width: availableWidth,
        height: gridHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.grey[900]!.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: TetrisGame.gridWidth * rows,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: TetrisGame.gridWidth,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              int row = index ~/ TetrisGame.gridWidth;
              int col = index % TetrisGame.gridWidth;
              return _buildGridCell(row, col, cellSize);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGridCell(int row, int col, double cellSize) {
    Color? cellColor = game.getCellColor(row, col);
    bool isAnimating = game.rowsToAnimate.contains(row);

    return AnimatedContainer(
      duration: Duration(milliseconds: isAnimating ? 150 : 0),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isAnimating
            ? Colors.white.withOpacity(0.9)
            : cellColor ?? Colors.grey[850]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
        border: cellColor != null
            ? Border.all(color: _getBorderColor(cellColor), width: 1.5)
            : Border.all(color: Colors.grey[700]!.withOpacity(0.2), width: 0.5),
        boxShadow: cellColor != null
            ? [
                BoxShadow(
                  color: cellColor.withOpacity(0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ]
            : null,
      ),
      child: cellColor != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cellColor,
                    cellColor.withOpacity(0.7),
                    cellColor.withOpacity(0.9),
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
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            )
          : null,
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
