import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

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
    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addTask(String title) async {
    await _db.collection('users').doc(uid).collection('tasks').add({
      'title': title,
      'isCompleted': false,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
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
