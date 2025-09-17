// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:enhanced_chameleon_ultra_gui/main.dart';

void main() {
  testWidgets('Enhanced Chameleon Ultra GUI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChameleonUltraApp());

    // Verify that the app starts with the correct title.
    expect(find.text('Enhanced Chameleon Ultra GUI'), findsOneWidget);

    // Verify that we have the main navigation elements.
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.terminal), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    expect(find.byIcon(Icons.build), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('Basic navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ChameleonUltraApp());

    // Test navigation to terminal page.
    await tester.tap(find.byIcon(Icons.terminal));
    await tester.pumpAndSettle();

    // Verify we're on the terminal page.
    expect(find.text('Terminal'), findsOneWidget);

    // Test navigation to cards page.
    await tester.tap(find.byIcon(Icons.credit_card));
    await tester.pumpAndSettle();

    // Verify we're on the cards page.
    expect(find.text('Card Slots'), findsOneWidget);
  });
}