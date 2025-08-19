import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tetris_game/models/game_session.dart';
import 'package:tetris_game/widgets/blast_particles.dart';
import '../models/tetris_piece.dart';

class TetrisGame extends ChangeNotifier {
  static const int gridWidth = 10;
  static const int gridHeight = 15;
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

  //Blast effect properties
  List<BlastParticle> blastParticles = [];
  bool isBlasting = false;
  Timer? blastTimer;

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
    return stored;
  }

  Duration get dropInterval =>
      Duration(milliseconds: max(50, 500 - (level - 1) * 40));

  void startGame() {
    if (isPlaying) return;

    resetGame();
    isPlaying = true;
    _initializePieceBag();
    spawnNewPiece();
    _startGameLoop();
    notifyListeners();
  }

  void pauseGame() {
    if (!isPlaying) return;

    isPlaying = false;
    gameTimer?.cancel();
    blastTimer?.cancel();
    notifyListeners();
  }

  void resumeGame() {
    if (isPlaying) return;

    isPlaying = true;
    _startGameLoop();
    if (isBlasting) _startBlastAnimation();
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
    blastParticles = [];
    isBlasting = false;
    gameTimer?.cancel();
    blastTimer?.cancel();
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

    // Check if the new piece can be placed at spawn position
    if (currentPiece != null && !_isValidPosition(currentPiece!)) {
      gameOver();
      return;
    }
    notifyListeners();
  }

  void _dropPiece() {
    if (currentPiece == null) return;
    movePiece(Direction.down);
  }

  void movePiece(Direction direction) {
    if (currentPiece == null || !isPlaying) return;

    // Create a copy to test movement
    TetrisPiece testPiece = TetrisPiece.copyFrom(currentPiece!);
    testPiece.move(direction);

    if (_isValidPosition(testPiece)) {
      // Only update the current piece position, don't recreate it
      currentPiece!.position[0] = testPiece.position[0];
      currentPiece!.position[1] = testPiece.position[1];
      notifyListeners();
    } else if (direction == Direction.down) {
      _placePiece();
    }
  }

  void rotatePiece() {
    if (currentPiece == null || !isPlaying) return;

    // Test rotation
    TetrisPiece testPiece = TetrisPiece.copyFrom(currentPiece!);
    testPiece.rotate();

    if (_isValidPosition(testPiece)) {
      // Apply rotation to current piece
      currentPiece!.rotationState = testPiece.rotationState;
      notifyListeners();
    } else {
      // Try wall kicks
      List<List<int>> wallKicks = [
        [-1, 0],
        [1, 0],
        [0, -1],
        [-1, -1],
        [1, -1],
        [2, 0],
        [-2, 0],
      ];

      for (var kick in wallKicks) {
        TetrisPiece kickTestPiece = TetrisPiece.copyFrom(testPiece);
        kickTestPiece.position[0] += kick[0];
        kickTestPiece.position[1] += kick[1];

        if (_isValidPosition(kickTestPiece)) {
          // Apply successful kick
          currentPiece!.position[0] = kickTestPiece.position[0];
          currentPiece!.position[1] = kickTestPiece.position[1];
          currentPiece!.rotationState = kickTestPiece.rotationState;
          notifyListeners();
          return;
        }
      }
    }
  }

  // Enhanced collision detection without wrapping
  bool _isValidPosition(TetrisPiece piece) {
    List<List<int>> positions = piece.currentPositions;

    for (var pos in positions) {
      int row = pos[0];
      int col = pos[1];

      // Check boundaries - no wrapping allowed
      if (col < 0 || col >= gridWidth || row >= gridHeight) {
        return false;
      }

      // Allow spawning above visible grid
      if (row < 0) continue;

      // Check collision with existing blocks
      if (grid[row][col] != null) return false;
    }
    return true;
  }

  // Enhanced piece placement
  void _placePiece() {
    if (currentPiece == null) return;

    // Place the piece on the grid
    for (var pos in currentPiece!.currentPositions) {
      int row = pos[0];
      int col = pos[1];

      if (row >= 0 && row < gridHeight && col >= 0 && col < gridWidth) {
        grid[row][col] = currentPiece!.type;
      }
    }

    _clearLines();
    spawnNewPiece();
    _updateGameSpeed();
  }

  //Clear lines with blast effect
  void _clearLines() {
    List<int> fullRows = [];

    for (int row = gridHeight - 1; row >= 0; row--) {
      if (grid[row].every((cell) => cell != null)) {
        fullRows.add(row);
      }
    }

    if (fullRows.isNotEmpty) {
      rowsToAnimate = [...fullRows];
      _createBlastEffect(fullRows);
      isBlasting = true;
      notifyListeners();

      // Start blast animation
      _startBlastAnimation();

      Timer(const Duration(milliseconds: 600), () {
        for (int row in fullRows.reversed) {
          grid.removeAt(row);
          grid.insert(0, List.generate(gridWidth, (j) => null));
        }

        int linesCount = fullRows.length;
        linesCleared += linesCount;
        totalLinesCleared += linesCount;
        _updateScore(linesCount);
        rowsToAnimate = [];
        blastParticles = [];
        isBlasting = false;
        blastTimer?.cancel();
        notifyListeners();
      });
    }
  }

  //Create blast effect particles
  void _createBlastEffect(List<int> fullRows) {
    blastParticles.clear();
    final random = Random();

    for (int row in fullRows) {
      for (int col = 0; col < gridWidth; col++) {
        Color cellColor = _getTypeColor(grid[row][col]!);

        // Create multiple particles per cell for more dramatic effect
        for (int i = 0; i < 8; i++) {
          blastParticles.add(
            BlastParticle(
              startRow: row.toDouble(),
              startCol: col.toDouble(),
              velocityX: (random.nextDouble() - 0.5) * 4,
              velocityY: (random.nextDouble() - 0.5) * 4,
              color: cellColor,
              size: random.nextDouble() * 0.3 + 0.1,
              life: 1.0,
              decay: random.nextDouble() * 0.02 + 0.015,
            ),
          );
        }

        // Add some sparkle particles
        for (int i = 0; i < 3; i++) {
          blastParticles.add(
            BlastParticle(
              startRow: row.toDouble(),
              startCol: col.toDouble(),
              velocityX: (random.nextDouble() - 0.5) * 6,
              velocityY: (random.nextDouble() - 0.5) * 6,
              color: Colors.white,
              size: random.nextDouble() * 0.2 + 0.05,
              life: 1.0,
              decay: random.nextDouble() * 0.03 + 0.02,
            ),
          );
        }
      }
    }
  }

  //Animate blast particles
  void _startBlastAnimation() {
    blastTimer?.cancel();
    blastTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isPlaying && !isBlasting) {
        timer.cancel();
        return;
      }

      bool anyAlive = false;
      for (var particle in blastParticles) {
        particle.update();
        if (particle.life > 0) anyAlive = true;
      }

      if (!anyAlive || blastParticles.isEmpty) {
        timer.cancel();
      }

      notifyListeners();
    });
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

    // Real-time high score updates with immediate notification
    if (score > highScore) {
      _scoreBox.put('highscore', score);
      notifyListeners();
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
    blastTimer?.cancel();

    _saveGameSession();
    notifyListeners();
  }

  // Enhanced game session tracking
  void _saveGameSession() {
    final session = GameSession(
      score: score,
      level: level,
      linesCleared: linesCleared,
      timestamp: DateTime.now(),
      duration: DateTime.now().difference(DateTime.now()),
    );

    gameHistory.insert(0, session);
    if (gameHistory.length > 100) gameHistory.removeLast();

    totalGamesPlayed++;
    totalLinesCleared += linesCleared;
    averageScore = gameHistory.isEmpty
        ? 0.0
        : gameHistory.fold<double>(0, (sum, game) => sum + game.score) /
              gameHistory.length;

    // Persist to storage with real-time updates
    _statsBox.put('gameHistory', gameHistory.map((s) => s.toJson()).toList());
    _statsBox.put('totalGamesPlayed', totalGamesPlayed);
    _statsBox.put('totalLinesCleared', totalLinesCleared);
    _statsBox.put('averageScore', averageScore);
  }

  // Load stats on initialization
  void loadStats() {
    final historyData = _statsBox.get('gameHistory', defaultValue: <dynamic>[]);
    gameHistory = (historyData as List)
        .map((json) => GameSession.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    totalGamesPlayed = _statsBox.get('totalGamesPlayed', defaultValue: 0);
    totalLinesCleared = _statsBox.get('totalLinesCleared', defaultValue: 0);
    averageScore = _statsBox.get('averageScore', defaultValue: 0.0);
  }

  Color? getCellColor(int row, int col) {
    // Show blast effect for clearing rows
    if (rowsToAnimate.contains(row)) {
      return Colors.white.withValues(alpha: 0.8);
    }

    if (grid[row][col] != null) {
      return _getTypeColor(grid[row][col]!);
    }

    if (currentPiece != null) {
      for (var pos in currentPiece!.currentPositions) {
        if (pos[0] == row && pos[1] == col) {
          return currentPiece!.color;
        }
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
    blastTimer?.cancel();
    super.dispose();
  }
}
