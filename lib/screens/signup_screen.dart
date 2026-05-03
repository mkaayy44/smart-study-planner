import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/buttons/skip_button.dart';
import 'package:studyplanner/navigation/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyplanner/services/firestore_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();

  bool loading = false;

  Future<void> signup() async {
    if (email.text.isEmpty ||
        password.text.isEmpty ||
        name.text.isEmpty ||
        phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception();

      await FirestoreService().createUser(
        name: name.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Signup failed"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => loading = false);
  }

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
              SkipButton(),

              Spacer(),

              /// 🔹 Title
              Text("Create account", style: AppStyles.title),
              SizedBox(height: 8),
              Text("Start your focused journey",
                  style: AppStyles.subtitle),

              SizedBox(height: 40),

              _input("Name", name),
              SizedBox(height: 16),
              _input("Phone Number", phone),
              SizedBox(height: 16),
              _input("Email", email),
              SizedBox(height: 16),
              _input("Password", password, isPassword: true),

              SizedBox(height: 30),

              /// 🔹 Button
              GestureDetector(
                onTap: loading ? null : signup,
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
                            "Sign Up",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              /// 🔹 Login redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: AppStyles.subtitle),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Login",
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
        keyboardType:
            hint == "Phone Number" ? TextInputType.phone : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}