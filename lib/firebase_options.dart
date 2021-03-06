// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQg-jbc1logvuFXldOzBnBThFE_1omJBI',
    appId: '1:786002759666:web:207e378b8956a344f8a56b',
    messagingSenderId: '786002759666',
    projectId: 'daytoday-13eb8',
    authDomain: 'daytoday-13eb8.firebaseapp.com',
    databaseURL: 'https://daytoday-13eb8-default-rtdb.firebaseio.com',
    storageBucket: 'daytoday-13eb8.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBF3fRHl0fYMtcDAgRUGhTKSJV2xMX2jLE',
    appId: '1:786002759666:android:b4043d2d34ca40b2f8a56b',
    messagingSenderId: '786002759666',
    projectId: 'daytoday-13eb8',
    databaseURL: 'https://daytoday-13eb8-default-rtdb.firebaseio.com',
    storageBucket: 'daytoday-13eb8.appspot.com',
  );
}
