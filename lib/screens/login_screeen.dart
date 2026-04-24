import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/password_textfeild.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class LoginScreeen extends StatefulWidget {
  const LoginScreeen({super.key});

  @override
  State<LoginScreeen> createState() => _LoginScreeenState();
}

class _LoginScreeenState extends State<LoginScreeen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == 'success') {
      // FIX: Refresh the user data BEFORE navigating
      if (mounted) {
        await Provider.of<UserProvider>(context, listen: false).refreshUser();

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        showSnackBar(res, context);
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToSignUP() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3,
                )
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 2, child: Container()),

              //svg image
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                height: 64,
              ),
              const SizedBox(height: 64),

              //textfield input for email
              TextFieldInput(
                textEditingController: _emailController,
                hintText: 'phone number,username, or email',
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              //textfield input for password
              PasswordField(
                textEditingController: _passwordController,
                hintText: 'password',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 24),

              //login button
              InkWell(
                onTap: loginUser,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    color: blueColorButton,
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const Text('Log in'),
                ),
              ),
              const SizedBox(height: 12),

              //Transitioning to signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text("Don't have an account?"),
                  ),
                  GestureDetector(
                    onTap: navigateToSignUP,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        " Sign up.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(flex: 2, child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
