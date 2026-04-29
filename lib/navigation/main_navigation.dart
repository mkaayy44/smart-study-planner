import 'package:flutter/material.dart';
import 'package:studyplanner/app%20design/app_colors.dart';
import 'package:studyplanner/screens/analysis_screen.dart';
import 'package:studyplanner/screens/focus_screen.dart';
import 'package:studyplanner/screens/home_screen.dart';
import 'package:studyplanner/screens/profile_screen.dart';
import 'package:studyplanner/screens/tasks_screen.dart';

class MainNavigation extends StatefulWidget {
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final screens = [
    HomeScreen(),
    TasksScreen(),
    AnalysisScreen(),
    FocusScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent, // Make scaffold background transparent
      body: Stack(
        children: [
          // Main content
          screens[index],
          
          // Floating bottom navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  IconData icon = [
                    Icons.home,
                    Icons.check,
                    Icons.bar_chart,
                    Icons.timer,
                    Icons.person
                  ][i];

                  return GestureDetector(
                    onTap: () => setState(() => index = i),
                    child: Icon(
                      icon,
                      color: index == i
                          ? AppColors.primary
                          : AppColors.textSoft,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}