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
    apiKey: 'AIzaSyC4oUWcoFkm8rL4LibmmqyAqUwI_ZuuIW4',
    appId: '1:867573064613:web:2585ea8390db433e507e4c',
    messagingSenderId: '867573064613',
    projectId: 'macro-global-app-test',
    authDomain: 'macro-global-app-test.firebaseapp.com',
    storageBucket: 'macro-global-app-test.firebasestorage.app',
    measurementId: 'G-38TBWYS0ED',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLmocz1d3gr2z8HB7EvH7x3j7jIdkh_O0',
    appId: '1:867573064613:android:d92ebc511acf9a00507e4c',
    messagingSenderId: '867573064613',
    projectId: 'macro-global-app-test',
    storageBucket: 'macro-global-app-test.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPAGDiIVJlBvdxTPfGVemU-OoRj9CSaVo',
    appId: '1:867573064613:ios:f4f2de95b972a020507e4c',
    messagingSenderId: '867573064613',
    projectId: 'macro-global-app-test',
    storageBucket: 'macro-global-app-test.firebasestorage.app',
    iosBundleId: 'com.example.macroGlobalTestApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPAGDiIVJlBvdxTPfGVemU-OoRj9CSaVo',
    appId: '1:867573064613:ios:f4f2de95b972a020507e4c',
    messagingSenderId: '867573064613',
    projectId: 'macro-global-app-test',
    storageBucket: 'macro-global-app-test.firebasestorage.app',
    iosBundleId: 'com.example.macroGlobalTestApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC4oUWcoFkm8rL4LibmmqyAqUwI_ZuuIW4',
    appId: '1:867573064613:web:71f8284716c8891b507e4c',
    messagingSenderId: '867573064613',
    projectId: 'macro-global-app-test',
    authDomain: 'macro-global-app-test.firebaseapp.com',
    storageBucket: 'macro-global-app-test.firebasestorage.app',
    measurementId: 'G-LBXG7MH0TQ',
  );
}
