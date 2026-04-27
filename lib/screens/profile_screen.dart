import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_card.dart';
import 'package:studyplanner/app%20design/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40),

            CircleAvatar(radius: 40),
            SizedBox(height: 10),

            Text("Your Name", style: AppStyles.title),
            Text("your@email.com", style: AppStyles.subtitle),

            SizedBox(height: 30),

            AppCard(
              child: ListTile(
                title: Text("Logout"),
                trailing: Icon(Icons.logout),
              ),
            )
          ],
        ),
      ),
    );
  }
}