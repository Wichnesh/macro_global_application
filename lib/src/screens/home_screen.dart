import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:macro_global_test_app/src/blocs/auth/auth_bloc.dart';
import 'package:macro_global_test_app/src/blocs/auth/auth_event.dart';
import 'package:macro_global_test_app/src/blocs/task/task_bloc.dart';
import 'package:macro_global_test_app/src/blocs/task/task_event.dart';
import 'package:macro_global_test_app/src/blocs/task/task_state.dart';
import 'package:macro_global_test_app/src/model/task_model.dart';
import 'package:macro_global_test_app/src/service/auth_service.dart';
import 'package:macro_global_test_app/src/service/storage_service.dart';
import 'package:macro_global_test_app/src/utils/shimmer.dart';
import 'package:toastification/toastification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userId = '';
  String _searchQuery = '';
  String _filterStatus = 'pending';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await StorageService.getUser();
    setState(() {
      _userId = user['uid'] ?? '';
      _userName = user['name'] ?? '';
      _userEmail = user['email'] ?? '';
      _userPhone = user['phone'] ?? '';
    });

    // Prompt if name or phone is missing
    if (_userName.isEmpty || _userPhone.isEmpty) {
      Future.delayed(Duration.zero, _showEditProfileDialog);
    }

    context.read<TaskBloc>().add(LoadTasks(_userId, _filterStatus));
  }

  void _onFilterChanged(String status) {
    setState(() => _filterStatus = status);
    context.read<TaskBloc>().add(LoadTasks(_userId, status));
  }

  void _onSearch(String value) {
    setState(() => _searchQuery = value.toLowerCase());
  }

  void _refreshTasks() {
    context.read<TaskBloc>().add(LoadTasks(_userId, _filterStatus));
  }

  void _showAddTaskDialog() {
    final _formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Add Task"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                    ),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              selectedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Text(
                        selectedDate != null ? "Picked: ${DateFormat('yyyy-MM-dd – hh:mm a').format(selectedDate!)}" : "Pick Due Date & Time",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedDate == null) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.warning,
                          title: const Text("Please pick a due date & time"),
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      context.read<TaskBloc>().add(AddTask(
                            title: titleController.text,
                            description: descController.text,
                            dueDate: selectedDate!.toUtc(),
                            userId: _userId,
                          ));

                      Navigator.pop(context);

                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        title: const Text('Task added successfully'),
                        autoCloseDuration: const Duration(seconds: 3),
                      );

                      _refreshTasks();
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    DateTime? selectedDate = task.dueDate.toLocal();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDate!),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      selectedDate = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text(
                selectedDate != null ? "Picked: ${DateFormat('yyyy-MM-dd – hh:mm a').format(selectedDate!)}" : "Pick Due Date & Time",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedDate != null && _userId.isNotEmpty) {
                context.read<TaskBloc>().add(EditTask(
                      userId: _userId,
                      taskId: task.id,
                      title: titleController.text,
                      description: descController.text,
                      dueDate: selectedDate!.toUtc(),
                    ));

                Navigator.pop(context);

                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  title: const Text("Task updated successfully"),
                  autoCloseDuration: const Duration(seconds: 3),
                );
                _refreshTasks();
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final phoneController = TextEditingController(text: _userPhone);
    final emailController = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email (not editable)",
                hintText: _userEmail,
                prefixIcon: const Icon(Icons.lock),
                disabledBorder: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isNotEmpty || phone.isNotEmpty) {
                await AuthService().updateUserProfile(_userId, {
                  'name': name,
                  'phone': phone,
                });

                await StorageService.updateUser({
                  'name': name,
                  'phone': phone,
                });

                setState(() {
                  _userName = name;
                  _userPhone = phone;
                });

                Navigator.pop(context);

                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  title: const Text("Profile updated successfully"),
                  autoCloseDuration: const Duration(seconds: 3),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isOverdue = task.status == 'overdue';
    final isCompleted = task.status == 'completed';
    final statusColor = isOverdue
        ? Colors.red
        : isCompleted
            ? Colors.green
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy-MM-dd – hh:mm a').format(task.dueDate.toLocal()),
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                IconButton(
                  tooltip: "Edit",
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => _showEditTaskDialog(task),
                ),
                IconButton(
                  tooltip: "Mark as Done",
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: isCompleted
                      ? null
                      : () {
                          final now = DateTime.now();
                          final due = task.dueDate.toLocal();
                          final newStatus = due.isBefore(now) ? 'overdue' : 'completed';

                          context.read<TaskBloc>().add(
                                UpdateTaskStatus(_userId, task.id, newStatus),
                              );

                          toastification.show(
                            context: context,
                            type: newStatus == 'completed' ? ToastificationType.success : ToastificationType.warning,
                            title: Text(newStatus == 'completed' ? 'Task marked as Completed' : 'Task was overdue! Marked accordingly'),
                            autoCloseDuration: const Duration(seconds: 3),
                          );
                          _refreshTasks();
                        },
                ),
                IconButton(
                  tooltip: "Delete",
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () {
                    context.read<TaskBloc>().add(DeleteTask(_userId, task.id));
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      title: const Text('Task deleted'),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    _refreshTasks();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    const filters = ['pending', 'completed', 'overdue'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: filters.map((status) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text(status.toUpperCase()),
            selected: _filterStatus == status,
            onSelected: (_) => _onFilterChanged(status),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Tasks'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search tasks...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearch,
                ),
              ),
              _buildFilterTabs(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return buildShimmerLoader();
          }

          if (state is TaskError) {
            return Center(child: Text(state.message));
          }

          if (state is TaskLoaded) {
            final tasks = state.tasks.where((task) => task.title.toLowerCase().contains(_searchQuery)).toList();

            if (tasks.isEmpty) {
              return const Center(child: Text("No tasks found."));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskBloc>().add(LoadTasks(_userId, _filterStatus));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (_, index) => _buildTaskCard(tasks[index]),
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
