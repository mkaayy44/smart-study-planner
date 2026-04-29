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
        body: Center(child: Text("No user logged in")),
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

            final data = snapshot.data!.data() as Map<String, dynamic>;

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
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}