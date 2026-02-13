import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
/// Auth wrapper to ensure authentication before showing app
class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Check for errors
        if (snapshot.hasError) {
          debugPrint('Auth stream error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication Error',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _retryAuthentication(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // User is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          debugPrint('✅ Auth confirmed in UI: ${user.uid}');
          debugPrint('   Anonymous: ${user.isAnonymous}');
          return widget.child;
        }

        // No user, attempt to authenticate
        debugPrint('No user in stream, attempting authentication...');
        _attemptAuthentication();

        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Authenticating...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _attemptAuthentication() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
        debugPrint('✅ Re-authenticated anonymously');
      }
    } catch (e) {
      debugPrint('❌ Re-authentication failed: $e');
    }
  }

  Future<void> _retryAuthentication() async {
    setState(() {});
    await _attemptAuthentication();
  }
}