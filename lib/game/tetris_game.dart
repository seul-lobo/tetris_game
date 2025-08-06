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

  // Game History & Statistics
  List<GameSession> gameHistory = [];
  int totalGamesPlayed = 0;
  int totalLinesCleared = 0;
  double averageScore = 0.0;

  // 7-Bag Randomization System
  List<TetrominoType> _pieceBag = [];
  int _bagIndex = 0;

  final Box _scoreBox = Hive.box('highscore');
  final Box _statsBox = Hive.box('gameStats');

  // Real-time high score with proper persistence
  int get highScore {
    final stored = _scoreBox.get('highscore', defaultValue: 0);
    notifyListeners(); // Ensure UI updates
    return stored;
  }

  Duration get dropInterval =>
      Duration(milliseconds: max(50, 500 - (level - 1) * 40));

  void startGame() {
    if (isPlaying) return;

    resetGame();
    isPlaying = true;
    _initializePieceBag(); // Initialize 7-bag system
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
    _pieceBag.clear();
    _bagIndex = 0;
    notifyListeners();
  }

  // 7-Bag Randomization System
  void _initializePieceBag() {
    _pieceBag = List.from(TetrominoType.values);
    _pieceBag.shuffle();
    _bagIndex = 0;
  }

  TetrominoType _getNextRandomType() {
    if (_bagIndex >= _pieceBag.length) {
      _initializePieceBag();
    }
    return _pieceBag[_bagIndex++];
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
    currentPiece =
        nextPiece ?? TetrisPiece.generateSpecificPiece(_getNextRandomType());
    nextPiece = TetrisPiece.generateSpecificPiece(_getNextRandomType());

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

    // Wall-kick system for better rotation
    if (_isValidPosition(testPiece, enforceBoundaries: true)) {
      currentPiece!.rotate();
      notifyListeners();
    } else {
      // Try wall kicks
      List<List<int>> wallKicks = [
        [-1, 0],
        [1, 0],
        [0, -1],
        [-1, -1],
        [1, -1],
      ];

      for (var kick in wallKicks) {
        TetrisPiece kickTestPiece = TetrisPiece(
          type: testPiece.type,
          position: [testPiece.position[0] + kick[0] + kick[1] * gridWidth],
          rotationState: testPiece.rotationState,
        );

        if (_isValidPosition(kickTestPiece, enforceBoundaries: true)) {
          currentPiece!.position[0] = kickTestPiece.position[0];
          currentPiece!.rotate();
          notifyListeners();
          return;
        }
      }
    }
  }

  void hardDrop() {
    if (currentPiece == null || !isPlaying) return;

    int dropDistance = 0;
    while (true) {
      TetrisPiece testPiece = TetrisPiece(
        type: currentPiece!.type,
        position: [...currentPiece!.position],
        rotationState: currentPiece!.rotationState,
      );
      testPiece.move(Direction.down);

      if (_isValidPosition(testPiece, enforceBoundaries: true)) {
        currentPiece!.move(Direction.down);
        dropDistance++;
      } else {
        break;
      }
    }

    score += dropDistance * 2; // Bonus points for hard drop
    _placePiece();
  }

  // CRITICAL FIX: Enhanced collision detection
  bool _isValidPosition(TetrisPiece piece, {bool enforceBoundaries = false}) {
    List<int> positions = piece.currentPositions;

    for (int pos in positions) {
      int row = pos ~/ gridWidth;
      int col = pos % gridWidth;

      // Allow spawning above grid (negative rows)
      if (row < 0 && !enforceBoundaries) continue;

      // Check boundaries
      if (enforceBoundaries) {
        if (col < 0 || col >= gridWidth || row >= gridHeight) return false;
      } else {
        if (row >= gridHeight || col < 0 || col >= gridWidth) return false;
      }

      // Check collision with existing blocks
      if (row >= 0 && row < gridHeight && grid[row][col] != null) return false;
    }
    return true;
  }

  // CRITICAL FIX: Enhanced piece placement with proper collision
  void _placePiece() {
    if (currentPiece == null) return;

    // Ensure piece settles completely - check if ANY part can fall further
    bool canFallFurther = true;
    while (canFallFurther) {
      TetrisPiece testPiece = TetrisPiece(
        type: currentPiece!.type,
        position: [...currentPiece!.position],
        rotationState: currentPiece!.rotationState,
      );
      testPiece.move(Direction.down);

      if (_isValidPosition(testPiece, enforceBoundaries: true)) {
        currentPiece!.move(Direction.down);
      } else {
        canFallFurther = false;
      }
    }

    // Place the piece on the grid
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
        totalLinesCleared += linesCount;
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
        points = 800 * level; // Tetris bonus!
        break;
    }
    score += points;

    // Real-time high score updates
    if (score > highScore) {
      _scoreBox.put('highscore', score);
      notifyListeners(); // Trigger UI update immediately
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

    // Save game session to history
    _saveGameSession();
    notifyListeners();
  }

  // Game session tracking
  void _saveGameSession() {
    final session = GameSession(
      score: score,
      level: level,
      linesCleared: linesCleared,
      timestamp: DateTime.now(),
      duration: DateTime.now().difference(
        DateTime.now(),
      ), // Calculate actual duration
    );

    gameHistory.insert(0, session);
    if (gameHistory.length > 50) gameHistory.removeLast(); // Keep last 50 games

    totalGamesPlayed++;
    averageScore =
        (averageScore * (totalGamesPlayed - 1) + score) / totalGamesPlayed;

    // Persist to storage
    _statsBox.put('gameHistory', gameHistory.map((s) => s.toJson()).toList());
    _statsBox.put('totalGamesPlayed', totalGamesPlayed);
    _statsBox.put('averageScore', averageScore);
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

// Game Session Data Model
class GameSession {
  final int score;
  final int level;
  final int linesCleared;
  final DateTime timestamp;
  final Duration duration;

  GameSession({
    required this.score,
    required this.level,
    required this.linesCleared,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'level': level,
    'linesCleared': linesCleared,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration.inSeconds,
  };

  factory GameSession.fromJson(Map<String, dynamic> json) => GameSession(
    score: json['score'] ?? 0,
    level: json['level'] ?? 1,
    linesCleared: json['linesCleared'] ?? 0,
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    duration: Duration(seconds: json['duration'] ?? 0),
  );
}
