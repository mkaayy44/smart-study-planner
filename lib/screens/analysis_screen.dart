import 'package:flutter/material.dart' show Widget, BuildContext, Center, Column, StatelessWidget, MainAxisSize, Icons, Icon, SizedBox, Text, Scaffold;
import 'package:studyplanner/app%20design/app_card.dart';
import 'package:studyplanner/app%20design/app_colors.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 40, color: AppColors.primary),
              SizedBox(height: 10),
              Text("No data yet", style: AppStyles.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}