// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/task_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, authController),
      body: SafeArea(
        child: Column(
          children: [
            // Statistics Overview Cards
            _buildStatsSection(),

            // Search Bar & Sort Button
            _buildSearchAndSortBar(context),

            // Filter Tabs (All / Pending / Completed)
            _buildFilterTabs(),

            // Task List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingWidget(message: 'Loading your tasks...');
                }

                final tasks = controller.filteredTasks;

                if (tasks.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    // Refresh is real-time via Firestore stream, so short delay
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Get.toNamed(AppRoutes.TASK_DETAIL, arguments: task);
                        },
                        onToggle: (_) {
                          controller.toggleTaskStatus(task);
                        },
                        onEdit: () {
                          Get.toNamed(AppRoutes.EDIT_TASK, arguments: task);
                        },
                        onDelete: () {
                          controller.confirmDeleteTask(task);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(AppRoutes.ADD_TASK);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(AppIcons.add, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AuthController authController) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleSpacing: 16,
      title: Obx(() {
        final userName = authController.currentUserModel.value?.name ?? 'User';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          tooltip: AppStrings.logout,
          icon: const Icon(AppIcons.logout, color: AppColors.error, size: 22),
          onPressed: () => authController.confirmLogout(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(
        () => Row(
          children: [
            _buildStatCard(
              title: AppStrings.total,
              count: controller.totalCount,
              color: AppColors.primary,
              bgColor: AppColors.primaryLight,
              icon: AppIcons.totalTasks,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              title: AppStrings.pending,
              count: controller.pendingCount,
              color: AppColors.warning,
              bgColor: AppColors.priorityMediumBg,
              icon: AppIcons.pending,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              title: AppStrings.completed,
              count: controller.completedCount,
              color: AppColors.success,
              bgColor: AppColors.successBg,
              icon: AppIcons.checkCircle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: AppStrings.searchPlaceholder,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                  prefixIcon: const Icon(
                    AppIcons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              AppIcons.clear,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: controller.clearSearch,
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Sort Button
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              icon: const Icon(
                AppIcons.sort,
                color: AppColors.primary,
                size: 22,
              ),
              tooltip: 'Sort Options',
              onPressed: () => _showSortBottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Obx(
        () => Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = controller.selectedFilter.value == key;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => controller.setFilter(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.totalTasks,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              AppStrings.noTasksFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              AppStrings.noTasksSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort Tasks By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Obx(
                () => Column(
                  children: [
                    _buildSortTile(
                      label: 'Due Date: Earliest First',
                      value: 'dueDateAsc',
                      icon: AppIcons.calendar,
                    ),
                    _buildSortTile(
                      label: 'Due Date: Latest First',
                      value: 'dueDateDesc',
                      icon: AppIcons.calendar,
                    ),
                    _buildSortTile(
                      label: 'Priority: High to Low',
                      value: 'priorityHigh',
                      icon: AppIcons.flag,
                    ),
                    _buildSortTile(
                      label: 'Priority: Low to High',
                      value: 'priorityLow',
                      icon: AppIcons.flag,
                    ),
                    _buildSortTile(
                      label: 'Recently Created First',
                      value: 'newest',
                      icon: Icons.history_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSortTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = controller.selectedSort.value == value;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        controller.setSort(value);
        Get.back();
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
