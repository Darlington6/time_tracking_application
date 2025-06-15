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
  final TextEditingController _projectController = TextEditingController();
  bool _showAddCard = false;

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }

  void _toggleAddCard() {
    setState(() {
      _showAddCard = !_showAddCard;
    });
  }

  void _addProject(ProjectTaskProvider provider) {
    final name = _projectController.text.trim();
    if (name.isEmpty) return;

    final newProject = Project(id: const Uuid().v4(), name: name);
    provider.addProject(newProject);
    _projectController.clear();
    _toggleAddCard();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectTaskProvider>(context);
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text('Manage Projects', style: TextStyle(color: Colors.white)),
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
                if (projects.isEmpty)
                  const Text("No projects yet.")
                else
                  ...projects.map((project) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(project.name, style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.deleteProject(project.id),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),

          // ADD PROJECT CARD
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
                          const Text("Add Project",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _projectController,
                            decoration: const InputDecoration(
                              labelText: 'Project Name',
                              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // Make label text blue
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 1), // Default state
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2), // When focused
                              ),
                            ),
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
                                onPressed: () => _addProject(provider),
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