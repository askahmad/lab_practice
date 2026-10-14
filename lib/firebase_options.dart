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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALz_sNMHZr0i3F5RKusyI1-0HT9UugLz0',
    appId: '1:664633188895:web:0c784f41d7fd76f79dab2a',
    messagingSenderId: '664633188895',
    projectId: 'lab-practice-f2836',
    authDomain: 'lab-practice-f2836.firebaseapp.com',
    storageBucket: 'lab-practice-f2836.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALz_sNMHZr0i3F5RKusyI1-0HT9UugLz0',
    appId: '1:664633188895:android:0c784f41d7fd76f79dab2a',
    messagingSenderId: '664633188895',
    projectId: 'lab-practice-f2836',
    storageBucket: 'lab-practice-f2836.firebasestorage.app',
  );
}
