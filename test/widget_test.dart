import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_game/main.dart';

void main() {
  testWidgets('Tetris app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TetrisApp());

    // Verify that the menu screen loads
    expect(find.text('TETRIS'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
  });
}