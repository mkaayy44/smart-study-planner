import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  int completedTasks = 0;
  int totalSessions = 0;
  int totalFocusSeconds = 0;
  int streak = 0;

  Future<Map<String, dynamic>> fetchUserData() async {
    if (user == null) return {};

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks')
        .get();

    final sessionsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('sessions')
        .get();

    completedTasks = tasksSnapshot.docs.where((e) {
      return e['isCompleted'] == true;
    }).length;

    totalSessions = sessionsSnapshot.docs.length;

    int seconds = 0;

    for (var doc in sessionsSnapshot.docs) {
      final data = doc.data();

      final int duration =
          (data['durationSeconds'] ?? data['duration'] ?? 0).toInt();

      seconds += duration;
    }

    totalFocusSeconds = seconds;

    streak = calculateStreak(
      tasksSnapshot.docs,
      sessionsSnapshot.docs,
    );

    return userDoc.data() ?? {};
  }

  int calculateStreak(
    List<QueryDocumentSnapshot> tasks,
    List<QueryDocumentSnapshot> sessions,
  ) {
    final Set<String> activeDays = {};

    for (var doc in tasks) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['isCompleted'] == true &&
          data['completedAt'] != null) {
        final date =
            (data['completedAt'] as Timestamp).toDate();

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

  String formatFocusTime() {
    final hours = totalFocusSeconds ~/ 3600;
    final minutes = (totalFocusSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }

    return "${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                      ),
                    ],
                  ),

                  child: Icon(
                    Icons.person_outline,
                    size: 70,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "You're not logged in",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Login to access your study profile and analytics.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 35),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          final name = data['name'] ?? "No Name";
          final email = user!.email ?? "No Email";
          final phone = data['phoneNumber'] ?? "No Phone";

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                120,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 15,
                            ),
                          ],
                        ),

                        child: Icon(
                          Icons.settings_rounded,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// PROFILE CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(30),

                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary
                              .withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary
                              .withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white30,
                              width: 3,
                            ),
                          ),

                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor:
                                Colors.white,

                            child: Text(
                              name[0]
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(
                              0.15,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),

                          child: Text(
                            "🔥 $streak Day Streak",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ACCOUNT INFO
                  const Text(
                    "Account Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  buildInfoTile(
                    Icons.person_outline_rounded,
                    "Full Name",
                    name,
                  ),

                  buildInfoTile(
                    Icons.email_outlined,
                    "Email Address",
                    email,
                  ),

                  buildInfoTile(
                    Icons.phone_outlined,
                    "Phone Number",
                    phone,
                  ),

                  const SizedBox(height: 32),

                  /// MOTIVATION CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(28),

                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(
                            0.04,
                          ),
                          blurRadius: 20,
                        ),
                      ],
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            Icons.psychology_rounded,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              const Text(
                                "Daily Motivation",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                streak >= 7
                                    ? "Amazing consistency. You're building strong study habits."
                                    : "Small daily progress creates big long-term results.",
                                style: TextStyle(
                                  color:
                                      Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance
                            .signOut();

                        if (!context.mounted) return;

                        Navigator.of(context)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) =>
                                LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },

                      icon: const Icon(Icons.logout),

                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 18,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.all(20),

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
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, color: color),
          ),

          const Spacer(),

          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color:
                  AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}