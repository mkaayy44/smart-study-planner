import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_colors.dart';
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

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),

            /// 🔹 Skip button (top right)
            SkipButton(),

            Spacer(),

            Text("Create account", style: AppStyles.title),
            SizedBox(height: 8),
            Text("Start your focused journey", style: AppStyles.subtitle),

            SizedBox(height: 40),

            _input("Name", name),
            SizedBox(height: 16),
            _input("Email", email),
            SizedBox(height: 16),
            _input("Password", password, isPassword: true),

            SizedBox(height: 30),

            GestureDetector(
              onTap: () async {
                setState(() => loading = true);

                try {
                  // 1. Create auth user
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: email.text,
                        password: password.text,
                      );

                  // 2. Save user in Firestore
                  await FirestoreService().createUser(
                    name: name.text,
                    email: email.text,
                    phone: "N/A",
                  );

                  // 3. Navigate
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MainNavigation()),
                  );
                } catch (e) {
                  print(e);
                }

                setState(() => loading = false);
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
                          "Sign Up",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ),

            SizedBox(height: 15),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Already have an account? Login"),
            ),
          ],
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
