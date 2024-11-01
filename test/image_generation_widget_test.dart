import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showai/screens/image_generation_screen.dart';

void main() {
  testWidgets('Image Generation Screen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ImageGenerationScreen(),
      ),
    );

    // Kiểm tra các widget cơ bản
    expect(find.text('Tạo hình ảnh AI'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Image Generation Form Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ImageGenerationScreen(),
      ),
    );

    // Nhập prompt
    await tester.enterText(find.byType(TextField).first, 'Test prompt');

    // Tap generate button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify loading state or response
    // (tùy thuộc vào implementation của bạn)
  });
}
