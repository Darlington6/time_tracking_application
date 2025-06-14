import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/task.dart';

class ProjectTaskProvider with ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  ProjectTaskProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final projectsString = prefs.getString('projects');
    if (projectsString != null) {
      final projectsJson = jsonDecode(projectsString) as List;
      _projects = projectsJson.map((e) => Project.fromJson(e)).toList();
    }

    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final tasksJson = jsonDecode(tasksString) as List;
      _tasks = tasksJson.map((e) => Task.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('projects', jsonEncode(_projects.map((e) => e.toJson()).toList()));
    prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  Future<void> addProject(Project project) async {
    _projects.add(project);
    await saveData();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await saveData();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await saveData();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await saveData();
    notifyListeners();
  }
}