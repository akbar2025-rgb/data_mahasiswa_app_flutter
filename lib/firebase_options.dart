import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web belum dikonfigurasi untuk proyek ini.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS belum dikonfigurasi untuk proyek ini.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows belum dikonfigurasi untuk proyek ini.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux belum dikonfigurasi untuk proyek ini.');
      default:
        throw UnsupportedError('Platform tidak didukung.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtqZJ4Q7RKmrn8S2QLgoJPuziYj1O6JaA',
    appId: '1:107933013652:android:d2d5fc6d0dde186ce54681',
    messagingSenderId: '107933013652',
    projectId: 'datamahasiswa-24811',
    storageBucket: 'datamahasiswa-24811.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDYZtl88ImbEG8xmGOB8HcoaB7k1BGzS8',
    appId: '1:107933013652:ios:e2bee55410bff5aae54681',
    messagingSenderId: '107933013652',
    projectId: 'datamahasiswa-24811',
    storageBucket: 'datamahasiswa-24811.firebasestorage.app',
    iosBundleId: 'com.unnga.dataMahasiswaApp',
  );
}
