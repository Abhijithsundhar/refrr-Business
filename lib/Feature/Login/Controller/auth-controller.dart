
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Core/common/snackbar.dart';
import 'package:refrr_admin/Feature/Login/Repository/auth-repository.dart';
import 'package:refrr_admin/Feature/Login/Screens/login-page.dart';

final loginControllerProvider = NotifierProvider<AuthController, bool>(() => AuthController());
class AuthController extends Notifier<bool>{
  @override
  bool build() {
    return false;
  }
  LoginRepository get _loginRepository => ref.read(loginRepositoryProvider);

  // affiliateLogin({required String userId,required String password,
  //   required BuildContext context,
  //   required Function() clear}) async {
  //   state=true;
  //   final admin = await _loginRepository.adminLogin(userId:userId,password:password);
  //   Future.delayed(Duration(seconds: 3),(){
  //     state=false;
  //   });
  //   admin.fold(
  //           (l) => showCommonSnackbars(context: context, message: l.failure),
  //           (adminModel) async {
  //         ref.read(adminProvider.notifier).update((state) => adminModel);
  //
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('uid', adminModel.userId ?? "");
  //
  //         if (context.mounted) {
  //           clear();
  //           Navigator.pushAndRemoveUntil(
  //             context,
  //             CupertinoPageRoute(builder: (context) =>  HomeScreen(lead: ,)),
  //                 (route) => false,
  //           );
  //         }
  //       }
  //   );
  // }
  /// reset password
  resetPassword({required String userId,
    required String password,
    required BuildContext context}) async {
    state=true;
    final admin = await _loginRepository.resetPassword(password: password, userId: userId);
    Future.delayed(Duration(seconds: 3),(){
      state=false;
      admin.fold((l) => showCommonSnackbars(context: context,message:l.failure), (adminModel) async {
        ref.read(adminProvider.notifier).update((state) => adminModel,);
        showCommonSnackbars(context: context, message: "Password reset Successfully");
      });
    });
  }
  /// logout
  logOut({required BuildContext context}) async {
    state=true;
    final admin = await _loginRepository.logOut();
    admin.fold((l) => showCommonSnackbars(context: context,message:l.failure), (r) async {
      showCommonSnackbars(context: context, message: "Log out Successfully");
      Future.delayed(Duration(seconds: 1),(){
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => const LoginPage(),),(route) => false);
        ref.read(adminProvider.notifier).update((state) => null,);
        state=false;
      });
    });
  }
  Future<DocumentSnapshot> getAdminModel({required String id}) async {
    return await _loginRepository.getAdminModel(id: id);
  }
}
