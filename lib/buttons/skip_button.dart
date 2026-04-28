import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_colors.dart' show AppColors;
import 'package:studyplanner/navigation/main_navigation.dart' show MainNavigation;

class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainNavigation()),
          );
        },
        child: Text(
          "Skip",
          style: TextStyle(color: AppColors.textSoft),
        ),
      ),
    );
  }
}