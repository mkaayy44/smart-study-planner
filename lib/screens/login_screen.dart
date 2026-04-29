import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyplanner/navigation/main_navigation.dart';

class LoginScreen extends StatefulWidget {
@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final email = TextEditingController();
final password = TextEditingController();

bool loading = false;

Future<void> login() async {
setState(() => loading = true);


try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email.text.trim(),
    password: password.text.trim(),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => MainNavigation()),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Login failed")),
  );
}

setState(() => loading = false);


}

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: SingleChildScrollView(
child: Padding(
padding: EdgeInsets.all(24),
child: Column(
children: [
SizedBox(height: 40),
Text("Login"),


            SizedBox(height: 40),

            TextField(controller: email, decoration: InputDecoration(hintText: "Email")),
            SizedBox(height: 16),
            TextField(controller: password, decoration: InputDecoration(hintText: "Password")),

            SizedBox(height: 30),

            GestureDetector(
              onTap: loading ? null : login,
              child: Container(
                height: 55,
                color: Colors.blue,
                child: Center(
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login"),
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
}
