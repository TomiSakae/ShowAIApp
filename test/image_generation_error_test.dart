import 'package:flutter_test/flutter_test.dart';
import 'package:showai/screens/image_generation_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Show error on empty prompt', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ImageGenerationScreen(),
      ),
    );

    // Tap generate without entering prompt
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Vui lòng nhập prompt'), findsOneWidget);
  });
}
