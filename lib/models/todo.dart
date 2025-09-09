class Todo {
  final String id;
  final String title;
  final String notes;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.notes = '',
    this.isCompleted = false,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? notes,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
