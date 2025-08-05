import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreBox = Hive.box('highscore');
    final highScore = scoreBox.get('highscore', defaultValue: 0);

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title
                const Spacer(flex: 2),
                _buildGameTitle(),
                const Spacer(flex: 3),

                // High Score Display
                _buildHighScoreCard(highScore),
                const SizedBox(height: 40),

                // Menu Buttons
                _buildMenuButtons(context),
                const Spacer(flex: 2),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTitle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColoredLetter('T', Colors.cyan),
            _buildColoredLetter('E', Colors.green),
            _buildColoredLetter('T', Colors.red),
            _buildColoredLetter('R', Colors.orange),
            _buildColoredLetter('I', Colors.purple),
            _buildColoredLetter('S', Colors.pink),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Classic Block Game',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildColoredLetter(String letter, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: color.withValues(alpha: 0.5),
              offset: const Offset(2.0, 2.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighScoreCard(int highScore) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: Colors.yellow, size: 32),
          const SizedBox(height: 8),
          const Text(
            'High Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            highScore.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        _buildMenuButton(
          'START GAME',
          Icons.play_arrow,
          Colors.green,
          () => Navigator.pushNamed(context, '/game'),
        ),
        const SizedBox(height: 15),
        _buildMenuButton(
          'HOW TO PLAY',
          Icons.help_outline,
          Colors.blue,
          () => _showHowToPlay(context),
        ),
        const SizedBox(height: 15),
        _buildMenuButton(
          'ABOUT',
          Icons.info_outline,
          Colors.purple,
          () => _showAbout(context),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: color, width: 2),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchURL('https://github.com'),
          child: Text(
            'Made with ❤️ in Flutter',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'v1.0.0',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
        ),
      ],
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B1B3D),
          title: const Text(
            'How to Play',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              '🎮 Controls:\n'
              '• Tap left/right arrows to move\n'
              '• Tap rotate button to rotate pieces\n'
              '• Tap down arrow for soft drop\n'
              '• Tap hard drop for instant drop\n\n'
              '🎯 Objective:\n'
              '• Fill complete horizontal lines to clear them\n'
              '• Prevent blocks from reaching the top\n'
              '• Score points by clearing lines\n\n'
              '⚡ Scoring:\n'
              '• 1 line = 100 × level\n'
              '• 2 lines = 300 × level\n'
              '• 3 lines = 500 × level\n'
              '• 4 lines = 800 × level (Tetris!)',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it!',
                style: TextStyle(color: Colors.cyan),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B1B3D),
          title: const Text(
            'About Tetris',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This is a modern implementation of the classic Tetris game, '
            'built with Flutter. Enjoy the nostalgic gameplay with smooth '
            'animations and responsive controls!\n\n'
            'Created as a learning project to demonstrate Flutter game development.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
