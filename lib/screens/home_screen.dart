import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';
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
      setState(() {}); // Rebuild when tab changes
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
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.teal),
                child: const SizedBox(
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
        body: Consumer<TimeEntryProvider>(
          builder: (context, provider, child) {
            final entries = provider.entries;
            final grouped = groupEntriesByProject(entries);

            return TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Prevent swipe, tab changes via custom tabs only
              children: [
                entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              title: Text('${entry.projectId} - ${entry.totalTime} hours'),
                              subtitle: Text('${entry.date.toLocal().toString().split(' ')[0]} - Notes: ${entry.notes}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => provider.deleteTimeEntry(entry.id),
                              ),
                            ),
                          );
                        },
                      ),
                grouped.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        children: grouped.entries.map((group) {
                          return ExpansionTile(
                            title: Text(group.key),
                            children: group.value.map((entry) {
                              return ListTile(
                                title: Text('${entry.taskId} - ${entry.totalTime} hours'),
                                subtitle: Text('${entry.date.toLocal().toString().split(' ')[0]} - Notes: ${entry.notes}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => provider.deleteTimeEntry(entry.id),
                                ),
                              );
                            }).toList(),
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
          child: const Icon(Icons.add, color: Colors.white,),
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
}