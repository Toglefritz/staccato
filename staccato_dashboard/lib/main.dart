import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/firebase/firebase_options.dart';
import 'services/firebase/dev_machine_ip.dart';
import 'staccato_dashboard_app.dart';

/// Main function that initializes services and runs the app.
///
/// This function handles all necessary initialization including Firebase and local storage setup before launching the
/// UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Get the use_emulator boolean from the `flutter run` command to determine if the Firebase Emulator Suite should
  // be used. The `fromEnvironment` method returns false by default if the argument is not passed.
  // To run the app with the emulator, use the following command:
  // flutter run --dart-define=USE_FIREBASE_EMULATOR=true
  const bool useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

  // In debug mode, use the Firebase local emulator.
  if (kDebugMode && useFirebaseEmulator) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator(devMachineIP, 8080);
      await FirebaseAuth.instance.useAuthEmulator(devMachineIP, 9099);

      debugPrint('Using Firebase emulator suite');
    } catch (e) {
      debugPrint('Firebase emulator initialization failed with exception, $e');
    }
  }

  runApp(const StaccatoDashboardApp());
}
