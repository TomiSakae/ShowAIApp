// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7tpdWTa5usWWTI3T5y5aoUmzYOGbAqro',
    appId: '1:1031619693187:web:44e25302986cdd1c1ba9b6',
    messagingSenderId: '1031619693187',
    projectId: 'showai-tomi',
    authDomain: 'showai-tomi.firebaseapp.com',
    storageBucket: 'showai-tomi.appspot.com',
    measurementId: 'G-01T6CDB742',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCNka5y1ZrPDhHlHmr1GgUNbf3V5BhdnqA',
    appId: '1:1031619693187:android:2149e1a0f0f806fb1ba9b6',
    messagingSenderId: '1031619693187',
    projectId: 'showai-tomi',
    storageBucket: 'showai-tomi.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5E6d9H1kB60v64-bAublpO9LB5RSyt8k',
    appId: '1:1031619693187:ios:fe3eb21293680f691ba9b6',
    messagingSenderId: '1031619693187',
    projectId: 'showai-tomi',
    storageBucket: 'showai-tomi.appspot.com',
    iosClientId: '1031619693187-7afvldduhp8fk2m1avrkm4lchflo1t4c.apps.googleusercontent.com',
    iosBundleId: 'com.example.showai',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5E6d9H1kB60v64-bAublpO9LB5RSyt8k',
    appId: '1:1031619693187:ios:fe3eb21293680f691ba9b6',
    messagingSenderId: '1031619693187',
    projectId: 'showai-tomi',
    storageBucket: 'showai-tomi.appspot.com',
    iosClientId: '1031619693187-7afvldduhp8fk2m1avrkm4lchflo1t4c.apps.googleusercontent.com',
    iosBundleId: 'com.example.showai',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC7tpdWTa5usWWTI3T5y5aoUmzYOGbAqro',
    appId: '1:1031619693187:web:c5a1f305e67aa6191ba9b6',
    messagingSenderId: '1031619693187',
    projectId: 'showai-tomi',
    authDomain: 'showai-tomi.firebaseapp.com',
    storageBucket: 'showai-tomi.appspot.com',
    measurementId: 'G-FTQJ3T65DD',
  );
}
