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

    // Test navigation to terminal page.
    await tester.tap(find.byIcon(Icons.terminal));
    await tester.pumpAndSettle();

    // Verify we're on the terminal page.
    expect(find.text('Terminal'), findsOneWidget);
    expect(find.text('proxmark3>'), findsAtLeastOneWidget);

    // Test navigation to cards page.
    await tester.tap(find.byIcon(Icons.credit_card));
    await tester.pumpAndSettle();

    // Verify we're on the cards page.
    expect(find.text('Card Slots'), findsOneWidget);

    // Test navigation to tools page.
    await tester.tap(find.byIcon(Icons.build));
    await tester.pumpAndSettle();

    // Verify we're on the tools page.
    expect(find.text('RFID Tools'), findsOneWidget);

    // Test navigation to settings page.
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify we're on the settings page.
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Command execution test', (WidgetTester tester) async {
    // Build our app and navigate to terminal.
    await tester.pumpWidget(const ChameleonUltraApp());
    await tester.tap(find.byIcon(Icons.terminal));
    await tester.pumpAndSettle();

    // Find the command input field.
    final commandInput = find.byType(TextField);
    expect(commandInput, findsOneWidget);

    // Enter a test command.
    await tester.enterText(commandInput, 'hw version');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Verify command was processed (mock response).
    expect(find.textContaining('Chameleon Ultra'), findsAtLeastOneWidget);
  });

  testWidgets('Card slot management test', (WidgetTester tester) async {
    // Build our app and navigate to cards page.
    await tester.pumpWidget(const ChameleonUltraApp());
    await tester.tap(find.byIcon(Icons.credit_card));
    await tester.pumpAndSettle();

    // Verify slot cards are displayed.
    expect(find.textContaining('Slot 1'), findsOneWidget);
    expect(find.textContaining('Slot 2'), findsOneWidget);
    expect(find.textContaining('MIFARE Classic 1k'), findsOneWidget);
    expect(find.textContaining('Empty'), findsAtLeastOneWidget);

    // Test slot selection.
    await tester.tap(find.textContaining('Slot 2'));
    await tester.pumpAndSettle();

    // Verify slot activation message.
    expect(find.textContaining('Slot 2 activated'), findsOneWidget);
  });

  testWidgets('Tools page functionality test', (WidgetTester tester) async {
    // Build our app and navigate to tools page.
    await tester.pumpWidget(const ChameleonUltraApp());
    await tester.tap(find.byIcon(Icons.build));
    await tester.pumpAndSettle();

    // Verify tool categories are displayed.
    expect(find.text('High Frequency (HF) Tools'), findsOneWidget);
    expect(find.text('Low Frequency (LF) Tools'), findsOneWidget);
    expect(find.text('Data Tools'), findsOneWidget);
    expect(find.text('Chameleon Tools'), findsOneWidget);

    // Test HF Search tool.
    await tester.tap(find.text('HF Search'));
    await tester.pumpAndSettle();

    // Verify tool dialog opened.
    expect(find.text('HF Search'), findsAtLeastOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Close dialog.
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });

  testWidgets('Settings page functionality test', (WidgetTester tester) async {
    // Build our app and navigate to settings page.
    await tester.pumpWidget(const ChameleonUltraApp());
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify settings sections are displayed.
    expect(find.text('Connection'), findsOneWidget);
    expect(find.text('Application'), findsOneWidget);
    expect(find.text('Commands'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // Test auto-connect toggle.
    final autoConnectSwitch = find.byType(Switch).first;
    await tester.tap(autoConnectSwitch);
    await tester.pumpAndSettle();

    // Test reset to defaults.
    await tester.tap(find.text('Reset to Defaults'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog.
    expect(find.text('Reset Settings'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // Cancel the reset.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}