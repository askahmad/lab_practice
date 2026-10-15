import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/task_service.dart';

class TaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final AuthService _authService = Get.find<AuthService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form Fields
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Rx<DateTime> selectedDueDate =
      Rx<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final RxString selectedPriority = 'Medium'.obs;
  final RxBool isCompleted = false.obs;
  final RxBool isLoading = false.obs;

  // Editing state
  TaskModel? editingTask;
  bool get isEditing => editingTask != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TaskModel) {
      initForEdit(args);
    } else {
      initForAdd();
    }
  }

  void initForAdd() {
    editingTask = null;
    titleController.clear();
    descriptionController.clear();
    selectedDueDate.value = DateTime.now().add(const Duration(days: 1));
    selectedPriority.value = 'Medium';
    isCompleted.value = false;
  }

  void initForEdit(TaskModel task) {
    editingTask = task;
    titleController.text = task.title;
    descriptionController.text = task.description;
    selectedDueDate.value = task.dueDate;
    selectedPriority.value = task.priority;
    isCompleted.value = task.isCompleted;
  }

  void setPriority(String priority) {
    selectedPriority.value = priority;
  }

  Future<void> pickDueDate(BuildContext context) async {
    final DateTime initial = selectedDueDate.value;
    final DateTime firstDate = DateTime.now().subtract(const Duration(days: 365));
    final DateTime lastDate = DateTime.now().add(const Duration(days: 365 * 5));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        selectedDueDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      } else {
        selectedDueDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          23,
          59,
        );
      }
    }
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Task title is required';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  Future<void> saveTask() async {
    if (!formKey.currentState!.validate()) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Authentication Error',
        'You must be logged in to save tasks.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      if (isEditing) {
        final updated = editingTask!.copyWith(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: selectedDueDate.value,
          priority: selectedPriority.value,
          isCompleted: isCompleted.value,
        );
        await _taskService.updateTask(updated);
        Get.back(result: true);
        Get.snackbar(
          'Updated',
          'Task updated successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      } else {
        final newTask = TaskModel(
          id: '',
          userId: currentUser.uid,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: selectedDueDate.value,
          priority: selectedPriority.value,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        await _taskService.addTask(newTask);
        Get.back(result: true);
        Get.snackbar(
          'Task Added',
          'Your new task has been created!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save task: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    Get.defaultDialog(
      title: 'Delete Task',
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      middleText: 'Are you sure you want to permanently delete this task?',
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
          await _taskService.deleteTask(task.userId, task.id);
          Get.back(); // close screen if in detail/edit view
          Get.snackbar(
            'Deleted',
            'Task deleted successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.info,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(16),
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to delete task: ${e.toString()}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
