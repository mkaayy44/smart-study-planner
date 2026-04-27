import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_card.dart' show AppCard;
import 'package:studyplanner/app%20design/app_colors.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),

            Text("Today", style: AppStyles.title),
            Text("You’re doing great", style: AppStyles.subtitle),

            SizedBox(height: 25),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Focus Time", style: AppStyles.subtitle),
                  SizedBox(height: 10),
                  Text("2h 30m",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            SizedBox(height: 20),

            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat("Tasks", "5"),
                  _miniStat("Done", "3"),
                  _miniStat("Streak", "7d"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(title, style: AppStyles.subtitle),
      ],
    );
  }
}