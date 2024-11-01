import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showai/screens/chat_page.dart';

void main() {
  testWidgets('Chat UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(),
      ),
    );

    // Verify initial UI elements
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
  });
} 