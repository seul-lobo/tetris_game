import 'package:flutter/material.dart';
import '../game/tetris_game.dart';
import '../models/tetris_piece.dart';

class NextPieceDisplay extends StatelessWidget {
  final TetrisGame game;

  const NextPieceDisplay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A3E), Color(0xFF2A4D7A).withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.25,
                    maxHeight: MediaQuery.of(context).size.height * 0.096,
                  ),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: game.nextPiece != null
                      ? _buildNextPieceGrid()
                      : Center(
                          child: Icon(
                            Icons.help_outline,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 20,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Center(
            child: Row(
              children: [
                _buildDropButton(
                  Icons.keyboard_arrow_down,
                  'SOFT DROP',
                  Colors.orange,
                  () => game.movePiece(Direction.down),
                ),
                SizedBox(width: 8),
                _buildDropButton(
                  Icons.vertical_align_bottom,
                  'HARD DROP',
                  Colors.red,
                  () => game.hardDrop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPieceGrid() {
    if (game.nextPiece == null) return SizedBox.shrink();

    TetrisPiece piece = game.nextPiece!;
    List<int> positions = piece.tetrominos[piece.type]![0];

    int minRow = positions
        .map((pos) => pos ~/ 10)
        .reduce((a, b) => a < b ? a : b);
    int maxRow = positions
        .map((pos) => pos ~/ 10)
        .reduce((a, b) => a > b ? a : b);
    int minCol = positions
        .map((pos) => pos % 10)
        .reduce((a, b) => a < b ? a : b);
    int maxCol = positions
        .map((pos) => pos % 10)
        .reduce((a, b) => a > b ? a : b);

    int pieceWidth = maxCol - minCol + 1;
    int pieceHeight = maxRow - minRow + 1;

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: 36,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        int row = index ~/ 6;
        int col = index % 6;

        int offsetRow = (6 - pieceHeight) ~/ 2;
        int offsetCol = (6 - pieceWidth) ~/ 2;

        bool isPartOfPiece = positions.any((pos) {
          int pieceRow = (pos ~/ 10) - minRow + offsetRow;
          int pieceCol = (pos % 10) - minCol + offsetCol;
          return pieceRow == row && pieceCol == col;
        });

        return Container(
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isPartOfPiece
                ? piece.color.withValues(alpha: 0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border: isPartOfPiece
                ? Border.all(color: _getBorderColor(piece.color), width: 1)
                : null,
            boxShadow: isPartOfPiece
                ? [
                    BoxShadow(
                      color: piece.color.withValues(alpha: 0.5),
                      blurRadius: 3,
                      offset: Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          child: isPartOfPiece
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [piece.color, piece.color.withValues(alpha: 0.7)],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildDropButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
        ),
      ],
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
