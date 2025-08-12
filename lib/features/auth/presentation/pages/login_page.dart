import 'dart:async';
import 'dart:developer';

import 'package:bookedin_app/core/DI/injection_container.dart';
import 'package:bookedin_app/features/admin/presentation/pages/admin_portal.dart';
import 'package:bookedin_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bookedin_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:bookedin_app/features/auth/presentation/widgets/CustomTextFormField.dart';
import 'package:bookedin_app/features/staff_user/presentation/pages/staff_portal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login_page';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showErrorMsg = false;
  int errorCount = 0;
  bool isBlocked = false;
  DateTime? blockUntil;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkBlockStatus();
  }

  void _checkBlockStatus() {
    if (blockUntil != null && DateTime.now().isBefore(blockUntil!)) {
      setState(() {
        isBlocked = true;
      });
      _startBlockTimer();
    }
  }

  void _startBlockTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (blockUntil == null || DateTime.now().isAfter(blockUntil!)) {
        timer.cancel();
        setState(() {
          isBlocked = false;
          errorCount = 0;
          showErrorMsg = false;
          blockUntil = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  String _remainingTime() {
    if (blockUntil == null) return '';
    final remaining = blockUntil!.difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return "$minutes minute(s) ${seconds.toString().padLeft(2, '0')} second(s)";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFF2560e8),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (state.user.role.toLowerCase() == "admin" ) {
                Navigator.pushReplacementNamed(context, AdminPortal.route);
              } else {
                Navigator.pushReplacementNamed(context, StaffPortal.route);
              }
            } else if (state is AuthError) {
              setState(() {
                showErrorMsg = true;
                errorCount++;
                if (errorCount >= 5) {
                  isBlocked = true;
                  blockUntil = DateTime.now().add(const Duration(minutes: 20));
                  _checkBlockStatus();
                }
              });
              log('Login failed $errorCount times');
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    isBlocked ? "Account Blocked" : "Welcome Back",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  isBlocked
                      ? "Too many failed attempts"
                      : "Sign in to book meeting rooms",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),

                if (showErrorMsg && !isBlocked)
                  _buildErrorMsg("❌ Wrong username or password"),

                if (isBlocked) _buildBlockTimeMsg(),

                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: emailController,
                  fieldType: "Email",
                  enabled: !isBlocked && state is! AuthLoading,
                ),
                CustomTextFormField(
                  controller: passwordController,
                  fieldType: "Password",
                  enabled: !isBlocked && state is! AuthLoading,
                ),

                const SizedBox(height: 25),
                _buildElevatedButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildErrorMsg(String msg) {
    return Container(
      width: 345,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFdb4653),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 20),
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
          color: const Color(0xFF4f7dea),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
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

  ElevatedButton _buildElevatedButton(BuildContext context, AuthState state) {
    return ElevatedButton(
      onPressed: (isBlocked || state is AuthLoading)
          ? null
          : () {
              if (emailController.text.trim().isEmpty ||
                  passwordController.text.trim().isEmpty) {
                setState(() {
                  showErrorMsg = true;
                });
              } else {
                context.read<AuthCubit>().login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(350, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: state is AuthLoading
          ? const CircularProgressIndicator(color: Color(0xFF2563eb))
          : const Text(
              "Sign in",
              style: TextStyle(
                color: Color(0xFF2563eb),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildBlockTimeMsg() {
    return Container(
      width: 320,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFdb4553),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Account temporarily blocked",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Try again in ${_remainingTime()}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
