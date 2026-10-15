import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/task_service.dart';

class HomeController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final AuthService _authService = Get.find<AuthService>();

  // Observables
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // 'all', 'pending', 'completed'
  final RxString selectedSort = 'dueDateAsc'.obs; // 'dueDateAsc', 'dueDateDesc', 'priorityHigh', 'priorityLow', 'newest'
  final RxBool isLoading = true.obs;

  final TextEditingController searchController = TextEditingController();
  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToUserTasks();
  }

  void _listenToUserTasks() {
    final user = _authService.currentUser;
    if (user != null) {
      isLoading.value = true;
      _tasksSubscription?.cancel();
      _tasksSubscription = _taskService.getTasksStream(user.uid).listen(
        (taskList) {
          tasks.assignAll(taskList);
          isLoading.value = false;
        },
        onError: (err) {
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Could not load tasks: $err',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        },
      );
    } else {
      isLoading.value = false;
    }
  }

  // Summary counts
  int get totalCount => tasks.length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;

  // Filtered and Sorted list
  List<TaskModel> get filteredTasks {
    List<TaskModel> list = List.from(tasks);

    // 1. Search filter
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      list = list.where((task) {
        return task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Status filter
    if (selectedFilter.value == 'pending') {
      list = list.where((task) => !task.isCompleted).toList();
    } else if (selectedFilter.value == 'completed') {
      list = list.where((task) => task.isCompleted).toList();
    }

    // 3. Sorting
    switch (selectedSort.value) {
      case 'dueDateAsc':
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'dueDateDesc':
        list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
        break;
      case 'priorityHigh':
        list.sort((a, b) => b.priorityWeight.compareTo(a.priorityWeight));
        break;
      case 'priorityLow':
        list.sort((a, b) => a.priorityWeight.compareTo(b.priorityWeight));
        break;
      case 'newest':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    return list;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void setSort(String sort) {
    selectedSort.value = sort;
  }

  // Toggle task completion
  Future<void> toggleTaskStatus(TaskModel task) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final newStatus = !task.isCompleted;
      await _taskService.toggleTaskStatus(user.uid, task.id, newStatus);
      Get.snackbar(
        newStatus ? 'Task Completed' : 'Task Marked Pending',
        task.title,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: newStatus ? AppColors.success : AppColors.warning,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // Delete task with confirmation dialog
  Future<void> confirmDeleteTask(TaskModel task) async {
    final user = _authService.currentUser;
    if (user == null) return;

    Get.defaultDialog(
      title: 'Delete Task',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      middleText: 'Are you sure you want to delete "${task.title}"?',
      middleTextStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      radius: 16,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () async {
        Get.back(); // close dialog
        try {
          await _taskService.deleteTask(user.uid, task.id);
          Get.snackbar(
            'Deleted',
            'Task removed successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.info,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to delete task: $e',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
