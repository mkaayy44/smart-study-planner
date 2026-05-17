import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  bool loading = true;

  int completedTasks = 0;
  int pendingTasks = 0;
  int totalSessions = 0;
  int totalFocusSeconds = 0;
  int streak = 0;
  int productivity = 0;

  List<Map<String, dynamic>> todayTasks = [];

  List<double> weeklyData = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
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

      int focusSeconds = 0;

      completedTasks = tasksSnapshot.docs.where((e) {
        return e['isCompleted'] == true;
      }).length;

      pendingTasks = tasksSnapshot.docs.where((e) {
        return e['isCompleted'] == false;
      }).length;

      totalSessions = sessionsSnapshot.docs.length;

      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data();

        final int duration =
            ((data['durationSeconds'] ?? data['duration'] ?? 0) as num)
                .toInt();

        focusSeconds += duration;

        final timestamp = data['endedAt'] ?? data['date'];

        if (timestamp != null) {
          final date = (timestamp as Timestamp).toDate();

          final weekday = date.weekday - 1;

          weeklyData[weekday] += duration / 3600;
        }
      }

      totalFocusSeconds = focusSeconds;

      productivity =
          ((completedTasks * 5) + (totalSessions * 2)).clamp(0, 100);

      streak = calculateRealStreak(
        tasksSnapshot.docs,
        sessionsSnapshot.docs,
      );

      todayTasks = tasksSnapshot.docs
          .where((e) => e['isCompleted'] == false)
          .take(3)
          .map((e) {
            return {
              'title': e['title'] ?? 'Untitled',
              'subject': e['subject'] ?? '',
            };
          })
          .toList();

      setState(() {
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  int calculateRealStreak(
    List<QueryDocumentSnapshot> tasks,
    List<QueryDocumentSnapshot> sessions,
  ) {
    final Set<String> activeDays = {};

    for (var doc in tasks) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['isCompleted'] == true && data['completedAt'] != null) {
        final date = (data['completedAt'] as Timestamp).toDate();

        activeDays.add(
          "${date.year}-${date.month}-${date.day}",
        );
      }
    }

    for (var doc in sessions) {
      final data = doc.data() as Map<String, dynamic>;

      final timestamp = data['endedAt'] ?? data['date'];

      if (timestamp != null) {
        final date = (timestamp as Timestamp).toDate();

        activeDays.add(
          "${date.year}-${date.month}-${date.day}",
        );
      }
    }

    int streakCount = 0;

    DateTime current = DateTime.now();

    while (true) {
      final key =
          "${current.year}-${current.month}-${current.day}";

      if (activeDays.contains(key)) {
        streakCount++;

        current = current.subtract(
          const Duration(days: 1),
        );
      } else {
        break;
      }
    }

    return streakCount;
  }

  String get greeting {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";

    return "Good Evening";
  }

  String formatFocusTime() {
    final hours = totalFocusSeconds ~/ 3600;
    final minutes = (totalFocusSeconds % 3600) ~/ 60;
    final seconds = totalFocusSeconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }

    if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    }

    return "${seconds}s";
  }

  String get streakText {
    if (streak == 0) {
      return "0 Day Streak";
    }

    if (streak == 1) {
      return "1 Day Streak";
    }

    return "$streak Day Streak";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  120,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    /// GREETING
                    Text(
                      "$greeting 👋",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Stay consistent and keep learning.",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// HERO CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),

                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),

                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  streakText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Today's Focus",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: Text(
                              formatFocusTime(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),

                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: productivity / 100,
                              backgroundColor: Colors.white24,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "$productivity% Productivity",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// WEEKLY STUDY
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Weekly Study",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Hours",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      height: 280,
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                          ),
                        ],
                      ),

                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),

                          gridData: FlGridData(show: false),

                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),

                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),

                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 42,
                                showTitles: true,

                                getTitlesWidget:
                                    (value, meta) {
                                  final days = [
                                    "M",
                                    "T",
                                    "W",
                                    "T",
                                    "F",
                                    "S",
                                    "S",
                                  ];

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 12,
                                    ),

                                    child: Text(
                                      days[value.toInt()],
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          barGroups: List.generate(
                            7,
                            (index) {
                              return BarChartGroupData(
                                x: index,

                                barRods: [
                                  BarChartRodData(
                                    toY: weeklyData[index],
                                    width: 18,
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                    color:
                                        AppColors.primary,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// STATS
                    GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,

                      children: [
                        buildStatCard(
                          "Completed",
                          "$completedTasks",
                          Icons.task_alt,
                          Colors.green,
                        ),

                        buildStatCard(
                          "Pending",
                          "$pendingTasks",
                          Icons.pending_actions,
                          Colors.orange,
                        ),

                        buildStatCard(
                          "Sessions",
                          "$totalSessions",
                          Icons.timer,
                          Colors.blue,
                        ),

                        buildStatCard(
                          "Score",
                          "$productivity%",
                          Icons.auto_graph,
                          Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// TASKS
                    const Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ...todayTasks.map((task) {
                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 14),

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                            ),
                          ],
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,

                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    task['title'],
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    task['subject'],
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // const SizedBox(width: 10),

                            // const Icon(
                            //   Icons.arrow_forward_ios,
                            //   size: 16,
                            // ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 32),

                    /// INSIGHT CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              Icons.psychology,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Smart Insight",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  productivity >= 70
                                      ? "Excellent momentum this week."
                                      : "Small daily study sessions can greatly improve your consistency and focus.",
                                  style: TextStyle(
                                    height: 1.5,
                                    color:
                                        Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const Spacer(),

          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,

              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}