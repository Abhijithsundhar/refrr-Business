import 'dart:ui';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/auth_wrapper.dart';
import 'package:refrr_admin/feature/login/screens/connectivity.dart';
import 'package:refrr_admin/feature/login/screens/splash_screen.dart';
import 'package:refrr_admin/firebase_options_dev.dart';
import 'package:refrr_admin/firebase_options_pro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  try {
    // Your existing Firebase initialization logic
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: env == 'dev'
              ? DevelopmentFirebaseOptions.currentPlatform
              : ProductionFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      if (!e.toString().contains('duplicate-app')) {
        rethrow;
      }
    }

    // --- NEW: Crashlytics and App Check Setup ---

    // Print current environment for easy debugging
    print("------------------------------------------");
    print("🔗 ENVIRONMENT: ${env.toUpperCase()}");
    print("📂 PROJECT ID: ${Firebase.app().options.projectId}");
    print("------------------------------------------");

    // Activate App Check (using debug provider for local testing)
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      // appleProvider: AppleProvider.appAttest, // Use for production
    );

    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true; // Mark as handled
    };

    // Enable Crashlytics collection in development for testing
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    debugPrint("✅ Firebase Crashlytics initialized and collection enabled");

    // --- End of New Setup ---

    // Ensure user is signed in anonymously (your existing function)
    await _ensureAuthenticated();

  } catch (e, s) { // NEW: Capture stack trace for better debugging
    debugPrint('🔥 Firebase init error: $e');
    debugPrintStack(stackTrace: s);
  }

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}
/// Ensures user is authenticated (anonymously)
Future<void> _ensureAuthenticated() async {
  final auth = FirebaseAuth.instance;

  try {
    // Wait for auth state to initialize
    await auth.authStateChanges().first;

    User? currentUser = auth.currentUser;

    if (currentUser == null) {
      debugPrint('No user found, signing in anonymously...');
      UserCredential userCredential = await auth.signInAnonymously();
      debugPrint('✅ Signed in anonymously as: ${userCredential.user?.uid}');
    } else {
      debugPrint('✅ Already signed in as: ${currentUser.uid}');
      debugPrint('   Is Anonymous: ${currentUser.isAnonymous}');
    }

    // Add auth state listener for debugging
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('⚠️ Auth state changed: User signed out');
      } else {
        debugPrint('🔄 Auth state changed: ${user.uid} (Anonymous: ${user.isAnonymous})');
      }
    });

    // Small delay to ensure auth state propagates
    await Future.delayed(const Duration(milliseconds: 300));

  } catch (e) {
    debugPrint('❌ Authentication error: $e');
    // Attempt to continue anyway
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(
        child: Builder(
          builder: (context) {
            width = MediaQuery.of(context).size.width;
            height = MediaQuery.of(context).size.height;
            return ConnectivityWrapper(child: SplashScreen());
          },
        ),
      ),
    );
  }
}