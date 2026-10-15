// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/task_controller.dart';

class AddEditTaskView extends GetView<TaskController> {
  const AddEditTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM dd, yyyy - hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          controller.isEditing ? AppStrings.editTask : AppStrings.addNewTask,
          style: const TextStyle(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Title
                CustomTextField(
                  controller: controller.titleController,
                  labelText: AppStrings.taskTitle,
                  hintText: AppStrings.taskTitleHint,
                  prefixIcon: AppIcons.edit,
                  validator: controller.validateTitle,
                  textInputAction: TextInputAction.next,
                  autoFocus: !controller.isEditing,
                ),
                const SizedBox(height: 20),

                // Task Description
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: AppStrings.taskDesc,
                  hintText: AppStrings.taskDescHint,
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),

                // Due Date Selector
                const Text(
                  AppStrings.dueDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => controller.pickDueDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            AppIcons.calendar,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dateFormat.format(controller.selectedDueDate.value),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Priority Selection
                const Text(
                  AppStrings.priority,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    children: [
                      _buildPriorityOption('Low', AppColors.priorityLow,
                          AppColors.priorityLowBg),
                      const SizedBox(width: 12),
                      _buildPriorityOption('Medium', AppColors.priorityMedium,
                          AppColors.priorityMediumBg),
                      const SizedBox(width: 12),
                      _buildPriorityOption('High', AppColors.priorityHigh,
                          AppColors.priorityHighBg),
                    ],
                  ),
                ),

                // Status Switch (if editing)
                if (controller.isEditing) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.2),
                    ),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                controller.isCompleted.value
                                    ? AppIcons.checkCircle
                                    : AppIcons.pending,
                                color: controller.isCompleted.value
                                    ? AppColors.success
                                    : AppColors.warning,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                controller.isCompleted.value
                                    ? 'Completed'
                                    : 'Mark as Completed',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.isCompleted.value,
                            activeColor: AppColors.success,
                            onChanged: (val) {
                              controller.isCompleted.value = val;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Submit Button
                Obx(
                  () => CustomButton(
                    text: controller.isEditing
                        ? AppStrings.updateTask
                        : AppStrings.saveTask,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.saveTask,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String label, Color color, Color bg) {
    final isSelected = controller.selectedPriority.value.toLowerCase() ==
        label.toLowerCase();

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.setPriority(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                AppIcons.flag,
                size: 18,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
