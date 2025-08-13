

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Login/Screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/constants/color-constnats.dart';
import '../../../Model/admin-model.dart';
import '../Controller/auth-controller.dart';
import 'onboardScreen-1.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  keepLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey('uid')){
      String id= pref.getString('uid') ??"";
      print("5555555555555555$id");
      if(id!=""){
        DocumentSnapshot snapshot=await ref.read(loginControllerProvider.notifier).getAdminModel(id: id);
        if(snapshot.exists){
          AdminModel adminModel=AdminModel.fromMap(snapshot.data() as Map<String,dynamic>);
          ref.read(adminProvider.notifier).update((state) => adminModel,
          );
          Navigator.pushAndRemoveUntil(context,
            CupertinoPageRoute(builder: (context) =>  HomeScreen(admin: adminModel,),), (route) => false,
          );
        }
        else{
          print("not snaappppp");
          Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => OnboardingPage(),),(route) => false,);
        }
      }
      else{
        print("not iddddddd");
        Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => OnboardingPage(),),(route) => false,);
      }
    }
    else{
      print("keeeeeeeeeeeeeeeeeeeeeepno");
      Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => OnboardingPage(),),(route) => false,);
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      keepLogin();
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      body: Consumer(
          builder: (context,ref,child) {
            print("splashsssssssss");
            // final connectivityStatus = ref.watch(connectivityProvider);
            return Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.7,
                child:
                // connectivityStatus==ConnectivityStatus.connected?
                Image.asset('assets/images/refrrAdminLogo.jpg')
                    // :const InternetError(),
              ), // Splash image
            );
          }
      ),
    );
  }
}
