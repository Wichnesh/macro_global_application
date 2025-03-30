abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final String status;
  final String userId;

  LoadTasks(this.userId, this.status);
}

class AddTask extends TaskEvent {
  final String title;
  final String description;
  final DateTime dueDate;
  final String userId;

  AddTask({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.userId,
  });
}

class UpdateTaskStatus extends TaskEvent {
  final String userId;
  final String taskId;
  final String newStatus;

  UpdateTaskStatus(this.userId, this.taskId, this.newStatus);
}

class DeleteTask extends TaskEvent {
  final String userId;
  final String taskId;

  DeleteTask(this.userId, this.taskId);
}

class EditTask extends TaskEvent {
  final String userId;
  final String taskId;
  final String title;
  final String description;
  final DateTime dueDate;

  EditTask({
    required this.userId,
    required this.taskId,
    required this.title,
    required this.description,
    required this.dueDate,
  });
}
