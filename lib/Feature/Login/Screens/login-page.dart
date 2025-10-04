import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Core/constants/color-constnats.dart';
import '../../../Core/common/snackbar.dart';
import '../Controller/lead-controllor.dart';
import 'contact-us.dart';
import 'home.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late double width;
  late double height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    final loginState = ref.watch(leadControllerProvider);

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: height * .35,
                      width: double.infinity,
                      color: ColorConstants.primaryColor,
                      child: Padding(
                        padding: EdgeInsets.only(top: height * .13, left: width * .06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello!',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: width * .08,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Welcome to refrr Business',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: width * .035,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * .1),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(45),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height * .05),
                                Padding(
                                  padding: EdgeInsets.only(top: height * .01, left: width * .06),
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.roboto(
                                      fontSize: width * .06,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * .04),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * .05),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: ColorConstants.texFieldColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextFormField(
                                      controller: emailController,
                                      style: const TextStyle(color: Colors.grey),
                                      decoration: const InputDecoration(
                                        hintText: 'Email',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * .04),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * .05),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: ColorConstants.texFieldColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextFormField(
                                      controller: passwordController,
                                      obscureText: true,
                                      style: const TextStyle(color: Colors.grey),
                                      decoration: const InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * .04),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * .05),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (emailController.text.trim().isEmpty) {
                                        showCommonSnackbars(
                                          context: context,
                                          message: "Please enter your email",
                                        );
                                        return;
                                      }
                                      if (passwordController.text.trim().isEmpty) {
                                        showCommonSnackbars(
                                          context: context,
                                          message: "Please enter your password",
                                        );
                                        return;
                                      }
                                      ref.read(leadControllerProvider.notifier).loginLead(
                                        context: context,
                                        email: emailController.text.trim(),
                                        password: passwordController.text.trim(),

                                      );
                                    },
                                    child: Container(
                                      width: width * .9,
                                      height: height * .07,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: width * .004,
                                        ),
                                        borderRadius: BorderRadius.circular(width * .03),
                                      ),
                                      child: Center(
                                        child: loginState
                                            ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                            : Text(
                                          'Login',
                                          style: GoogleFonts.roboto(
                                            fontSize: width * .04,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * .02),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width * .05),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'If you are a new user',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300,
                                          fontSize: width * .035,
                                        ),
                                      ),
                                      SizedBox(width: width * .01),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ContactUs()),
                                          );
                                        },
                                        child: Text(
                                          'Contact Us',
                                          style: GoogleFonts.roboto(
                                            color: const Color.fromRGBO(0, 103, 176, 1),
                                            fontWeight: FontWeight.w400,
                                            fontSize: width * .035,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * .1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: height * .228,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: width * .22,
                      backgroundImage: const AssetImage('assets/images/fourthimage.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
