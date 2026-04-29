import 'package:flutter/material.dart';
import 'package:studyplanner/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksScreen extends StatefulWidget {
@override
State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
final firestore = FirestoreService();

@override
Widget build(BuildContext context) {
return Scaffold(
body: StreamBuilder<QuerySnapshot>(
stream: firestore.getTasks(),
builder: (context, snapshot) {
if (!snapshot.hasData) {
return Center(child: Text("No tasks yet"));
}
      final docs = snapshot.data!.docs;

      return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (_, i) {
          final data =
              docs[i].data() as Map<String, dynamic>?;

          final title = data?['title'] ?? 'Untitled';

          return ListTile(
            title: Text(title),
          );
        },
      );
    },
  ),
);}
}
