import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnimplementedError(
      'Firebase configuration is missing. Run `flutterfire configure` in your project directory after creating the Firebase Android app, then replace this placeholder with the generated firebase_options.dart file.',
    );
  }
}
