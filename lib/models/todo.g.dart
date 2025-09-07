// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 0;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeByte(obj.index);
  }
}

class TaskCategoryAdapter extends TypeAdapter<TaskCategory> {
  @override
  final int typeId = 1;

  @override
  TaskCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskCategory.personal;
      case 1:
        return TaskCategory.work;
      case 2:
        return TaskCategory.study;
      case 3:
        return TaskCategory.shopping;
      case 4:
        return TaskCategory.others;
      default:
        return TaskCategory.personal;
    }
  }

  @override
  void write(BinaryWriter writer, TaskCategory obj) {
    writer.writeByte(obj.index);
  }
}

class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 2;

  @override
  SubTask read(BinaryReader reader) {
    return SubTask(
      title: reader.readString(),
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer.writeString(obj.title);
    writer.writeBool(obj.isCompleted);
  }
}

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 3;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      id: reader.readString(),
      title: reader.readString(),
      notes: reader.readString(),
      priority: reader.read() as TaskPriority,
      category: reader.read() as TaskCategory,
      dueDate: reader.read() as DateTime?,
      isRecurring: reader.readBool(),
      isCompleted: reader.readBool(),
      subTasks: (reader.readList().cast<SubTask>()),
      timeSpentMinutes: reader.readInt(),
      streakCount: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.notes);
    writer.write(obj.priority);
    writer.write(obj.category);
    writer.write(obj.dueDate);
    writer.writeBool(obj.isRecurring);
    writer.writeBool(obj.isCompleted);
    writer.writeList(obj.subTasks);
    writer.writeInt(obj.timeSpentMinutes);
    writer.writeInt(obj.streakCount);
  }
}
