import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../game/tetris_game.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Box _statsBox = Hive.box('gameStats');
  List<GameSession> gameHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGameHistory();
  }

  void _loadGameHistory() {
    final historyData = _statsBox.get('gameHistory', defaultValue: <dynamic>[]);
    gameHistory = (historyData as List)
        .map((json) => GameSession.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B1B3D), Color(0xFF4A1625), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHighScoresTab(),
                    _buildRecentGamesTab(),
                    _buildStatsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'LEADERBOARD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.yellow.withValues(alpha: 0.3),
                  Colors.amber.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.yellow, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${gameHistory.length}',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'HIGH SCORES'),
          Tab(text: 'RECENT'),
          Tab(text: 'STATISTICS'),
        ],
      ),
    );
  }

  Widget _buildHighScoresTab() {
    final topScores = [...gameHistory]
      ..sort((a, b) => b.score.compareTo(a.score))
      ..take(10);

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: topScores.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCurrentHighScore();
        }

        final session = topScores.elementAt(index - 1);
        return _buildScoreCard(session, index);
      },
    );
  }

  Widget _buildCurrentHighScore() {
    final highScore = Hive.box('highscore').get('highscore', defaultValue: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.yellow.withValues(alpha: 0.3),
            Colors.amber.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.yellow, size: 48),
          const SizedBox(height: 12),
          const Text(
            'ALL-TIME HIGH SCORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatNumber(highScore),
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(GameSession session, int rank) {
    Color rankColor = rank <= 3
        ? [Colors.yellow, Colors.grey, Colors.brown][rank - 1]
        : Colors.white54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatNumber(session.score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.timeline, color: Colors.cyan, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${session.level}',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.horizontal_rule, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${session.linesCleared} lines',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _formatDate(session.timestamp),
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGamesTab() {
    final recentGames = gameHistory.take(20).toList();

    if (recentGames.isEmpty) {
      return _buildEmptyState(
        'No games played yet',
        'Start playing to see your game history!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: recentGames.length,
      itemBuilder: (context, index) {
        final session = recentGames[index];
        return _buildRecentGameCard(session, index);
      },
    );
  }

  Widget _buildRecentGameCard(GameSession session, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Game #${gameHistory.length - index}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(session.score).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatNumber(session.score),
                  style: TextStyle(
                    color: _getScoreColor(session.score),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatChip(
                Icons.trending_up,
                'Level ${session.level}',
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.horizontal_rule,
                '${session.linesCleared}',
                Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.access_time,
                _formatDuration(session.duration),
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(session.timestamp),
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final totalGames = _statsBox.get('totalGamesPlayed', defaultValue: 0);
    final averageScore = _statsBox.get('averageScore', defaultValue: 0.0);
    final highScore = Hive.box('highscore').get('highscore', defaultValue: 0);

    final totalLines = gameHistory.fold<int>(
      0,
      (sum, game) => sum + game.linesCleared,
    );
    final averageLevel = gameHistory.isEmpty
        ? 0.0
        : gameHistory.fold<double>(0, (sum, game) => sum + game.level) /
              gameHistory.length;
    final bestLevel = gameHistory.isEmpty
        ? 0
        : gameHistory.map((g) => g.level).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatsGrid([
            _StatCard(
              'Total Games',
              totalGames.toString(),
              Icons.games,
              Colors.blue,
            ),
            _StatCard(
              'High Score',
              _formatNumber(highScore),
              Icons.emoji_events,
              Colors.yellow,
            ),
            _StatCard(
              'Average Score',
              _formatNumber(averageScore.round()),
              Icons.analytics,
              Colors.green,
            ),
            _StatCard(
              'Best Level',
              bestLevel.toString(),
              Icons.trending_up,
              Colors.purple,
            ),
          ]),
          const SizedBox(height: 20),
          _buildStatsGrid([
            _StatCard(
              'Total Lines',
              _formatNumber(totalLines),
              Icons.horizontal_rule,
              Colors.orange,
            ),
            _StatCard(
              'Average Level',
              averageLevel.toStringAsFixed(1),
              Icons.timeline,
              Colors.cyan,
            ),
            _StatCard(
              'Games Today',
              _getGamesToday().toString(),
              Icons.today,
              Colors.pink,
            ),
            _StatCard(
              'Best Streak',
              '0',
              Icons.local_fire_department,
              Colors.red,
            ), // TODO: Implement streak tracking
          ]),
          const SizedBox(height: 30),
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(List<_StatCard> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                stat.color.withValues(alpha: 0.2),
                stat.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: stat.color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.icon, color: stat.color, size: 32),
              const SizedBox(height: 8),
              Text(
                stat.value,
                style: TextStyle(
                  color: stat.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievements() {
    final achievements = _getAchievements();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACHIEVEMENTS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        ...achievements.map(
          (achievement) => _buildAchievementCard(achievement),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(_Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.unlocked
            ? achievement.color.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.unlocked
              ? achievement.color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? achievement.color.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.unlocked ? achievement.color : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: achievement.unlocked ? Colors.white : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: achievement.unlocked ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: achievement.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'UNLOCKED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, color: Colors.white38, size: 64),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getScoreColor(int score) {
    if (score >= 50000) return Colors.purple;
    if (score >= 25000) return Colors.red;
    if (score >= 10000) return Colors.orange;
    if (score >= 5000) return Colors.yellow;
    if (score >= 1000) return Colors.green;
    return Colors.blue;
  }

  int _getGamesToday() {
    final today = DateTime.now();
    return gameHistory.where((game) {
      return game.timestamp.year == today.year &&
          game.timestamp.month == today.month &&
          game.timestamp.day == today.day;
    }).length;
  }

  List<_Achievement> _getAchievements() {
    final highScore = Hive.box('highscore').get('highscore', defaultValue: 0);
    final totalGames = gameHistory.length;
    final totalLines = gameHistory.fold<int>(
      0,
      (sum, game) => sum + game.linesCleared,
    );
    final bestLevel = gameHistory.isEmpty
        ? 0
        : gameHistory.map((g) => g.level).reduce((a, b) => a > b ? a : b);

    return [
      _Achievement(
        'First Steps',
        'Play your first game',
        Icons.play_arrow,
        Colors.green,
        totalGames >= 1,
      ),
      _Achievement(
        'Line Clearer',
        'Clear 100 lines total',
        Icons.horizontal_rule,
        Colors.blue,
        totalLines >= 100,
      ),
      _Achievement(
        'High Scorer',
        'Reach 10,000 points',
        Icons.star,
        Colors.yellow,
        highScore >= 10000,
      ),
      _Achievement(
        'Level Master',
        'Reach level 10',
        Icons.trending_up,
        Colors.purple,
        bestLevel >= 10,
      ),
      _Achievement(
        'Dedication',
        'Play 50 games',
        Icons.favorite,
        Colors.red,
        totalGames >= 50,
      ),
      _Achievement(
        'Line Master',
        'Clear 1000 lines total',
        Icons.whatshot,
        Colors.orange,
        totalLines >= 1000,
      ),
    ];
  }
}

class _StatCard {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatCard(this.label, this.value, this.icon, this.color);
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  _Achievement(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.unlocked,
  );
}
