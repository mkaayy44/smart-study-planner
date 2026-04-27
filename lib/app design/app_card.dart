import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }
}