// Game Session Data Model - Enhanced
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