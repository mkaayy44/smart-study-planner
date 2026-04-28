import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/app%20design/app_card.dart';

class FocusScreen extends StatefulWidget {
  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? ticker;

  DateTime? startTime;

  int sessionDuration = 25 * 60; // default 25 min
  bool isRunning = false;
  bool isBreak = false;

  /// ▶️ Start / Resume
  void startTimer() {
    if (isRunning) return;

    startTime = DateTime.now();

    setState(() => isRunning = true);

    ticker?.cancel();
    ticker = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  /// ⏸ Pause
  void pauseTimer() {
    if (startTime == null) return;

    final elapsed = DateTime.now().difference(startTime!).inSeconds;

    sessionDuration -= elapsed;

    startTime = null;
    ticker?.cancel();

    setState(() => isRunning = false);
  }

  /// 🔁 Reset
  void resetTimer() {
    ticker?.cancel();

    setState(() {
      isRunning = false;
      isBreak = false;
      sessionDuration = 25 * 60;
      startTime = null;
    });
  }

  /// 🔄 Switch Focus <-> Break
  void switchSession() {
    startTime = DateTime.now();

    setState(() {
      isBreak = !isBreak;
      sessionDuration = isBreak ? 5 * 60 : 25 * 60;
    });
  }

  /// 🧠 REAL TIME CALCULATION
  int get secondsLeft {
    if (startTime == null) return sessionDuration;

    final elapsed = DateTime.now().difference(startTime!).inSeconds;
    final remaining = sessionDuration - elapsed;

    if (remaining <= 0) {
      switchSession();
      return 0;
    }

    return remaining;
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = secondsLeft;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🔹 Title
              Text(
                isBreak ? "Break Time" : "Focus Session",
                style: AppStyles.subtitle,
              ),

              SizedBox(height: 10),

              /// 🔹 Timer
              Text(
                formatTime(time),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: isBreak
                      ? Colors.green
                      : AppColors.primary,
                ),
              ),

              SizedBox(height: 25),

              /// 🔘 Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// ▶️ Start / Resume
                  _circleButton(
                    icon: Icons.play_arrow,
                    onTap: startTimer,
                  ),

                  SizedBox(width: 15),

                  /// ⏸ Pause
                  _circleButton(
                    icon: Icons.pause,
                    onTap: pauseTimer,
                  ),

                  SizedBox(width: 15),

                  /// 🔁 Reset
                  _circleButton(
                    icon: Icons.refresh,
                    onTap: resetTimer,
                  ),
                ],
              ),

              SizedBox(height: 15),

              /// 🔹 Subtitle
              Text(
                isBreak
                    ? "Relax. Let your brain breathe."
                    : "Deep focus. No distractions.",
                style: AppStyles.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}