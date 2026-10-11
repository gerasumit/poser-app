import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poser/main.dart';

void main() {
  testWidgets('PoserApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PoserApp());

    // Verify that the title POSER is present on the home screen.
    expect(find.text('POSER'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });
}
