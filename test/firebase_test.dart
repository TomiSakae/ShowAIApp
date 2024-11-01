import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
  });

  test('Sign in with email', () async {
    final result = await auth.signInWithEmailAndPassword(
      email: 'test@test.com',
      password: 'password123',
    );
    expect(result.user, isNotNull);
  });

  test('Firestore operations', () async {
    await firestore.collection('users').add({
      'name': 'Test User',
      'email': 'test@test.com',
    });

    final snapshot = await firestore.collection('users').get();
    expect(snapshot.docs.length, 1);
  });
}
