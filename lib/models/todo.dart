import 'package:flutter/material.dart';

enum TaskPriority {
  low('Low', Colors.green, 1),
  medium('Medium', Colors.orange, 2),
  high('High', Colors.red, 3);

  const TaskPriority(this.label, this.color, this.value);
  
  final String label;
  final Color color;
  final int value;
}

enum TaskCategory {
  personal('Personal', Icons.person),
  work('Work', Icons.work),
  shopping('Shopping', Icons.shopping_cart),
  health('Health', Icons.favorite),
  education('Education', Icons.school),
  finance('Finance', Icons.account_balance_wallet),
  other('Other', Icons.category);

  const TaskCategory(this.label, this.icon);
  
  final String label;
  final IconData icon;
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Todo {
  final String id;
  final String title;
  final String notes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskCategory category;
  final List<SubTask> subTasks;
  final int timeSpentMinutes; // For time tracking
  final bool isRecurring;
  final int streakCount; // For habit tracking

  Todo({
    required this.id,
    required this.title,
    this.notes = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    List<SubTask>? subTasks,
    this.timeSpentMinutes = 0,
    this.isRecurring = false,
    this.streakCount = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       subTasks = subTasks ?? [];

  Todo copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskCategory? category,
    List<SubTask>? subTasks,
    int? timeSpentMinutes,
    bool? isRecurring,
    int? streakCount,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      subTasks: subTasks ?? this.subTasks,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      isRecurring: isRecurring ?? this.isRecurring,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  // Helper methods
  bool get isOverdue => dueDate != null && 
                      dueDate!.isBefore(DateTime.now()) && 
                      !isCompleted;

  bool get isDueToday => dueDate != null &&
                        dueDate!.day == DateTime.now().day &&
                        dueDate!.month == DateTime.now().month &&
                        dueDate!.year == DateTime.now().year;

  bool get isDueSoon => dueDate != null &&
                       dueDate!.isAfter(DateTime.now()) &&
                       dueDate!.isBefore(DateTime.now().add(const Duration(days: 3)));

  int get completedSubTasks => subTasks.where((st) => st.isCompleted).length;
  
  double get subTaskProgress => subTasks.isEmpty ? 1.0 : completedSubTasks / subTasks.length;

  String get timeSpentFormatted {
    final hours = timeSpentMinutes ~/ 60;
    final minutes = timeSpentMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}