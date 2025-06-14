import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../providers/project_task_provider.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  final _projectController = TextEditingController();

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: Text('Manage Projects', style: TextStyle(color: Colors.white),)
        ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _projectController,
                    decoration: InputDecoration(labelText: 'Project Name'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_projectController.text.trim().isEmpty) return;
                    final newProject = Project(
                      id: Uuid().v4(),
                      name: _projectController.text.trim(),
                    );
                    provider.addProject(newProject);
                    _projectController.clear();
                  },
                  child: Text('Add Project'),
                )
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ListTile(
                    title: Text(project.name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.deleteProject(project.id),
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