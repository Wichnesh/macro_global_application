import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macro_global_test_app/src/model/task_model.dart';
import 'package:macro_global_test_app/src/service/task_service.dart';

import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService taskService;

  TaskBloc(this.taskService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<EditTask>(_onEditTask);
    on<DeleteTask>(_onDeleteTask);
    on<_TaskStreamUpdated>(_onStreamUpdated);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    emit(TaskLoading());
    taskService.getTasksByStatus(event.userId, event.status).listen(
      (tasks) {
        add(_TaskStreamUpdated(tasks));
      },
    );
  }

  void _onStreamUpdated(_TaskStreamUpdated event, Emitter<TaskState> emit) {
    emit(TaskLoaded(event.tasks));
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final task = Task(
        id: '',
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        status: 'pending',
        userId: event.userId,
      );
      await taskService.addTask(task);
    } catch (e) {
      emit(TaskError('Failed to add task'));
    }
  }

  void _onUpdateTaskStatus(UpdateTaskStatus event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await taskService.updateTaskStatus(event.userId, event.taskId, event.newStatus);
    } catch (e) {
      emit(TaskError('Failed to update task status'));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await taskService.deleteTask(event.userId, event.taskId);
    } catch (e) {
      emit(TaskError('Failed to delete task'));
    }
  }

  void _onEditTask(EditTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await taskService.updateTask(event.userId, event.taskId, {
        'title': event.title,
        'description': event.description,
        'dueDate': event.dueDate.toUtc(),
      });
    } catch (e) {
      emit(TaskError('Failed to update task'));
    }
  }
}

// Internal event to pass real-time stream updates into BLoC
class _TaskStreamUpdated extends TaskEvent {
  final List<Task> tasks;

  _TaskStreamUpdated(this.tasks);
}
