import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:refrr_admin/Core/common/global variables.dart';
import 'package:refrr_admin/Core/common/loader.dart';
import 'package:refrr_admin/Feature/Login/Screens/SplashScreen.dart';
import 'package:refrr_admin/Feature/Login/Screens/connectivity.dart';
import 'package:refrr_admin/Feature/Login/Screens/net-checkpage.dart';
import 'package:refrr_admin/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🚀 Ensure user is signed in anonymously
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      debugPrint('Signed in anonymously as: ${auth.currentUser?.uid}');
    } else {
      debugPrint('Already signed in as: ${auth.currentUser?.uid}');
    }

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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          width = MediaQuery.of(context).size.width;
          height = MediaQuery.of(context).size.height;
          return ConnectivityWrapper(child: SplashScreen());
        },
      ),
    );
  }
}