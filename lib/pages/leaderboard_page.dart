import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris_game/models/game_session.dart';
import '../game/tetris_game.dart';
import '../utils/screen_utils.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
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
              _buildGoldenTabBar(),
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
      padding: EdgeInsets.all(ScreenUtils.wp(5)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: ScreenUtils.getScaledSize(28),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(width: ScreenUtils.wp(4)),
          Text(
            'LEADERBOARD',
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ).copyWith(letterSpacing: 2),
          ),
          const Spacer(),
          Consumer<TetrisGame>(
            builder: (context, game, child) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtils.wp(3),
                  vertical: ScreenUtils.hp(0.8),
                ),
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
                    Icon(
                      Icons.emoji_events,
                      color: Colors.yellow,
                      size: ScreenUtils.getScaledSize(16),
                    ),
                    SizedBox(width: ScreenUtils.wp(1)),
                    Text(
                      '${game.gameHistory.length}',
                      style: ScreenUtils.getResponsiveTextStyle(
                        baseFontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtils.wp(5)),
      child: Row(
        children: [
          _buildTabItem('HIGH SCORE', 0),
          _buildTabItem('RECENT', 1),
          _buildTabItem('STATISTICS', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: ScreenUtils.wp(1)),
          padding: EdgeInsets.symmetric(vertical: ScreenUtils.hp(1.5)),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB347)],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? Colors.amber
                  : Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: ScreenUtils.getResponsiveTextStyle(
                baseFontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighScoresTab() {
    return Consumer<TetrisGame>(
      builder: (context, game, child) {
        final topScores = [...game.gameHistory]
          ..sort((a, b) => b.score.compareTo(a.score))
          ..take(10);

        return ListView.builder(
          padding: ScreenUtils.getResponsivePadding(),
          itemCount: topScores.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCurrentHighScore(game.highScore);
            }

            final session = topScores.elementAt(index - 1);
            return _buildScoreCard(session, index);
          },
        );
      },
    );
  }

  Widget _buildCurrentHighScore(int highScore) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtils.hp(3)),
      padding: EdgeInsets.all(ScreenUtils.wp(6)),
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
          Icon(
            Icons.emoji_events,
            color: Colors.yellow,
            size: ScreenUtils.getScaledSize(48),
          ),
          SizedBox(height: ScreenUtils.hp(1.5)),
          Text(
            'ALL-TIME HIGH SCORE',
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ).copyWith(letterSpacing: 1),
          ),
          SizedBox(height: ScreenUtils.hp(1)),
          Text(
            _formatNumber(highScore),
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
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
      margin: EdgeInsets.only(bottom: ScreenUtils.hp(1.5)),
      padding: EdgeInsets.all(ScreenUtils.wp(4)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtils.getScaledSize(40),
            height: ScreenUtils.getScaledSize(40),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: rankColor, width: 2),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: ScreenUtils.getResponsiveTextStyle(
                  baseFontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtils.wp(4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatNumber(session.score),
                  style: ScreenUtils.getResponsiveTextStyle(
                    baseFontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ScreenUtils.hp(0.5)),
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: Colors.cyan,
                      size: ScreenUtils.getScaledSize(14),
                    ),
                    SizedBox(width: ScreenUtils.wp(1)),
                    Text(
                      'Level ${session.level}',
                      style: ScreenUtils.getResponsiveTextStyle(
                        baseFontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.wp(4)),
                    Icon(
                      Icons.horizontal_rule,
                      color: Colors.orange,
                      size: ScreenUtils.getScaledSize(14),
                    ),
                    SizedBox(width: ScreenUtils.wp(1)),
                    Text(
                      '${session.linesCleared} lines',
                      style: ScreenUtils.getResponsiveTextStyle(
                        baseFontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _formatDate(session.timestamp),
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 11,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGamesTab() {
    return Consumer<TetrisGame>(
      builder: (context, game, child) {
        final recentGames = game.gameHistory.take(20).toList();

        if (recentGames.isEmpty) {
          return _buildEmptyState(
            'No games played yet',
            'Start playing to see your game history!',
          );
        }

        return ListView.builder(
          padding: ScreenUtils.getResponsivePadding(),
          itemCount: recentGames.length,
          itemBuilder: (context, index) {
            final session = recentGames[index];
            return _buildRecentGameCard(
              session,
              index,
              game.gameHistory.length,
            );
          },
        );
      },
    );
  }

  Widget _buildRecentGameCard(GameSession session, int index, int totalGames) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtils.hp(1.5)),
      padding: EdgeInsets.all(ScreenUtils.wp(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Game number badge
          Container(
            width: ScreenUtils.getScaledSize(50),
            height: ScreenUtils.getScaledSize(50),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Center(
              child: Text(
                '${totalGames - index}',
                style: ScreenUtils.getResponsiveTextStyle(
                  baseFontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtils.wp(4)),

          // Game details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatNumber(session.score),
                      style: ScreenUtils.getResponsiveTextStyle(
                        baseFontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatRelativeTime(session.timestamp),
                      style: ScreenUtils.getResponsiveTextStyle(
                        baseFontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.hp(0.8)),
                Row(
                  children: [
                    _buildMiniStat(
                      'LVL ${session.level}',
                      Colors.green,
                      Icons.trending_up,
                    ),
                    SizedBox(width: ScreenUtils.wp(3)),
                    _buildMiniStat(
                      '${session.linesCleared}L',
                      Colors.orange,
                      Icons.horizontal_rule,
                    ),
                    SizedBox(width: ScreenUtils.wp(3)),
                    _buildMiniStat(
                      _formatDuration(session.duration),
                      Colors.purple,
                      Icons.timer,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String text, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.wp(2),
        vertical: ScreenUtils.hp(0.3),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: ScreenUtils.getScaledSize(12)),
          SizedBox(width: ScreenUtils.wp(1)),
          Text(
            text,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Consumer<TetrisGame>(
      builder: (context, game, child) {
        if (game.gameHistory.isEmpty) {
          return _buildEmptyState(
            'No statistics yet',
            'Play some games to see your stats!',
          );
        }

        return SingleChildScrollView(
          padding: ScreenUtils.getResponsivePadding(),
          child: Column(
            children: [
              _buildStatsOverview(game),
              SizedBox(height: ScreenUtils.hp(3)),
              _buildDetailedStats(game),
              SizedBox(height: ScreenUtils.hp(3)),
              _buildAchievements(game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsOverview(TetrisGame game) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.wp(5)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'GAME STATISTICS',
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ).copyWith(letterSpacing: 2),
          ),
          SizedBox(height: ScreenUtils.hp(3)),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  'GAMES PLAYED',
                  game.totalGamesPlayed.toString(),
                  Colors.cyan,
                  Icons.sports_esports,
                ),
              ),
              SizedBox(width: ScreenUtils.wp(3)),
              Expanded(
                child: _buildStatTile(
                  'TOTAL LINES',
                  game.totalLinesCleared.toString(),
                  Colors.orange,
                  Icons.horizontal_rule,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.hp(2)),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  'AVG SCORE',
                  _formatNumber(game.averageScore.round()),
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: ScreenUtils.wp(3)),
              Expanded(
                child: _buildStatTile(
                  'BEST LEVEL',
                  _getBestLevel(game).toString(),
                  Colors.purple,
                  Icons.star,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.wp(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: ScreenUtils.getScaledSize(24)),
          SizedBox(height: ScreenUtils.hp(1)),
          Text(
            value,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: ScreenUtils.hp(0.5)),
          Text(
            label,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(TetrisGame game) {
    final totalScore = game.gameHistory.fold<int>(
      0,
      (sum, session) => sum + session.score,
    );
    final totalTime = game.gameHistory.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.duration,
    );
    final averageLevel = game.gameHistory.isEmpty
        ? 0.0
        : game.gameHistory.fold<double>(
                0,
                (sum, session) => sum + session.level,
              ) /
              game.gameHistory.length;

    return Container(
      padding: EdgeInsets.all(ScreenUtils.wp(5)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAILED ANALYTICS',
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ).copyWith(letterSpacing: 1),
          ),
          SizedBox(height: ScreenUtils.hp(2)),
          _buildDetailRow(
            'Total Score',
            _formatNumber(totalScore),
            Colors.cyan,
          ),
          _buildDetailRow(
            'Total Playtime',
            _formatLongDuration(totalTime),
            Colors.green,
          ),
          _buildDetailRow(
            'Average Level',
            averageLevel.toStringAsFixed(1),
            Colors.orange,
          ),
          _buildDetailRow(
            'Lines per Game',
            _getLinesPerGame(game),
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenUtils.hp(0.8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(TetrisGame game) {
    List<Achievement> achievements = _calculateAchievements(game);

    return Container(
      padding: EdgeInsets.all(ScreenUtils.wp(5)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: ScreenUtils.getScaledSize(24),
              ),
              SizedBox(width: ScreenUtils.wp(2)),
              Text(
                'ACHIEVEMENTS',
                style: ScreenUtils.getResponsiveTextStyle(
                  baseFontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ).copyWith(letterSpacing: 1),
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.hp(2)),
          ...achievements.map(
            (achievement) => _buildAchievementTile(achievement),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement achievement) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtils.hp(1)),
      padding: EdgeInsets.all(ScreenUtils.wp(3)),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? Colors.amber.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ScreenUtils.wp(2)),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? Colors.amber.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked ? Colors.amber : Colors.grey,
              size: ScreenUtils.getScaledSize(20),
            ),
          ),
          SizedBox(width: ScreenUtils.wp(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: ScreenUtils.getResponsiveTextStyle(
                    baseFontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? Colors.amber
                        : Colors.white70,
                  ),
                ),
                Text(
                  achievement.description,
                  style: ScreenUtils.getResponsiveTextStyle(
                    baseFontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.isUnlocked)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.wp(2),
                vertical: ScreenUtils.hp(0.3),
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Text(
                'UNLOCKED',
                style: ScreenUtils.getResponsiveTextStyle(
                  baseFontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
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
          Icon(
            Icons.videogame_asset_off,
            color: Colors.white.withValues(alpha: 0.3),
            size: ScreenUtils.getScaledSize(64),
          ),
          SizedBox(height: ScreenUtils.hp(2)),
          Text(
            title,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          SizedBox(height: ScreenUtils.hp(1)),
          Text(
            subtitle,
            style: ScreenUtils.getResponsiveTextStyle(
              baseFontSize: 14,
              color: Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtils.hp(4)),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/game');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.wp(8),
                vertical: ScreenUtils.hp(1.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.cyan, width: 2),
              ),
            ),
            child: Text(
              'START PLAYING',
              style: ScreenUtils.getResponsiveTextStyle(
                baseFontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
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

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatLongDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _getLinesPerGame(TetrisGame game) {
    if (game.gameHistory.isEmpty) return '0.0';
    final average = game.totalLinesCleared / game.gameHistory.length;
    return average.toStringAsFixed(1);
  }

  int _getBestLevel(TetrisGame game) {
    if (game.gameHistory.isEmpty) return 0;
    return game.gameHistory
        .map((session) => session.level)
        .reduce((a, b) => a > b ? a : b);
  }

  List<Achievement> _calculateAchievements(TetrisGame game) {
    return [
      Achievement(
        title: 'First Steps',
        description: 'Play your first game',
        icon: Icons.play_arrow,
        isUnlocked: game.gameHistory.isNotEmpty,
      ),
      Achievement(
        title: 'Score Hunter',
        description: 'Reach 10,000 points',
        icon: Icons.turn_sharp_right_rounded,
        isUnlocked: game.highScore >= 10000,
      ),
      Achievement(
        title: 'Line Clearer',
        description: 'Clear 100 total lines',
        icon: Icons.horizontal_rule,
        isUnlocked: game.totalLinesCleared >= 100,
      ),
      Achievement(
        title: 'Speed Demon',
        description: 'Reach level 10',
        icon: Icons.speed,
        isUnlocked: _getBestLevel(game) >= 10,
      ),
      Achievement(
        title: 'Tetris Master',
        description: 'Score 50,000 points',
        icon: Icons.emoji_events,
        isUnlocked: game.highScore >= 50000,
      ),
      Achievement(
        title: 'Persistent Player',
        description: 'Play 50 games',
        icon: Icons.refresh,
        isUnlocked: game.totalGamesPlayed >= 50,
      ),
      Achievement(
        title: 'Line Destroyer',
        description: 'Clear 1000 total lines',
        icon: Icons.whatshot,
        isUnlocked: game.totalLinesCleared >= 1000,
      ),
      Achievement(
        title: 'The Legend',
        description: 'Score 100,000 points',
        icon: Icons.star,
        isUnlocked: game.highScore >= 100000,
      ),
    ];
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}
