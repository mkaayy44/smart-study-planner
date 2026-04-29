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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [SkipButton()],
                ),
                SizedBox(height: 40),

                Text("Create account"),
                SizedBox(height: 40),

                _input("Name", name),
                SizedBox(height: 16),
                _input("Phone Number", phone),
                SizedBox(height: 16),
                _input("Email", email),
                SizedBox(height: 16),
                _input("Password", password, isPassword: true),

                SizedBox(height: 30),

                GestureDetector(
                  onTap: () async {
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
                  },
                  child: Container(
                    height: 55,
                    color: Colors.blue,
                    child: Center(
                      child: loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Sign Up"),
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

  Widget _input(
    String hint,
    TextEditingController c, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: c,
      obscureText: isPassword,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
