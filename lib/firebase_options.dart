import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'TEMP',
      appId: 'TEMP',
      messagingSenderId: 'TEMP',
      projectId: 'TEMP',
    );
  }
}
