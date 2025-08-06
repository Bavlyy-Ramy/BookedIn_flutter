import 'dart:developer';

import 'package:bookedin_app/features/auth/presentation/widgets/CustomTextFormField.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  bool showErrorMsg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2560e8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogo(),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Welcome Back",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            "Sign in to book meeting rooms",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 30),

          if (showErrorMsg) _buildErrorMsg(),

          SizedBox(height: 20),
          CustomTextFormField(controller: emailController, fieldType: "Email"),
          CustomTextFormField(
            controller: passwordController,
            fieldType: "Password",
          ),

          SizedBox(height: 25),
          _buildElevatedButton(),
        ],
      ),
    );
  }

  Container _buildErrorMsg() {
    return Container(
      width: 345,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFFdb4653),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          "❌ Wrong username or password",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Center _buildLogo() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Color(0xFF4f7dea),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "MR",
          style: TextStyle(
            color: Colors.white,
            fontSize: 50,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildElevatedButton() {
    return ElevatedButton(
      onPressed: () {
        if (emailController.text.trim().isEmpty ||
            passwordController.text.trim().isEmpty) {
          setState(() {
            showErrorMsg = true;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(350, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text(
        "Sign in",
        style: TextStyle(
          color: Color(0xFF2563eb),
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
