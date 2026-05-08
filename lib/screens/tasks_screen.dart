import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_card.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyplanner/services/notification_service.dart';
import 'package:studyplanner/services/pdf_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final firestore = FirestoreService();
  User? currentUser;
  String selectedSort = 'deadline';
  String selectedPriorityFilter = 'all';
  String selectedDifficultyFilter = 'all';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Beirut'));
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Filters & Sorting",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  // SEARCH
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search task name...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),

                  SizedBox(height: 16),

                  // SORT
                  DropdownButtonFormField<String>(
                    value: selectedSort,
                    decoration: InputDecoration(
                      labelText: "Sort By",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'deadline',
                        child: Text("Deadline"),
                      ),
                      DropdownMenuItem(
                        value: 'priority',
                        child: Text("Priority"),
                      ),
                      DropdownMenuItem(
                        value: 'difficulty',
                        child: Text("Difficulty"),
                      ),
                      DropdownMenuItem(
                        value: 'urgency',
                        child: Text("Urgency Score"),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedSort = value!;
                      });

                      setState(() {});
                    },
                  ),

                  SizedBox(height: 16),

                  // PRIORITY FILTER
                  DropdownButtonFormField<String>(
                    value: selectedPriorityFilter,
                    decoration: InputDecoration(
                      labelText: "Priority Filter",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text("All")),
                      DropdownMenuItem(value: 'high', child: Text("High")),
                      DropdownMenuItem(value: 'medium', child: Text("Medium")),
                      DropdownMenuItem(value: 'low', child: Text("Low")),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedPriorityFilter = value!;
                      });

                      setState(() {});
                    },
                  ),

                  SizedBox(height: 16),

                  // DIFFICULTY FILTER
                  DropdownButtonFormField<String>(
                    value: selectedDifficultyFilter,
                    decoration: InputDecoration(
                      labelText: "Difficulty Filter",
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text("All")),
                      DropdownMenuItem(value: 'hard', child: Text("Hard")),
                      DropdownMenuItem(value: 'medium', child: Text("Medium")),
                      DropdownMenuItem(value: 'easy', child: Text("Easy")),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedDifficultyFilter = value!;
                      });

                      setState(() {});
                    },
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Apply"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String getCurrentTimeZone() {
    return tz.local.name;
  }

  void showAdd() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    String selectedPriority = 'medium';
    String selectedDifficulty = 'medium';
    DateTime? selectedDeadline;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add New Task",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Task Title",
                      hintText: "Enter task title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      hintText: "Enter subject name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(),
                    ),
                    items: ['low', 'medium', 'high'].map((String priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: priority == 'low'
                                    ? Colors.green
                                    : priority == 'medium'
                                    ? Colors.orange
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(priority.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedPriority = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: "Difficulty",
                      border: OutlineInputBorder(),
                    ),
                    items: ['easy', 'medium', 'hard'].map((String difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedDifficulty = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDeadline = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDeadline == null
                                ? "Select Deadline"
                                : "Deadline: ${selectedDeadline!.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(
                              color: selectedDeadline == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (picked != null) {
                        setModalState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTime == null
                                ? "Select Time"
                                : "Time: ${selectedTime!.format(context)}",
                            style: TextStyle(
                              color: selectedTime == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please enter a task title"),
                            ),
                          );
                        }
                        return;
                      }

                      try {
                        if (selectedDeadline == null || selectedTime == null) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please select date and time"),
                              ),
                            );
                          }
                          return;
                        }

                        final finalDeadline = DateTime(
                          selectedDeadline!.year,
                          selectedDeadline!.month,
                          selectedDeadline!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );

                        if (finalDeadline.isBefore(DateTime.now())) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Deadline must be in the future! Please select a valid date and time.",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        await firestore.addTask(
                          title: titleController.text.trim(),
                          subject: subjectController.text.trim(),
                          priority: selectedPriority,
                          difficulty: selectedDifficulty,
                          deadline: finalDeadline,
                        );

                        final notificationTime = finalDeadline.subtract(
                          Duration(minutes: 1),
                        );

                        if (notificationTime.isAfter(DateTime.now())) {
                          await NotificationService.scheduleNotification(
                            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            title: "Task Reminder",
                            body:
                                "Don't forget: ${titleController.text.trim()} is due soon!",
                            scheduledDate: notificationTime,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Task added! Reminder set for 1 minute before deadline.",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          await NotificationService.scheduleNotification(
                            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            title: "Task Deadline",
                            body:
                                "Don't forget: ${titleController.text.trim()} is due now!",
                            scheduledDate: finalDeadline,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Task added! Reminder set for deadline time.",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }

                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error adding task: $e")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Add Task"),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showEditDialog(String taskId, Map<String, dynamic> currentData) {
    final titleController = TextEditingController(
      text: currentData['title'] ?? '',
    );
    final subjectController = TextEditingController(
      text: currentData['subject'] ?? '',
    );
    String selectedPriority = currentData['priority'] ?? 'medium';
    String selectedDifficulty = currentData['difficulty'] ?? 'medium';

    DateTime? deadlineDateTime = (currentData['deadline'] as Timestamp?)
        ?.toDate();
    DateTime? selectedDeadline = deadlineDateTime;
    TimeOfDay? selectedTime = deadlineDateTime != null
        ? TimeOfDay(
            hour: deadlineDateTime.hour,
            minute: deadlineDateTime.minute,
          )
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Task",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Task Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: "Priority",
                      border: OutlineInputBorder(),
                    ),
                    items: ['low', 'medium', 'high'].map((String priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedPriority = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: "Difficulty",
                      border: OutlineInputBorder(),
                    ),
                    items: ['easy', 'medium', 'hard'].map((String difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedDifficulty = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDeadline = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDeadline == null
                                ? "Select Deadline"
                                : "Deadline: ${selectedDeadline!.toLocal().toString().split(' ')[0]}",
                            style: TextStyle(
                              color: selectedDeadline == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedTime == null
                                ? "Select Time"
                                : "Time: ${selectedTime!.format(context)}",
                            style: TextStyle(
                              color: selectedTime == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please enter a task title"),
                            ),
                          );
                        }
                        return;
                      }

                      try {
                        DateTime? finalDeadline;
                        if (selectedDeadline != null && selectedTime != null) {
                          finalDeadline = DateTime(
                            selectedDeadline!.year,
                            selectedDeadline!.month,
                            selectedDeadline!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          if (finalDeadline.isBefore(DateTime.now())) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Deadline must be in the future! Please select a valid date and time.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }
                        }

                        await firestore.updateTask(
                          taskId: taskId,
                          title: titleController.text.trim(),
                          subject: subjectController.text.trim(),
                          priority: selectedPriority,
                          difficulty: selectedDifficulty,
                          deadline: finalDeadline,
                        );

                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error updating task: $e")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Update Task"),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSmartFeatures() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: generateSmartSchedule,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      "Smart Schedule",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Generate your study plan",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> generateSchedule(
    List<QueryDocumentSnapshot> docs,
  ) {
    List<Map<String, dynamic>> tasks = docs
        .map((e) => e.data() as Map<String, dynamic>)
        .toList();

    tasks.sort((a, b) {
      final scoreA = calculateScore(a);
      final scoreB = calculateScore(b);
      return scoreB.compareTo(scoreA);
    });

    DateTime currentTime = DateTime.now();
    List<Map<String, dynamic>> schedule = [];

    int sessionCount = 0;

    for (var task in tasks) {
      // ⛔ Stop late-night studying
      if (currentTime.hour >= 22) {
        currentTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day + 1,
          9, // next day at 9 AM
        );
      }

      int duration = estimateDuration(task);

      // Reduce long sessions if user is tired
      if (sessionCount >= 3 && duration > 45) {
        duration = 30; // split heavy tasks
      }

      DateTime start = currentTime;
      DateTime end = currentTime.add(Duration(minutes: duration));

      schedule.add({
        'title': task['title'],
        'priority': task['priority'],
        'difficulty': task['difficulty'],
        'deadline': task['deadline'],
        'start': start,
        'end': end,
        'score': calculateScore(task), // 👈 ADD THIS
      });

      sessionCount++;

      // Smarter breaks
      int breakMinutes = (duration >= 60) ? 15 : 10;

      currentTime = end.add(Duration(minutes: breakMinutes));
    }

    return schedule;
  }

  int estimateDuration(Map<String, dynamic> task) {
    final difficulty = (task['difficulty'] ?? 'easy')
        .toString()
        .toLowerCase()
        .trim();

    switch (difficulty) {
      case 'hard':
        return 70; // 1h 10m
      case 'medium':
        return 45;
      case 'easy':
      default:
        return 25;
    }
  }

  Future<void> generateSmartSchedule() async {
    final snapshot = await firestore.getTasks().first;

    final docs = snapshot.docs;

    final schedule = generateSchedule(docs);

    await createPdf(schedule);
  }

  double calculateScore(Map<String, dynamic> task) {
    final priority = (task['priority'] ?? 'low').toString();
    final difficulty = (task['difficulty'] ?? 'easy').toString();
    final deadline = (task['deadline'] as Timestamp?)?.toDate();

    // Priority score (0–3)
    final priorityMap = {'low': 1.0, 'medium': 2.0, 'high': 3.0};

    // Difficulty score (0–2)
    final difficultyMap = {'easy': 1.0, 'medium': 1.5, 'hard': 2.0};

    double priorityScore = priorityMap[priority] ?? 1.0;
    double difficultyScore = difficultyMap[difficulty] ?? 1.0;

    double urgencyScore = 0;

    if (deadline != null) {
      final hoursLeft = deadline.difference(DateTime.now()).inHours;

      if (hoursLeft <= 0) {
        urgencyScore = 5; // VERY urgent
      } else if (hoursLeft < 6) {
        urgencyScore = 4;
      } else if (hoursLeft < 24) {
        urgencyScore = 3;
      } else if (hoursLeft < 72) {
        urgencyScore = 2;
      } else {
        urgencyScore = 1;
      }
    }

    // Final weighted score
    return (priorityScore * 2) + (difficultyScore * 1.5) + (urgencyScore * 3);
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Please login to view tasks",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text("Tasks"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: showFilterBottomSheet,
          ),

          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary, size: 30),
            onPressed: showAdd,
          ),

          SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No tasks yet", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text(
                    "Tap the + button to add your first task",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          // SEARCH FILTER
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final title = (data['title'] ?? '').toString().toLowerCase();

            return title.contains(searchQuery);
          }).toList();

          // PRIORITY FILTER
          if (selectedPriorityFilter != 'all') {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return data['priority'] == selectedPriorityFilter;
            }).toList();
          }

          // DIFFICULTY FILTER
          if (selectedDifficultyFilter != 'all') {
            docs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return data['difficulty'] == selectedDifficultyFilter;
            }).toList();
          }

          // SORTING
          docs.sort((a, b) {
            final taskA = a.data() as Map<String, dynamic>;
            final taskB = b.data() as Map<String, dynamic>;

            if (selectedSort == 'priority') {
              final priorityMap = {'high': 3, 'medium': 2, 'low': 1};

              return (priorityMap[taskB['priority']] ?? 0).compareTo(
                priorityMap[taskA['priority']] ?? 0,
              );
            }

            if (selectedSort == 'difficulty') {
              final difficultyMap = {'hard': 3, 'medium': 2, 'easy': 1};

              return (difficultyMap[taskB['difficulty']] ?? 0).compareTo(
                difficultyMap[taskA['difficulty']] ?? 0,
              );
            }

            if (selectedSort == 'urgency') {
              return calculateScore(taskB).compareTo(calculateScore(taskA));
            }

            // DEADLINE SORT
            final deadlineA = (taskA['deadline'] as Timestamp?)?.toDate();

            final deadlineB = (taskB['deadline'] as Timestamp?)?.toDate();

            if (deadlineA == null || deadlineB == null) {
              return 0;
            }

            return deadlineA.compareTo(deadlineB);
          });

          // FIX: Use Column with Expanded, NOT SingleChildScrollView
          return Column(
            children: [
              buildSmartFeatures(),
              Expanded(
                // This will take all remaining space
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final task = docs[i];
                    final taskData = task.data() as Map<String, dynamic>;

                    final taskTitle =
                        taskData['title'] as String? ?? 'Untitled Task';
                    final subject = taskData['subject'] as String? ?? '';
                    final priority =
                        taskData['priority'] as String? ?? 'medium';
                    final difficulty =
                        taskData['difficulty'] as String? ?? 'medium';
                    final isCompleted =
                        taskData['isCompleted'] as bool? ?? false;
                    final deadline = (taskData['deadline'] as Timestamp?)
                        ?.toDate();

                    Color priorityColor = Colors.grey;
                    switch (priority) {
                      case 'low':
                        priorityColor = Colors.green;
                        break;
                      case 'medium':
                        priorityColor = Colors.orange;
                        break;
                      case 'high':
                        priorityColor = Colors.red;
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: isCompleted,
                                  onChanged: (value) async {
                                    try {
                                      await firestore.toggleTaskCompletion(
                                        task.id,
                                        value!,
                                      );
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Error updating task",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                // Task info - Expanded to take available space
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        taskTitle,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (subject.isNotEmpty)
                                        Text(
                                          subject,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      // Tags section - moved here to be under task info
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          // Priority tag
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: priorityColor.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: priorityColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  priority.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: priorityColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Difficulty tag
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              difficulty.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          // Deadline tag (if exists)
                                          if (deadline != null)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 10,
                                                    color: Colors.purple,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    _formatDeadline(deadline),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.purple,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          showEditDialog(task.id, taskData),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        try {
                                          await firestore.deleteTask(task.id);
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Task deleted'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Error deleting task",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to format deadline nicely
  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays == 0) {
      // Today
      return "Today ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      // Tomorrow
      return "Tomorrow ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays < 7) {
      // Within a week
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return "${days[deadline.weekday - 1]} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}";
    } else {
      // More than a week
      return "${deadline.day}/${deadline.month} ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}";
    }
  }
}
