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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Time Tracking', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'All Entries'),
              Tab(text: 'Grouped by Projects'),
            ],
          ),
        ),
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.teal),
                child: SizedBox(
                  width: double.infinity,
                  child: Text('Menu', style: TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.center,),
                  ),
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text('Projects'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProjectManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Tasks'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskManagementScreen()),
                  );
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
              children: [
                // Tab 1: All Entries
                entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No time entries yet!',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Tap the + button to add your first entry.'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 2,
                            child: ListTile(
                              title: Text('${entry.projectId} - ${entry.totalTime} hours'),
                              subtitle: Text(
                                '${entry.date.toLocal().toString().split(' ')[0]} - Notes: ${entry.notes}',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => provider.deleteTimeEntry(entry.id),
                              ),
                            ),
                          );
                        },
                      ),

                // Tab 2: Grouped by Projects
                grouped.isEmpty
                    ? Center(
                        child: Text('No entries to group by project yet.'),
                      )
                    : ListView(
                        children: grouped.entries.map((group) {
                          return ExpansionTile(
                            title: Text(group.key),
                            children: group.value.map((entry) {
                              return ListTile(
                                title: Text('${entry.taskId} - ${entry.totalTime} hours'),
                                subtitle: Text(
                                  '${entry.date.toLocal().toString().split(' ')[0]} - Notes: ${entry.notes}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
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
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
            );
          },
          backgroundColor: Colors.orangeAccent,
          tooltip: 'Add Time Entry',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}