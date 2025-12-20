import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hintText;
  String? Function(String?)? validator;
  bool obscureText;
  bool showEye;
  VoidCallback? suffixCallback;
  AuthTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.hintText,
    this.validator,
    this.suffixCallback,
    this.obscureText = false,
    this.showEye = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 15.0, bottom: 7.0),
              child: Text(title),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextFormField(
            obscureText: obscureText,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: showEye
                  ? IconButton(
                      onPressed: suffixCallback,
                      icon: Icon(obscureText? Icons.visibility : Icons.visibility_off, color: Colors.black,),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFFE6DFDF),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
