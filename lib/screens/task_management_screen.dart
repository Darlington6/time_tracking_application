import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/project_task_provider.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final _taskController = TextEditingController();
  String? selectedProjectId;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);
    final tasks = provider.tasks;
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(title: Text('Manage Tasks')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Task Name'),
                  ),
                ),
                DropdownButton<String>(
                  hint: Text('Select Project'),
                  value: selectedProjectId,
                  items: projects.map((p) {
                    return DropdownMenuItem(value: p.id, child: Text(p.name));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedProjectId = val;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.trim().isEmpty || selectedProjectId == null) return;
                    final newTask = Task(
                      id: Uuid().v4(),
                      name: _taskController.text.trim(), 
                      projectId: '',
                    );
                    provider.addTask(newTask);
                    _taskController.clear();
                  },
                  child: Text('Add Task'),
                )
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.deleteTask(task.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}