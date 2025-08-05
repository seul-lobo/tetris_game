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

  // Generate the positions for each piece type and rotation
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
      [-36, -26, -16, -6], // 0°
      [-7, -6, -5, -4], // 90°
      [-36, -26, -16, -6], // 180°
      [-7, -6, -5, -4], // 270°
    ],
    TetrominoType.O: [
      [-16, -15, -6, -5], // 0°
      [-16, -15, -6, -5], // 90°
      [-16, -15, -6, -5], // 180°
      [-16, -15, -6, -5], // 270°
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

  Color get color {
    switch (type) {
      case TetrominoType.L:
        return Colors.orange;
      case TetrominoType.J:
        return Colors.blue;
      case TetrominoType.I:
        return Colors.cyan;
      case TetrominoType.O:
        return Colors.yellow;
      case TetrominoType.S:
        return Colors.green;
      case TetrominoType.Z:
        return Colors.red;
      case TetrominoType.T:
        return Colors.purple;
    }
  }

  static TetrisPiece generateRandomPiece() {
    Random random = Random();
    TetrominoType randomType =
        TetrominoType.values[random.nextInt(TetrominoType.values.length)];
    return TetrisPiece(
      type: randomType,
      position: [4], // Start at top center
    );
  }
}
