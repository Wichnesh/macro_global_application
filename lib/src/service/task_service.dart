import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Stream<List<Task>> getTasksByStatus(String userId, String status) {
    return _userTasksRef(userId)
        .where('status', isEqualTo: status)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromDocument(doc)).toList());
  }

  Future<void> addTask(Task task) async {
    await _userTasksRef(task.userId).add(task.toMap());
  }

  Future<void> updateTaskStatus(String userId, String taskId, String newStatus) async {
    await _userTasksRef(userId).doc(taskId).update({'status': newStatus});
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _userTasksRef(userId).doc(taskId).delete();
  }

  Future<void> updateTask(String userId, String taskId, Map<String, dynamic> data) async {
    await _userTasksRef(userId).doc(taskId).update(data);
  }
}
