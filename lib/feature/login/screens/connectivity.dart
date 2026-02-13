import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/core/common/loader.dart';
import 'package:refrr_admin/feature/login/screens/net_check_page.dart';

/// Global connectivity provider (NO autoDispose - keeps running)
final connectivityStreamProvider = StreamProvider((ref) async* {
  final connectivity = Connectivity();

  final initial = await connectivity.checkConnectivity();
  yield initial.isNotEmpty ? initial.first : ConnectivityResult.none;

  yield* connectivity.onConnectivityChanged.map(
        (list) => list.isNotEmpty ? list.first : ConnectivityResult.none,
  );
});

/// Wrapper widget that monitors connectivity throughout the app
class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStreamProvider);

    return connectivity.when(
      data: (status) {
        // 🚫 No network = show offline page
        if (status == ConnectivityResult.none) {
          return const NetWorkChecker();
        }
        // ✅ Network available = show normal content
        return child;
      },
      loading: () => const Scaffold(
        body: Center(child: CommonLoader()),
      ),
      error: (_, __) => const NetWorkChecker(),
    );
  }
}
