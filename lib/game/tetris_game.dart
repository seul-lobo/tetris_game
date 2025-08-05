import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/tetris_piece.dart';

class TetrisGame extends ChangeNotifier {
  static const int gridWidth = 10;
  static const int gridHeight = 12;
  static const int gridSize = gridWidth * gridHeight;

  List<List<TetrominoType?>> grid = List.generate(
    gridHeight,
    (i) => List.generate(gridWidth, (j) => null),
  );

  TetrisPiece? currentPiece;
  TetrisPiece? nextPiece;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool isGameOver = false;
  bool isPlaying = false;
  Timer? gameTimer;
  List<int> rowsToAnimate = [];

  final Box _scoreBox = Hive.box('highscore');

  int get highScore => _scoreBox.get('highscore', defaultValue: 0);

  Duration get dropInterval =>
      Duration(milliseconds: max(50, 500 - (level - 1) * 50));

  void startGame() {
    if (isPlaying) return;

    resetGame();
    isPlaying = true;
    spawnNewPiece();
    _startGameLoop();
    notifyListeners();
  }

  void pauseGame() {
    if (!isPlaying) return;

    isPlaying = false;
    gameTimer?.cancel();
    notifyListeners();
  }

  void resumeGame() {
    if (isPlaying) return;

    isPlaying = true;
    _startGameLoop();
    notifyListeners();
  }

  void resetGame() {
    grid = List.generate(
      gridHeight,
      (i) => List.generate(gridWidth, (j) => null),
    );
    currentPiece = null;
    nextPiece = null;
    score = 0;
    level = 1;
    linesCleared = 0;
    isGameOver = false;
    isPlaying = false;
    rowsToAnimate = [];
    gameTimer?.cancel();
    notifyListeners();
  }

  void _startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(dropInterval, (timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }
      _dropPiece();
    });
  }

  void spawnNewPiece() {
    currentPiece = nextPiece ?? TetrisPiece.generateRandomPiece();
    nextPiece = TetrisPiece.generateRandomPiece();

    if (!_isValidPosition(currentPiece!)) {
      gameOver();
    }
    notifyListeners();
  }

  void _dropPiece() {
    if (currentPiece == null) return;

    movePiece(Direction.down);
  }

  void movePiece(Direction direction) {
    if (currentPiece == null || !isPlaying) return;

    TetrisPiece testPiece = TetrisPiece(
      type: currentPiece!.type,
      position: [...currentPiece!.position],
      rotationState: currentPiece!.rotationState,
    );

    testPiece.move(direction);

    if (_isValidPosition(testPiece, enforceBoundaries: true)) {
      currentPiece!.move(direction);
      notifyListeners();
    } else if (direction == Direction.down) {
      _placePiece();
    }
  }

  void rotatePiece() {
    if (currentPiece == null || !isPlaying) return;

    TetrisPiece testPiece = TetrisPiece(
      type: currentPiece!.type,
      position: [...currentPiece!.position],
      rotationState: currentPiece!.rotationState,
    );

    testPiece.rotate();

    if (_isValidPosition(testPiece, enforceBoundaries: true)) {
      currentPiece!.rotate();
      notifyListeners();
    }
  }

  void hardDrop() {
    if (currentPiece == null || !isPlaying) return;

    while (_isValidPosition(currentPiece!, enforceBoundaries: true)) {
      TetrisPiece testPiece = TetrisPiece(
        type: currentPiece!.type,
        position: [...currentPiece!.position],
        rotationState: currentPiece!.rotationState,
      );
      testPiece.move(Direction.down);

      if (_isValidPosition(testPiece, enforceBoundaries: true)) {
        currentPiece!.move(Direction.down);
        score += 2;
      } else {
        break;
      }
    }
    _placePiece();
  }

  bool _isValidPosition(TetrisPiece piece, {bool enforceBoundaries = false}) {
    for (int pos in piece.currentPositions) {
      int row = pos ~/ gridWidth;
      int col = pos % gridWidth;

      if (row < 0) continue;
      if (enforceBoundaries) {
        if (col < 0 || col >= gridWidth || row >= gridHeight) return false;
      } else {
        if (row >= gridHeight || col < 0 || col >= gridWidth) return false;
      }
      if (grid[row][col] != null) return false;
    }
    return true;
  }

  void _placePiece() {
    if (currentPiece == null) return;

    for (int pos in currentPiece!.currentPositions) {
      int row = pos ~/ gridWidth;
      int col = pos % gridWidth;

      if (row >= 0 && row < gridHeight && col >= 0 && col < gridWidth) {
        grid[row][col] = currentPiece!.type;
      }
    }

    _clearLines();
    spawnNewPiece();
    _updateGameSpeed();
  }

  void _clearLines() {
    List<int> fullRows = [];

    for (int row = gridHeight - 1; row >= 0; row--) {
      if (grid[row].every((cell) => cell != null)) {
        fullRows.add(row);
      }
    }

    if (fullRows.isNotEmpty) {
      rowsToAnimate = [...fullRows];
      notifyListeners();

      Timer(const Duration(milliseconds: 300), () {
        for (int row in fullRows.reversed) {
          grid.removeAt(row);
          grid.insert(0, List.generate(gridWidth, (j) => null));
        }

        int linesCount = fullRows.length;
        linesCleared += linesCount;
        _updateScore(linesCount);
        rowsToAnimate = [];
        notifyListeners();
      });
    }
  }

  void _updateScore(int linesCount) {
    int points = 0;
    switch (linesCount) {
      case 1:
        points = 100 * level;
        break;
      case 2:
        points = 300 * level;
        break;
      case 3:
        points = 500 * level;
        break;
      case 4:
        points = 800 * level;
        break;
    }
    score += points;

    if (score > highScore) {
      _scoreBox.put('highscore', score);
    }
  }

  void _updateGameSpeed() {
    int newLevel = (linesCleared ~/ 10) + 1;
    if (newLevel != level) {
      level = newLevel;
      gameTimer?.cancel();
      _startGameLoop();
    }
  }

  void gameOver() {
    isGameOver = true;
    isPlaying = false;
    gameTimer?.cancel();
    notifyListeners();
  }

  Color? getCellColor(int row, int col) {
    if (grid[row][col] != null) {
      return _getTypeColor(grid[row][col]!);
    }

    if (currentPiece != null) {
      int cellIndex = row * gridWidth + col;
      if (currentPiece!.currentPositions.contains(cellIndex)) {
        return currentPiece!.color;
      }
    }

    return null;
  }

  Color _getTypeColor(TetrominoType type) {
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

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}
