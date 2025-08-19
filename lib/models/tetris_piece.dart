import 'package:flutter/material.dart';
import 'dart:math';

enum TetrominoType { I, O, T, S, Z, J, L }

enum Direction { left, right, down }

class TetrisPiece {
  TetrominoType type;
  List<int> position; // [row, col] of the anchor point
  int rotationState;

  TetrisPiece({
    required this.type,
    required this.position,
    this.rotationState = 0,
  });

  // Copy constructor to avoid reference issues
  TetrisPiece.copyFrom(TetrisPiece other)
    : type = other.type,
      position = [...other.position],
      rotationState = other.rotationState;

  // FIXED: Proper tetromino definitions with relative positions
  Map<TetrominoType, List<List<List<int>>>> get tetrominos => {
    TetrominoType.L: [
      [
        [-1, 0],
        [0, 0],
        [1, 0],
        [1, 1],
      ], // 0°
      [
        [0, -1],
        [0, 0],
        [0, 1],
        [1, -1],
      ], // 90°
      [
        [-1, -1],
        [-1, 0],
        [0, 0],
        [1, 0],
      ], // 180°
      [
        [-1, 1],
        [0, -1],
        [0, 0],
        [0, 1],
      ], // 270°
    ],
    TetrominoType.J: [
      [
        [-1, 0],
        [0, 0],
        [1, 0],
        [1, -1],
      ], // 0°
      [
        [-1, -1],
        [0, -1],
        [0, 0],
        [0, 1],
      ], // 90°
      [
        [-1, 1],
        [-1, 0],
        [0, 0],
        [1, 0],
      ], // 180°
      [
        [0, -1],
        [0, 0],
        [0, 1],
        [1, 1],
      ], // 270°
    ],
    TetrominoType.I: [
      [
        [-2, 0],
        [-1, 0],
        [0, 0],
        [1, 0],
      ], // 0° - Vertical
      [
        [0, -1],
        [0, 0],
        [0, 1],
        [0, 2],
      ], // 90° - Horizontal
      [
        [-2, 0],
        [-1, 0],
        [0, 0],
        [1, 0],
      ], // 180° - Vertical
      [
        [0, -1],
        [0, 0],
        [0, 1],
        [0, 2],
      ], // 270° - Horizontal
    ],
    TetrominoType.O: [
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
      ], // All rotations the same
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
      ],
      [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1],
      ],
    ],
    TetrominoType.S: [
      [
        [0, -1],
        [0, 0],
        [1, 0],
        [1, 1],
      ], // 0°
      [
        [-1, 0],
        [0, -1],
        [0, 0],
        [1, -1],
      ], // 90°
      [
        [0, -1],
        [0, 0],
        [1, 0],
        [1, 1],
      ], // 180°
      [
        [-1, 0],
        [0, -1],
        [0, 0],
        [1, -1],
      ], // 270°
    ],
    TetrominoType.Z: [
      [
        [0, 0],
        [0, 1],
        [1, -1],
        [1, 0],
      ], // 0°
      [
        [-1, -1],
        [0, -1],
        [0, 0],
        [1, 0],
      ], // 90°
      [
        [0, 0],
        [0, 1],
        [1, -1],
        [1, 0],
      ], // 180°
      [
        [-1, -1],
        [0, -1],
        [0, 0],
        [1, 0],
      ], // 270°
    ],
    TetrominoType.T: [
      [
        [0, -1],
        [0, 0],
        [0, 1],
        [1, 0],
      ], // 0°
      [
        [-1, 0],
        [0, -1],
        [0, 0],
        [1, 0],
      ], // 90°
      [
        [-1, 0],
        [0, -1],
        [0, 0],
        [0, 1],
      ], // 180°
      [
        [-1, 0],
        [0, 0],
        [0, 1],
        [1, 0],
      ], // 270°
    ],
  };

  // FIXED: Returns absolute positions as [row, col] pairs
  List<List<int>> get currentPositions {
    List<List<int>> positions = [];
    for (var relPos in tetrominos[type]![rotationState]) {
      positions.add([
        position[0] + relPos[0], // row
        position[1] + relPos[1], // col
      ]);
    }
    return positions;
  }

  void move(Direction direction) {
    switch (direction) {
      case Direction.down:
        position[0] += 1; // Move down one row
        break;
      case Direction.left:
        position[1] -= 1; // Move left one column
        break;
      case Direction.right:
        position[1] += 1; // Move right one column
        break;
    }
  }

  void rotate() {
    rotationState = (rotationState + 1) % 4;
  }

  // Enhanced color system with better contrast
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

  // Generate specific piece type (for 7-bag system)
  static TetrisPiece generateSpecificPiece(TetrominoType type) {
    return TetrisPiece(
      type: type,
      position: [0, 4], // Start at row 0 (top of 10x10 grid), center column
    );
  }

  // Keep original random generation for backward compatibility
  static TetrisPiece generateRandomPiece() {
    Random random = Random();
    TetrominoType randomType =
        TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    return TetrisPiece(
      type: randomType,
      position: [-2, 4], // Start above visible grid, center column
    );
  }

  // Get piece preview for next piece display
  List<List<bool>> get previewGrid {
    List<List<bool>> preview = List.generate(4, (_) => List.filled(4, false));
    List<List<int>> positions =
        tetrominos[type]![0]; // Always use first rotation

    int minRow = positions.map((pos) => pos[0]).reduce((a, b) => a < b ? a : b);
    int minCol = positions.map((pos) => pos[1]).reduce((a, b) => a < b ? a : b);

    for (var pos in positions) {
      int row = pos[0] - minRow;
      int col = pos[1] - minCol;
      if (row >= 0 && row < 4 && col >= 0 && col < 4) {
        preview[row][col] = true;
      }
    }

    return preview;
  }
}
