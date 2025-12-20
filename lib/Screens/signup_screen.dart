import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/round_rect_button.dart';
import '../Theme/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  bool obscureText = true;
  final _auth = FirebaseAuth.instance;

  Future<void> registerUser() async {
    try {
      UserCredential registered = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await registered.user?.sendEmailVerification();

      print("WHAT IS THIS: $registered");
      registered.user!.updateDisplayName("RODRIGO");
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AuthTextField(title: "Username", controller: usernameController, hintText: "John Doe",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },

              ),
              AuthTextField(title: "Email", controller: emailController, hintText: "JohnDoe@email.com",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              AuthTextField(title: "Password", controller: passwordController, hintText: "********",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  } else if (value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
                suffixCallback: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                obscureText: obscureText,
                showEye: true,
              ),

              RoundRectButton(buttonText: "Sign Up",
                onPressed: () async {
                  final bool isValid = formKey.currentState?.validate() ?? false;
                  if (!isValid) {
                    return;
                  }
                  await registerUser();
                  //signup function

                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
