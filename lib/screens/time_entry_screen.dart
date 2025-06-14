import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_task_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  AddTimeEntryScreenState createState() => AddTimeEntryScreenState();
}

class AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectTaskProvider>(context);
    final projects = projectProvider.projects;
    projectProvider.tasks.where((t) => t.id == taskId || taskId == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Time Entry'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: projectId,
                hint: Text('Select Project'),
                items: projects.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text(p.name));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    projectId = value;
                    taskId = null; // reset task when project changes
                  });
                },
                validator: (value) => value == null ? 'Please select a project' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: taskId,
                hint: Text('Select Task'),
                items: projectId == null
                    ? []
                    : projectProvider.tasks.map((t) {
                        return DropdownMenuItem(value: t.id, child: Text(t.name));
                      }).toList(),
                onChanged: (value) {
                  setState(() {
                    taskId = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a task' : null,
              ),

              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Date: ${date.toLocal().toString().split(' ')[0]}')),
                  TextButton(
                    onPressed: _selectDate,
                    child: Text('Select Date'),
                  )
                ],
              ),
              
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Total Time (hours)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (val) {
                  totalTime = double.tryParse(val ?? '0') ?? 0;
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter total time';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  if (double.parse(val) <= 0) return 'Time must be positive';
                  return null;
                },
              ),

              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onSaved: (val) {
                  notes = val ?? '';
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newEntry = TimeEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: projectId!,
                      taskId: taskId!,
                      totalTime: totalTime,
                      date: date,
                      notes: notes,
                    );
                    Provider.of<TimeEntryProvider>(context, listen: false).addTimeEntry(newEntry);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Entry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}