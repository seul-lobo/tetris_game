import 'package:flutter/material.dart';
import 'dart:math';

enum TetrominoType { I, O, T, S, Z, J, L }

enum Direction { left, right, down }

class TetrisPiece {
  TetrominoType type;
  List<int> position;
  int rotationState;

  TetrisPiece({
    required this.type,
    required this.position,
    this.rotationState = 0,
  });

  //More precise tetromino definitions with better balance
  Map<TetrominoType, List<List<int>>> get tetrominos => {
    TetrominoType.L: [
      [-26, -16, -6, -5], // 0°
      [-25, -15, -14, -13], // 90°
      [-15, -5, 5, 6], // 180°
      [-5, -4, -3, 5], // 270°
    ],
    TetrominoType.J: [
      [-25, -15, -5, -6], // 0°
      [-26, -16, -15, -14], // 90°
      [-16, -6, 4, 5], // 180°
      [-6, -5, -4, -14], // 270°
    ],
    TetrominoType.I: [
      [-36, -26, -16, -6], // 0° - Vertical
      [-7, -6, -5, -4], // 90° - Horizontal
      [-36, -26, -16, -6], // 180° - Vertical
      [-7, -6, -5, -4], // 270° - Horizontal
    ],
    TetrominoType.O: [
      [-16, -15, -6, -5], // All rotations the same
      [-16, -15, -6, -5],
      [-16, -15, -6, -5],
      [-16, -15, -6, -5],
    ],
    TetrominoType.S: [
      [-15, -14, -6, -5], // 0°
      [-26, -16, -15, -5], // 90°
      [-15, -14, -6, -5], // 180°
      [-26, -16, -15, -5], // 270°
    ],
    TetrominoType.Z: [
      [-17, -16, -6, -5], // 0°
      [-25, -15, -16, -6], // 90°
      [-17, -16, -6, -5], // 180°
      [-25, -15, -16, -6], // 270°
    ],
    TetrominoType.T: [
      [-16, -15, -14, -5], // 0°
      [-26, -16, -15, -6], // 90°
      [-15, -5, -4, -3], // 180°
      [-25, -16, -15, -5], // 270°
    ],
  };

  List<int> get currentPositions {
    List<int> positions = [];
    for (int pos in tetrominos[type]![rotationState]) {
      positions.add(pos + position[0]);
    }
    return positions;
  }

  void move(Direction direction) {
    switch (direction) {
      case Direction.down:
        position[0] += 10;
        break;
      case Direction.left:
        position[0] -= 1;
        break;
      case Direction.right:
        position[0] += 1;
        break;
    }
  }

  void rotate() {
    rotationState = (rotationState + 1) % 4;
  }

  //Enhanced color system with better contrast
  Color get color {
    switch (type) {
      case TetrominoType.L:
        return const Color(0xFFFF8C00); // Dark Orange
      case TetrominoType.J:
        return const Color(0xFF0080FF); // Bright Blue
      case TetrominoType.I:
        return const Color(0xFF00FFFF); // Cyan
      case TetrominoType.O:
        return const Color(0xFFFFD700); // Gold
      case TetrominoType.S:
        return const Color(0xFF32CD32); // Lime Green
      case TetrominoType.Z:
        return const Color(0xFFFF4444); // Bright Red
      case TetrominoType.T:
        return const Color(0xFF9932CC); // Dark Orchid
    }
  }

  //Generate specific piece type (for 7-bag system)
  static TetrisPiece generateSpecificPiece(TetrominoType type) {
    return TetrisPiece(
      type: type,
      position: [4], // Start at top center
    );
  }

  // Keep original random generation for backward compatibility
  static TetrisPiece generateRandomPiece() {
    Random random = Random();
    TetrominoType randomType =
        TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    return TetrisPiece(
      type: randomType,
      position: [4], // Start at top center
    );
  }

  //Get piece preview for next piece display
  List<List<bool>> get previewGrid {
    List<List<bool>> preview = List.generate(4, (_) => List.filled(4, false));
    List<int> positions =
        tetrominos[type]![0]; // Always use first rotation for preview

    int minRow = positions
        .map((pos) => pos ~/ 10)
        .reduce((a, b) => a < b ? a : b);
    int minCol = positions
        .map((pos) => pos % 10)
        .reduce((a, b) => a < b ? a : b);

    for (int pos in positions) {
      int row = (pos ~/ 10) - minRow;
      int col = (pos % 10) - minCol;
      if (row >= 0 && row < 4 && col >= 0 && col < 4) {
        preview[row][col] = true;
      }
    }

    return preview;
  }
}
