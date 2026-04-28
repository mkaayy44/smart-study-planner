import 'package:flutter/material.dart';
import 'package:studyplanner/app design/app_card.dart';
import 'package:studyplanner/app design/app_colors.dart';
import 'package:studyplanner/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final firestore = FirestoreService();

  void showAdd() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter task",
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 15),

            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                await firestore.addTask(controller.text.trim());

                Navigator.pop(context);
              },
              child: Text("Add Task"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tasks yet"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final task = docs[i];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(task['title']),
                      ),

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await firestore
                              .deleteTask(task.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: showAdd,
        child: Icon(Icons.add),
      ),
    );
  }
}