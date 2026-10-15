import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to user's tasks subcollection
  CollectionReference _userTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Real-time stream of user tasks
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _userTasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList();
    });
  }

  // Add new task
  Future<TaskModel> addTask(TaskModel task) async {
    try {
      final docRef = await _userTasksRef(task.userId).add(task.toMap());
      return task.copyWith(id: docRef.id);
    } catch (e) {
      throw 'Failed to add task: ${e.toString()}';
    }
  }

  // Update existing task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _userTasksRef(task.userId).doc(task.id).update(task.toMap());
    } catch (e) {
      throw 'Failed to update task: ${e.toString()}';
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskStatus(String userId, String taskId, bool isCompleted) async {
    try {
      await _userTasksRef(userId).doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      throw 'Failed to toggle task status: ${e.toString()}';
    }
  }

  // Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _userTasksRef(userId).doc(taskId).delete();
    } catch (e) {
      throw 'Failed to delete task: ${e.toString()}';
    }
  }
}
