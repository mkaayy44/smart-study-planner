import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_colors.dart';
import 'package:studyplanner/navigation/main_navigation.dart';
import 'package:studyplanner/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Skip button (top right)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainNavigation()),
                    );
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(color: AppColors.textSoft),
                  ),
                ),
              ),

              Spacer(),

              /// 🔹 Title
              Text("Welcome back", style: AppStyles.title),
              SizedBox(height: 8),
              Text("Stay focused, stay calm", style: AppStyles.subtitle),

              SizedBox(height: 40),

              /// 🔹 Inputs
              _input("Email", email),
              SizedBox(height: 16),
              _input("Password", password, isPassword: true),

              SizedBox(height: 30),

              /// 🔹 Login Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainNavigation()),
                  );
                },
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// 🔹 Signup redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don’t have an account? ", style: AppStyles.subtitle),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignupScreen()),
                      );
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    TextEditingController c, {
    bool isPassword = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: c,
        obscureText: isPassword,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }
}
