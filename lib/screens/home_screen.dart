import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/time_entry_provider.dart';
import '../providers/project_task_provider.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';
import 'time_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isHoveringAllEntries = false;
  bool _isHoveringGroupedProjects = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<TimeEntry>> groupEntriesByProject(List<TimeEntry> entries) {
    Map<String, List<TimeEntry>> map = {};
    for (var entry in entries) {
      map.putIfAbsent(entry.projectId, () => []).add(entry);
    }
    return map;
  }

  Project? findProjectById(List<Project> projects, String id) {
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Task? findTaskById(List<Task> tasks, String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildCustomTab({
    required String label,
    required int index,
    required bool isHovering,
    required void Function(bool) onHoverChanged,
  }) {
    final isSelected = _tabController.index == index;

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.index = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isHovering || isSelected ? Colors.orange : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isHovering || isSelected ? Colors.white : const Color.fromRGBO(51, 51, 51, 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Time Tracking', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCustomTab(
                  label: 'All Entries',
                  index: 0,
                  isHovering: _isHoveringAllEntries,
                  onHoverChanged: (hovering) => setState(() => _isHoveringAllEntries = hovering),
                ),
                _buildCustomTab(
                  label: 'Grouped by Projects',
                  index: 1,
                  isHovering: _isHoveringGroupedProjects,
                  onHoverChanged: (hovering) => setState(() => _isHoveringGroupedProjects = hovering),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal),
                child: SizedBox(
                  width: double.infinity,
                  child: Text('Menu', style: TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.center),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Projects'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectManagementScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment),
                title: const Text('Tasks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TaskManagementScreen()));
                },
              ),
            ],
          ),
        ),
        body: Consumer2<TimeEntryProvider, ProjectTaskProvider>(
          builder: (context, timeEntryProvider, projectTaskProvider, _) {
            final entries = timeEntryProvider.entries;
            final grouped = groupEntriesByProject(entries);

            return TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // All Entries
                entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final project = findProjectById(projectTaskProvider.projects, entry.projectId);
                          final task = findTaskById(projectTaskProvider.tasks, entry.taskId);
                          final projectName = project?.name ?? 'Unknown Project';
                          final taskName = task?.name ?? 'Unknown Task';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                '$projectName - $taskName',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Time: ${entry.totalTime} hours'),
                                  Text('Date: ${_formatDate(entry.date)}'),
                                  Text('Notes: ${entry.notes}'),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => timeEntryProvider.deleteTimeEntry(entry.id),
                              ),
                            ),
                          );
                        },
                      ),
                // Grouped by Projects
                grouped.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        children: grouped.entries.map((group) {
                          final project = findProjectById(projectTaskProvider.projects, group.key);
                          final projectName = project?.name ?? 'Unknown Project';
                          final entries = group.value;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    projectName,
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...entries.map((entry) {
                                    final task = findTaskById(projectTaskProvider.tasks, entry.taskId);
                                    final taskName = task?.name ?? 'Unknown Task';
                                    final formattedDate = _formatDate(entry.date);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '- $taskName: ${entry.totalTime} hours ($formattedDate)',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => timeEntryProvider.deleteTimeEntry(entry.id),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTimeEntryScreen()));
          },
          backgroundColor: Colors.orangeAccent,
          tooltip: 'Add Time Entry',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No time entries yet!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Tap the + button to add your first entry.'),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}