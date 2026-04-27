import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_colors.dart';

import '../app design/app_card.dart';

class FocusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Focus Session", style: AppStyles.subtitle),
              SizedBox(height: 10),
              Text("25:00",
                  style:
                      TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: Text("Start")),
            ],
          ),
        ),
      ),
    );
  }
}