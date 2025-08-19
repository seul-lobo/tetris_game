import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'pages/game_page.dart';
import 'pages/menu_page.dart';
import 'pages/leaderboard_page.dart';
import 'game/tetris_game.dart';
import 'utils/screen_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive with additional storage
  await Hive.initFlutter();

  // Open all required boxes
  await Hive.openBox('highscore');
  await Hive.openBox('gameStats');
  await Hive.openBox('settings');
  await Hive.openBox('achievements');

  // Set system overlay style for better immersion
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1421),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TetrisGame()..loadStats()),
      ],
      child: MaterialApp(
        title: 'Tetris Game - Enhanced',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF2B1B3D),
            titleTextStyle: TextStyle(color: Colors.white),
            contentTextStyle: TextStyle(color: Colors.white70),
          ),
        ),
        home: const MenuPage(),
        routes: {
          '/game': (context) => const GamePage(),
          '/menu': (context) => const MenuPage(),
          '/leaderboard': (context) => const LeaderboardPage(),
        },
        builder: (context, child) {
          // Initialize ScreenUtils
          ScreenUtils.init(context);
          return child!;
        },
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/game':
              page = const GamePage();
              break;
            case '/leaderboard':
              page = const LeaderboardPage();
              break;
            default:
              page = const MenuPage();
          }

          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    );
  }
}
