import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/services/firestore_service.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? ticker;

  final int focusDuration = 25 * 60;
  final int breakDuration = 5 * 60;

  int remainingSeconds = 25 * 60;

  bool isRunning = false;
  bool isBreak = false;

  DateTime? sessionStartTime;

  String? currentSessionId;

  bool sessionStarted = false;

  DateTime? sessionStartedAt;

  @override
  void dispose() {
    ticker?.cancel();

    finishSession();

    super.dispose();
  }

  void startTimer() async {
    if (isRunning) return;

    // Create ONLY ONE session
    if (!sessionStarted) {
      sessionStarted = true;
      sessionStartedAt = DateTime.now();

      currentSessionId = await FirestoreService().startFocusSession(
        isBreak: isBreak,
      );
    }

    setState(() {
      isRunning = true;
    });

    ticker?.cancel();

    ticker = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        switchMode();
      }
    });
  }

  void pauseTimer() {
    ticker?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    ticker?.cancel();

    setState(() {
      isRunning = false;
      isBreak = false;
      remainingSeconds = focusDuration;
    });
  }

  Future<void> finishSession() async {
    if (currentSessionId == null || sessionStartedAt == null) return;

    final durationInSeconds = DateTime.now()
        .difference(sessionStartedAt!)
        .inSeconds;

    // Ignore tiny sessions
    if (durationInSeconds < 5) return;

    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;

    final formattedDuration = "${minutes}m ${seconds}s";

    await FirestoreService().endFocusSession(
      sessionId: currentSessionId!,
      durationSeconds: durationInSeconds,
      formattedDuration: formattedDuration,
    );
  }

  void switchMode() {
    ticker?.cancel();

    setState(() {
      isBreak = !isBreak;
      isRunning = false;
      remainingSeconds = isBreak ? breakDuration : focusDuration;
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');

    final secs = (seconds % 60).toString().padLeft(2, '0');

    return "$minutes:$secs";
  }

  double get progress {
    final total = isBreak ? breakDuration : focusDuration;

    return remainingSeconds / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              SizedBox(height: 20),

              Text(
                isBreak ? "Break Time" : "Pomodoro Focus",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 10),

              Text(
                isBreak
                    ? "Relax your mind for a few minutes"
                    : "Stay focused on your task",
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),

              Spacer(),

              Container(
                width: 290,
                height: 290,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    SizedBox(
                      width: 290,
                      height: 290,

                      child: CustomPaint(
                        painter: PomodoroPainter(
                          progress: progress,
                          color: isBreak ? Colors.green : AppColors.primary,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatTime(remainingSeconds),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 10),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (isBreak ? Colors.green : AppColors.primary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            isBreak ? "BREAK" : "FOCUS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBreak ? Colors.green : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton(
                    icon: isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    onTap: isRunning ? pauseTimer : startTimer,
                    isPrimary: true,
                  ),

                  SizedBox(width: 20),

                  buildButton(icon: Icons.refresh_rounded, onTap: resetTimer),
                ],
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),

        width: isPrimary ? 80 : 65,
        height: isPrimary ? 80 : 65,

        decoration: BoxDecoration(
          color: isPrimary
              ? (isBreak ? Colors.green : AppColors.primary)
              : Colors.white,

          shape: BoxShape.circle,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),

        child: Icon(
          icon,
          color: isPrimary ? Colors.white : Colors.black87,
          size: 34,
        ),
      ),
    );
  }
}

class PomodoroPainter extends CustomPainter {
  final double progress;
  final Color color;

  PomodoroPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    final radius = min(size.width / 2, size.height / 2) - strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      -sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
