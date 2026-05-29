import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:studyplanner/app design/app_colors.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  int completedTasks = 0;
  int totalTasks = 0;

  int totalSessions = 0;
  int totalFocusSeconds = 0;

  int streak = 0;
  bool loading = true;

  List<double> weeklyData = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  // ✅ ADD THIS METHOD - Copy from HomeScreen
  int calculateRealStreak(
    List<QueryDocumentSnapshot> tasks,
    List<QueryDocumentSnapshot> sessions,
  ) {
    final Set<String> activeDays = {};

    // Check completed tasks
    for (var doc in tasks) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['isCompleted'] == true && data['completedAt'] != null) {
        final date = (data['completedAt'] as Timestamp).toDate();
        activeDays.add("${date.year}-${date.month}-${date.day}");
      }
    }

    // Check study sessions
    for (var doc in sessions) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['endedAt'] ?? data['date'];

      if (timestamp != null) {
        final date = (timestamp as Timestamp).toDate();
        activeDays.add("${date.year}-${date.month}-${date.day}");
      }
    }

    // Calculate consecutive days from today
    int streakCount = 0;
    DateTime current = DateTime.now();

    while (true) {
      final key = "${current.year}-${current.month}-${current.day}";

      if (activeDays.contains(key)) {
        streakCount++;
        current = current.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streakCount;
  }

  Future<void> loadAnalytics() async {
    if (uid == null) return;

    try {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();

      final sessionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .get();

      totalTasks = tasksSnapshot.docs.length;

      completedTasks =
          tasksSnapshot.docs.where((d) => d['isCompleted'] == true).length;

      totalSessions = sessionsSnapshot.docs.length;

      int seconds = 0;

      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final int durationSeconds = (data['durationSeconds'] ?? 0);

        seconds += durationSeconds;

        final date = (data['date'] as Timestamp?)?.toDate();

        if (date != null) {
          final weekday = date.weekday - 1;
          if (weekday >= 0 && weekday < 7) {
            weeklyData[weekday] += durationSeconds / 60;
          }
        }
      }

      totalFocusSeconds = seconds;

      // ✅ ADD THIS - Calculate streak
      streak = calculateRealStreak(tasksSnapshot.docs, sessionsSnapshot.docs);

      setState(() => loading = false);
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  // FORMAT: 1h 02m 05s
  String formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;

    if (h > 0) {
      return "${h}h ${m}m ${s}s";
    } else if (m > 0) {
      return "${m}m ${s}s";
    } else {
      return "${s}s";
    }
  }

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  int get productivityScore {
    final score =
        (completedTasks * 3) +
        (totalSessions * 2) +
        ((totalFocusSeconds ~/ 3600) * 5);

    return score > 100 ? 100 : score;
  }

  String get smartInsight {
    if (productivityScore >= 80) {
      return "Excellent consistency this week.";
    } else if (productivityScore >= 50) {
      return "Good progress. Keep going.";
    }
    return "Small focus sessions can improve productivity.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Productivity Analysis",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      smartInsight,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// STREAK CARD (NOW SHOWS CORRECT STREAK)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Colors.white, size: 40),
                          const SizedBox(width: 16),
                          Text(
                            streak == 0
                                ? "0 Day Streak"
                                : streak == 1
                                    ? "1 Day Streak"
                                    : "$streak Day Streak",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// STATS GRID
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                      children: [
                        buildStat("Completed", "$completedTasks"),
                        buildStat("Sessions", "$totalSessions"),
                        buildStat(
                          "Study Time",
                          formatTime(totalFocusSeconds),
                        ),
                        buildStat("Score", "$productivityScore%"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// CIRCLE
                    Center(
                      child: CircularPercentIndicator(
                        radius: 80,
                        lineWidth: 14,
                        percent: completionRate.clamp(0, 1),
                        progressColor: AppColors.primary,
                        backgroundColor: Colors.grey.shade200,
                        center: Text(
                          "${(completionRate * 100).toInt()}%",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}