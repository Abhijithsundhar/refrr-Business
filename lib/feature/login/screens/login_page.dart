import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:refrr_admin/core/common/global_variables.dart';
import 'package:refrr_admin/core/common/snackbar.dart';
import 'package:refrr_admin/core/constants/colorconstnats.dart';
import 'package:refrr_admin/feature/login/Controller/lead_controller.dart';
import 'package:refrr_admin/feature/login/screens/contact_us.dart';


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(leadControllerProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(height: height * .3),

                /// CARD
                Container(
                  width: width * 0.9,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: height * 0.03,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xFFe5e9eb))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Center(
                        child: SvgPicture.asset('assets/svg/GRRO-SVG.svg'),
                      ),
                      SizedBox(height: height * 0.03),

                      /// EMAIL FIELD
                      SizedBox(
                         height: height*.065,
                        child: TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: ColorConstants.primaryColor,
                              fontSize: 14,
                            ),

                            prefixIcon: Icon(Icons.email_outlined, color: ColorConstants.primaryColor),

                            // Enable this for floating label like your screenshot
                            floatingLabelBehavior: FloatingLabelBehavior.auto,

                            // Border style (GREEN like screenshot)
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: ColorConstants.primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: ColorConstants.primaryColor, width: 2),
                            ),

                            // Padding
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 18,
                            ),
                          ),

                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),

                          validator: FormValidation.emailTextField,
                        ),
                      ),
                      SizedBox(height: height * 0.025),


                      /// PASSWORD FIELD
              SizedBox(
                height: height * .065,
                child: TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  textInputAction: TextInputAction.done,

                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: ColorConstants.primaryColor,
                      fontSize: 14,
                    ),

                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: ColorConstants.primaryColor,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black87,
                      ),
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                    ),

                    floatingLabelBehavior: FloatingLabelBehavior.auto,

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                        width: 2,
                      ),
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                  ),

                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: height * 0.035),

                      /// LOGIN BUTTON
                      GestureDetector(
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
                          width: double.infinity,
                          height: height * 0.06,
                          decoration: BoxDecoration(
                            color: Color(0xFF151515),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: loginState
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              'login',
                              style: GoogleFonts.dmSans(
                                fontSize: width * 0.043,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// FOOTER
                Padding(
                  padding:  EdgeInsets.only(top: height*.12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account yet?",
                        style: GoogleFonts.dmSans(
                          color:Color(0xFFe5e9eb) ,
                            fontWeight: FontWeight.w500,
                            fontSize: width*.04),
                      ),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  ContactUs()),
                          );
                        },
                        child: Text(
                          "Contact Us",
                          style: GoogleFonts.dmSans(
                            fontSize: width*.04,
                            color: Color(0xFF151515),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
