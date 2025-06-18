import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedProjectId;
  String? selectedTaskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);
    final projects = projectProvider.projects;
    final tasks = projectProvider.tasks
        .where((task) => task.projectId == selectedProjectId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Add Time Entry', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (selectedProjectId == null) ...[
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: projects.map((project) {
                        return ListTile(
                          title: Text(project.name),
                          onTap: () {
                            setState(() {
                              selectedProjectId = project.id;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else if (selectedTaskId == null) ...[
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          projectProvider.projects.firstWhere((p) => p.id == selectedProjectId).name,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        ...tasks.map((task) {
                          return ListTile(
                            title: Text(task.name),
                            onTap: () {
                              setState(() {
                                selectedTaskId = task.id;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],

              if (selectedProjectId != null && selectedTaskId != null) ...[
                const SizedBox(height: 8),
                const Text('Project', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  projectProvider.projects.firstWhere((p) => p.id == selectedProjectId).name,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text('Task', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  tasks.firstWhere((t) => t.id == selectedTaskId).name,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
              ],

              // Always-visible form fields
              Text('Date: ${date.toLocal().toString().split(' ')[0]}', style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectDate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      foregroundColor: Colors.blue, // Text color
                    ),
                    child: const Text('Select Date',),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total Time (in hours)',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Default state
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1), // When focused
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) => totalTime = double.tryParse(val ?? '0') ?? 0,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter total time';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  if (double.parse(val) <= 0) return 'Time must be positive';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Default state
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1), // When focused
                  ),
                ),
                maxLines: 1,
                onSaved: (val) => notes = val ?? '',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _saveEntry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      foregroundColor: Colors.blue, // Text color
                    ),
                    child: const Text('Save Time Entry'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != date) {
      setState(() => date = picked);
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: selectedProjectId!,
        taskId: selectedTaskId!,
        totalTime: totalTime,
        date: date,
        notes: notes,
      );
      Provider.of<TimeEntryProvider>(context, listen: false).addTimeEntry(newEntry);
      Navigator.pop(context);
    }
  }
}