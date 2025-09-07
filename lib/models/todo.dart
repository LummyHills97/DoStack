import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'todo.g.dart'; // needed for Hive codegen

/// =======================
/// Task Priority Enum
/// =======================
@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}

/// =======================
/// Task Category Enum
/// =======================
@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  personal,
  @HiveField(1)
  work,
  @HiveField(2)
  study,
  @HiveField(3)
  shopping,
  @HiveField(4)
  others,
}

extension TaskCategoryX on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.study:
        return Icons.school;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.others:
        return Icons.category;
    }
  }
}

/// =======================
/// SubTask Model
/// =======================
@HiveType(typeId: 2)
class SubTask extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late bool isCompleted;

  SubTask({
    required this.title,
    this.isCompleted = false,
  });

  // Added copyWith method for SubTask too
  SubTask copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// =======================
/// Todo Model
/// =======================
@HiveType(typeId: 3)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String notes;

  @HiveField(3)
  TaskPriority priority;

  @HiveField(4)
  TaskCategory category;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  List<SubTask> subTasks;

  @HiveField(9)
  int timeSpentMinutes;

  @HiveField(10)
  int streakCount;

  Todo({
    required this.id,
    required this.title,
    this.notes = '',
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    this.dueDate,
    this.isRecurring = false,
    this.isCompleted = false,
    List<SubTask>? subTasks,  // Fixed: changed parameter type
    this.timeSpentMinutes = 0,
    this.streakCount = 0,
  }) : subTasks = subTasks ?? <SubTask>[];  // Fixed: proper initialization

  // ADDED: The missing copyWith method that TodoViewModel needs
  Todo copyWith({
    String? id,
    String? title,
    String? notes,
    TaskPriority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool? isRecurring,
    bool? isCompleted,
    List<SubTask>? subTasks,
    int? timeSpentMinutes,
    int? streakCount,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      subTasks: subTasks ?? this.subTasks,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}