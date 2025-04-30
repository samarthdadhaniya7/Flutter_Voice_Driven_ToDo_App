import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<String>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<String>> {
  TaskNotifier() : super([]);

  // Add a new task
  void addTask(String task) {
    state = [...state, task];
    _addTaskToFirestore(task);
  }

  // Mark a task as completed
  void completeTask(String task) {
    state = state.where((t) => t != task).toList();
    _removeTaskFromFirestore(task);
  }

  // Add task to Firestore
  Future<void> _addTaskToFirestore(String task) async {
    await FirebaseFirestore.instance.collection('tasks').add({
      'task': task,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Remove task from Firestore
  Future<void> _removeTaskFromFirestore(String task) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('task', isEqualTo: task)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Sync task from Firestore (handle real-time sync)
  Future<void> syncTasks() async {
    FirebaseFirestore.instance
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs.map((doc) => doc['task'] as String).toList();
    });
  }
}
