import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyA2ur-ZtBGt30Hj9oCVuPBenvXlkQENmVc',
    appId: '1:336833825246:web:4c9de0d83e8a9a9356f54f',
    messagingSenderId: '336833825246',
    projectId: 'ashifportfolio-27f49',
    authDomain: 'ashifportfolio-27f49.firebaseapp.com',
    storageBucket: 'ashifportfolio-27f49.firebasestorage.app',
    measurementId: 'G-M5FEQKZC0H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2ur-ZtBGt30Hj9oCVuPBenvXlkQENmVc',
    appId: '1:336833825246:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '336833825246',
    projectId: 'ashifportfolio-27f49',
    storageBucket: 'ashifportfolio-27f49.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2ur-ZtBGt30Hj9oCVuPBenvXlkQENmVc',
    appId: '1:336833825246:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '336833825246',
    projectId: 'ashifportfolio-27f49',
    storageBucket: 'ashifportfolio-27f49.firebasestorage.app',
    iosBundleId: 'com.example.ashifportfolio',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2ur-ZtBGt30Hj9oCVuPBenvXlkQENmVc',
    appId: '1:336833825246:ios:YOUR_MAC_APP_ID',
    messagingSenderId: '336833825246',
    projectId: 'ashifportfolio-27f49',
    storageBucket: 'ashifportfolio-27f49.firebasestorage.app',
    iosBundleId: 'com.example.ashifportfolio',
  );
  
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA2ur-ZtBGt30Hj9oCVuPBenvXlkQENmVc',
    appId: '1:336833825246:web:4c9de0d83e8a9a9356f54f', // Use web app id for windows typically if no specific windows app
    messagingSenderId: '336833825246',
    projectId: 'ashifportfolio-27f49',
    authDomain: 'ashifportfolio-27f49.firebaseapp.com',
    storageBucket: 'ashifportfolio-27f49.firebasestorage.app',
    measurementId: 'G-M5FEQKZC0H',
  );
}
