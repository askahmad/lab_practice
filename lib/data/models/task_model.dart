import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: map['priority'] as String? ?? 'Medium',
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return TaskModel.fromMap(data, doc.id);
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Priority color helpers
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'low':
        return AppColors.priorityLow;
      case 'medium':
      default:
        return AppColors.priorityMedium;
    }
  }

  Color get priorityBgColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHighBg;
      case 'low':
        return AppColors.priorityLowBg;
      case 'medium':
      default:
        return AppColors.priorityMediumBg;
    }
  }

  int get priorityWeight {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
      default:
        return 1;
    }
  }
}
