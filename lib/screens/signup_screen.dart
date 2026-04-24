import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/login_screeen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/password_textfeild.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  void navigateToLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => LoginScreeen()));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image!,
    );
    setState(() {
      _isLoading = false;
    });

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text('Account Created Successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  navigateToLogin();
                },
                child: const Text(
                  'Login now',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
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

              //Circular widget to accept and show our selected file
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                            'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-2650281813.jpg',
                          ),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: () async {
                        // select image
                        Uint8List? im = await pickImage(ImageSource.gallery);
                        setState(() {
                          _image = im;
                        });
                      },
                      icon: const Icon(
                        Icons.add_circle_outlined,
                        color: blueColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              //textfieldinput for username
              TextFieldInput(
                textEditingController: _usernameController,
                hintText: 'Enter a username',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              //textfield input for email
              TextFieldInput(
                textEditingController: _emailController,
                hintText: 'phone number or email',
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              //textfield input for password
              PasswordField(
                textEditingController: _passwordController,
                hintText: 'password',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 12),

              //textfieldinput for bio
              TextFieldInput(
                textEditingController: _bioController,
                hintText: 'Enter your bio',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 24),

              //Sign up button
              InkWell(
                onTap: signUpUser,
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
                      : const Text('Sign up'),
                ),
              ),

              //transitioning to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text("Already have an account?"),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        " Log in.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: blueColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Flexible(flex: 2, child: Container()),
            ],
          ),
        ),
      ),
    );
  }
}
