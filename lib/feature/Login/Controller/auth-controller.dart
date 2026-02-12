import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:refrr_admin/Core/common/globalVariables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Login/Repository/auth-repository.dart';
import 'package:refrr_admin/Feature/Login/Screens/login-page.dart';
import 'package:refrr_admin/Feature/Login/Screens/contact-us.dart';

final loginControllerProvider =
NotifierProvider<AuthController, bool>(() => AuthController());

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  LoginRepository get _loginRepository => ref.read(loginRepositoryProvider);

  /// ========== LOGIN METHOD ==========
  Future<void> loginAdmin({
    required BuildContext context,
    required String userId,
    required String password,
  }) async {
    state = true;

    final result = await _loginRepository.adminLogin(
      userId: userId,
      password: password,
    );

    result.fold(
      // ❌ Login failed
          (failure) {
        state = false;

        // 🔴 CHECK IF ACCOUNT IS DELETED
        if (failure.failure == "ACCOUNT_DELETED") {
          _showDeletedAccountSnackbar(context);
        } else {
          // Show normal error
          showCommonSnackbars(context: context, message: failure.failure);
        }
      },
      // ✅ Login success
          (adminModel) {
        state = false;
        ref.read(adminProvider.notifier).update((state) => adminModel);
        showCommonSnackbars(context: context, message: "Login Successfully");

        // Navigate to home screen
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomeScreen()),
        // );
      },
    );
  }

  /// ========== SHOW DELETED ACCOUNT SNACKBAR ==========
  void _showDeletedAccountSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                "Your account has been deleted. Contact admin for recovery or create a new account.",
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.035,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        margin: EdgeInsets.all(width * 0.04),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.035,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Contact Us',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUs()),
            );
          },
        ),
      ),
    );
  }

  /// ========== RESET PASSWORD ==========
  resetPassword({
    required String userId,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final admin = await _loginRepository.resetPassword(
      password: password,
      userId: userId,
    );
    Future.delayed(const Duration(seconds: 3), () {
      state = false;
      admin.fold(
            (l) => showCommonSnackbars(context: context, message: l.failure),
            (adminModel) async {
          ref.read(adminProvider.notifier).update((state) => adminModel);
          showCommonSnackbars(
              context: context, message: "Password reset Successfully");
        },
      );
    });
  }

  /// ========== LOGOUT ==========
  logOut({required BuildContext context}) async {
    state = true;
    final admin = await _loginRepository.logOut();
    admin.fold(
          (l) => showCommonSnackbars(context: context, message: l.failure),
          (r) async {
        showCommonSnackbars(context: context, message: "Log out Successfully");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
          ref.read(adminProvider.notifier).update((state) => null);
          state = false;
        });
      },
    );
  }

  /// ========== GET ADMIN MODEL ==========
  Future<DocumentSnapshot> getAdminModel({required String id}) async {
    return await _loginRepository.getAdminModel(id: id);
  }
}
