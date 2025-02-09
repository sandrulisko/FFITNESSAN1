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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCiI-NyZUu0EaZffOeYpf0_MvLbJO3N_j4',
    appId: '1:169115161872:web:5f74f95a5750e850f48195',
    messagingSenderId: '169115161872',
    projectId: 'myfitnesan',
    authDomain: 'myfitnesan.firebaseapp.com',
    storageBucket: 'myfitnesan.firebasestorage.app',
    measurementId: 'G-JKFL8W5B4H',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCw9ZNvwxz8Rbi5DNgahbvBfr_KF0M9eY8',
    appId: '1:169115161872:ios:f0b1b2d21ce4bd73f48195',
    messagingSenderId: '169115161872',
    projectId: 'myfitnesan',
    storageBucket: 'myfitnesan.firebasestorage.app',
    iosBundleId: 'com.example.fitnesSan',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCiI-NyZUu0EaZffOeYpf0_MvLbJO3N_j4',
    appId: '1:169115161872:web:941bf7720094a900f48195',
    messagingSenderId: '169115161872',
    projectId: 'myfitnesan',
    authDomain: 'myfitnesan.firebaseapp.com',
    storageBucket: 'myfitnesan.firebasestorage.app',
    measurementId: 'G-SPV6WFDC86',
  );
}
