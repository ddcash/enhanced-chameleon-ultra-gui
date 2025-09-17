import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enhanced_chameleon_ultra_gui/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app loads and displays hello world.
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Enhanced Chameleon Ultra GUI'), findsOneWidget);
  });
}