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
  final TextEditingController _taskController = TextEditingController();
  String? _selectedProjectId;
  bool _showAddCard = false;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _toggleAddCard() {
    setState(() {
      _showAddCard = !_showAddCard;
    });
  }

  void _addTask(ProjectTaskProvider provider) {
    final taskName = _taskController.text.trim();
    if (taskName.isEmpty || _selectedProjectId == null) return;

    final newTask = Task(
      id: const Uuid().v4(),
      name: taskName,
      projectId: _selectedProjectId!,
    );
    provider.addTask(newTask);
    _taskController.clear();
    _selectedProjectId = null;
    _toggleAddCard();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);
    final tasks = provider.tasks;
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text('Manage Tasks', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAddCard,
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tasks.isEmpty)
                  const Text("No tasks yet.")
                else
                  ...tasks.map((task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(task.name, style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.deleteTask(task.id),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),

          // ADD TASK CARD
          if (_showAddCard)
            Container(
              color: Colors.black.withAlpha((0.5 * 255).toInt()),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Add Task",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _taskController,
                            decoration: const InputDecoration(
                              labelText: 'Task Name',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // Make label text blue
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 1), // Default state
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2), // When focused
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedProjectId,
                            decoration: const InputDecoration(
                              labelText: 'Select Project',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // Make label text blue
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 1), // Default state
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2), // When focused
                              ),
                            ),
                            items: projects.map((project) {
                              return DropdownMenuItem(
                                value: project.id,
                                child: Text(project.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedProjectId = val;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _toggleAddCard,
                                child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
                              ),
                              ElevatedButton(
                                onPressed: () => _addTask(provider),
                                child: const Text("Add", style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}