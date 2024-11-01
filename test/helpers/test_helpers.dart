import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelper {
  static Future<void> loadPage(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      MaterialApp(
        home: widget,
      ),
    );
    await tester.pumpAndSettle();
  }

  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
