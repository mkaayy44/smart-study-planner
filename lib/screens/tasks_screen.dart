import 'package:flutter/material.dart' show Widget, TextEditingController, StatefulWidget, State, BuildContext, EdgeInsets, Colors, BorderRadius, Radius, BoxDecoration, MainAxisSize, SizedBox, Text, Navigator, ElevatedButton, Column, Container, showModalBottomSheet, TextField, ListView, Padding, Icons, Icon, FloatingActionButton, Scaffold;
import 'package:studyplanner/app%20design/app_card.dart';
import 'package:studyplanner/app%20design/app_colors.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<String> tasks = ["Study UI", "Workout"];

  void addTask(String t) {
    setState(() => tasks.add(t));
  }

  void showAdd() {
    final c = TextEditingController();

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
            _input(c),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                addTask(c.text);
                Navigator.pop(context);
              },
              child: Text("Add Task"),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c) => TextField(controller: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 70, 20, 20),
        itemCount: tasks.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(child: Text(tasks[i])),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: showAdd,
        child: Icon(Icons.add),
      ),
    );
  }
}