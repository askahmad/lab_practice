import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/task_controller.dart';
import '../../home/controllers/home_controller.dart';

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Task passed through arguments
    final TaskModel initialTask = Get.arguments as TaskModel;
    final homeController = Get.find<HomeController>();
    final taskController = Get.find<TaskController>();

    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy - hh:mm a');
    final createdFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.taskDetails,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.edit, color: AppColors.primary, size: 22),
            onPressed: () async {
              // Find updated task if modified
              final current = homeController.tasks.firstWhere(
                (t) => t.id == initialTask.id,
                orElse: () => initialTask,
              );
              final result = await Get.toNamed(
                AppRoutes.EDIT_TASK,
                arguments: current,
              );
              if (result == true) {
                // If updated, stay or refresh
              }
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.delete, color: AppColors.error, size: 22),
            onPressed: () {
              final current = homeController.tasks.firstWhere(
                (t) => t.id == initialTask.id,
                orElse: () => initialTask,
              );
              taskController.deleteTask(current);
            },
          ),
        ],
      ),
      body: Obx(() {
        // Find latest reactive version of this task from HomeController
        final currentTask = homeController.tasks.firstWhere(
          (t) => t.id == initialTask.id,
          orElse: () => initialTask,
        );

        final isOverdue = !currentTask.isCompleted &&
            currentTask.dueDate.isBefore(DateTime.now());

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority & Status Row
                Row(
                  children: [
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentTask.priorityBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.flag,
                            size: 14,
                            color: currentTask.priorityColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentTask.priority} Priority',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: currentTask.priorityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentTask.isCompleted
                            ? AppColors.successBg
                            : AppColors.priorityMediumBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentTask.isCompleted
                                ? AppIcons.checkCircle
                                : AppIcons.pending,
                            size: 14,
                            color: currentTask.isCompleted
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentTask.isCompleted ? 'Completed' : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: currentTask.isCompleted
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Task Title
                Text(
                  currentTask.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    decoration: currentTask.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 20),

                // Due Date Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? AppColors.errorBg
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppIcons.calendar,
                          color: isOverdue ? AppColors.error : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOverdue ? 'Overdue Due Date' : 'Due Date',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(currentTask.dueDate),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description Card
                const Text(
                  AppStrings.taskDesc,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    currentTask.description.isNotEmpty
                        ? currentTask.description
                        : 'No additional description provided for this task.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: currentTask.description.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Created At Info
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Created: ${createdFormat.format(currentTask.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Quick Toggle Button
                CustomButton(
                  text: currentTask.isCompleted
                      ? 'Mark as Incomplete'
                      : 'Mark as Completed',
                  icon: currentTask.isCompleted
                      ? AppIcons.pending
                      : AppIcons.checkCircle,
                  backgroundColor: currentTask.isCompleted
                      ? AppColors.textSecondary
                      : AppColors.success,
                  onPressed: () {
                    homeController.toggleTaskStatus(currentTask);
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
