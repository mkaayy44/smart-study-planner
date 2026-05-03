import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_card.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final firestore = FirestoreService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
  }

  void showAdd() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    String selectedPriority = 'medium';
    String selectedDifficulty = 'medium';
    DateTime? selectedDeadline;

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
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter a task title")),
                        );
                        return;
                      }

                      try {
                        await firestore.addTask(
                          title: titleController.text.trim(),
                          subject: subjectController.text.trim(),
                          priority: selectedPriority,
                          difficulty: selectedDifficulty,
                          deadline: selectedDeadline,
                        );

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
    DateTime? selectedDeadline = (currentData['deadline'] as Timestamp?)
        ?.toDate();

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
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter a task title")),
                        );
                        return;
                      }

                      try {
                        await firestore.updateTask(
                          taskId: taskId,
                          title: titleController.text.trim(),
                          subject: subjectController.text.trim(),
                          priority: selectedPriority,
                          difficulty: selectedDifficulty,
                          deadline: selectedDeadline,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text("Tasks"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Add button in AppBar instead of FAB
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

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final task = docs[i];
              final taskData = task.data() as Map<String, dynamic>;

              final taskTitle = taskData['title'] as String? ?? 'Untitled Task';
              final subject = taskData['subject'] as String? ?? '';
              final priority = taskData['priority'] as String? ?? 'medium';
              final difficulty = taskData['difficulty'] as String? ?? 'medium';
              final isCompleted = taskData['isCompleted'] as bool? ?? false;
              final deadline = (taskData['deadline'] as Timestamp?)?.toDate();

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                ),
                                onPressed: () =>
                                    showEditDialog(task.id, taskData),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await firestore.deleteTask(task.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Task deleted')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("Error deleting task"),
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
                      Padding(
                        padding: EdgeInsets.only(
                          left: 48,
                          right: 16,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
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
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
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
                            if (deadline != null) ...[
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
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
                                      "${deadline.day}/${deadline.month}/${deadline.year}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
