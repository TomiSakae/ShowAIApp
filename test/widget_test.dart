// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showai/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class MockFirebasePlatform extends FirebasePlatform {
  final _app = MockFirebaseAppPlatform();
  final _apps = <FirebaseAppPlatform>[];

  @override
  bool get isAutomaticDataCollectionEnabled => true;

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    return _app;
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps;

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _apps.add(_app);
    return _app;
  }
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform()
      : super(
            '[DEFAULT]',
            const FirebaseOptions(
              apiKey: 'mock-api-key',
              appId: 'mock-app-id',
              messagingSenderId: 'mock-sender-id',
              projectId: 'mock-project-id',
            ));

  @override
  String get name => '[DEFAULT]';

  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'mock-api-key',
        appId: 'mock-app-id',
        messagingSenderId: 'mock-sender-id',
        projectId: 'mock-project-id',
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Setup mock Firebase Platform
    FirebasePlatform.instance = MockFirebasePlatform();
  });

  testWidgets('ShowAI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    ));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
