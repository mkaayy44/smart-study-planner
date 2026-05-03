import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studyplanner/app design/app_card.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: Colors.grey),

                SizedBox(height: 20),

                Text("You're not logged in", style: AppStyles.title),

                SizedBox(height: 12),

                Text(
                  "Login or create an account to access your profile",
                  style: AppStyles.subtitle,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30),

                Text(
                  "Start tracking your study sessions and stay productive 📚",
                  style: AppStyles.subtitle,
                  textAlign: TextAlign.center,
                ),

                /// 🔹 Login Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("Login"),
                ),

                SizedBox(height: 10),

                /// 🔹 Signup Button
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup'); // or direct route
                  },
                  child: Text(
                    "Create account",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            final name = data['name'] ?? "No Name";
            final email = user!.email ?? "No Email";
            final phoneNumber = data['phoneNumber'] ?? "";

            return Column(
              children: [
                SizedBox(height: 40),

                CircleAvatar(radius: 40),
                SizedBox(height: 10),

                Text(name, style: AppStyles.title),
                Text(email, style: AppStyles.subtitle),
                Text(phoneNumber, style: AppStyles.subtitle),

                SizedBox(height: 30),

                AppCard(
                  child: ListTile(
                    title: Text("Logout"),
                    trailing: Icon(Icons.logout),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
