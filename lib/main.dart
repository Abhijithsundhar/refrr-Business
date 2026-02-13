import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/constants/auth_wrapper.dart';
import 'package:refrr_admin/feature/Login/screens/connectivity.dart';
import 'package:refrr_admin/feature/login/screens/splash_screen.dart';
import 'package:refrr_admin/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Ensure user is signed in anonymously
    await _ensureAuthenticated();

  } catch (e) {
    debugPrint('Firebase init error: $e');
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AuthWrapper(
        child: Builder(
          builder: (context) {
            width = MediaQuery.of(context).size.width;
            height = MediaQuery.of(context).size.height;
            return  ConnectivityWrapper(child: SplashScreen());
          },
        ),
      ),
    );
  }
}



