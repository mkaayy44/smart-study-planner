import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // ---------------- USERS ----------------
  Future<void> createUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phone,
      'createdAt': Timestamp.now(),
    });
  }

  // ---------------- TASKS ----------------

  Stream<QuerySnapshot> getTasks() {
    final userId = uid;
    if (userId == null) {
      // Return empty stream if no user
      return Stream.empty();
    }

    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add new task with all fields
  Future<void> addTask({
    required String title,
    required String subject,
    required String priority,
    required String difficulty,
    DateTime? deadline,
  }) async {
    final userId = uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }

    await _db.collection('users').doc(userId).collection('tasks').add({
      'title': title,
      'subject': subject,
      'priority': priority, // 'low', 'medium', 'high'
      'difficulty': difficulty, // 'easy', 'medium', 'hard'
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'isCompleted': false,
      'createdAt': Timestamp.now(),
    });
  }

  // Update existing task
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String subject,
    required String priority,
    required String difficulty,
    DateTime? deadline,
  }) async {
    final userId = uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({
          'title': title,
          'subject': subject,
          'priority': priority,
          'difficulty': difficulty,
          'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
          'updatedAt': Timestamp.now(),
        });
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final userId = uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({
          'isCompleted': isCompleted,
          'completedAt': isCompleted ? Timestamp.now() : null,
        });
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final userId = uid;
    if (userId == null) {
      throw Exception("User not authenticated");
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // ---------------- SESSIONS ----------------
  Future<void> addSession(int duration) async {
    await _db.collection('users').doc(uid).collection('sessions').add({
      'duration': duration,
      'date': Timestamp.now(),
    });
  }
}
