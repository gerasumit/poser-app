import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:poser/main.dart';
import 'package:poser/providers/game_provider.dart';
import 'package:poser/screens/game_flow_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  testWidgets('PoserApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PoserApp());

    // Verify that the title POSER is present on the home screen.
    expect(find.text('POSER'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });

  testWidgets('PassRevealWidget disables button until peeked and shows START GAME on last player', (WidgetTester tester) async {
    final provider = GameProvider();
    provider.addPlayer('Alice');
    provider.addPlayer('Bob');
    provider.startGame();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: const PassRevealWidget(),
        ),
      ),
    );
    await tester.pump();

    // Initially button should show NEXT PLAYER
    expect(find.text('NEXT PLAYER'), findsOneWidget);

    // Try tapping button without peeking - should not advance (button disabled)
    final buttonFinder = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

    // Press and hold (peek) on the reveal card
    final gesture = await tester.startGesture(tester.getCenter(find.byType(GestureDetector).first));
    await tester.pump();

    // Now button should be enabled
    expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNotNull);

    // Release press
    await gesture.up();
    await tester.pump();

    // Tap next player
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Now on player 2 (last player)
    expect(provider.currentRevealIndex, 1);
    expect(find.text('START GAME'), findsOneWidget);
  });
}
