import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];

  List<TimeEntry> get entries => _entries;

  TimeEntryProvider() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString('timeEntries');
    if (entriesString != null) {
      final entriesJson = jsonDecode(entriesString) as List;
      _entries = entriesJson.map((e) => TimeEntry.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('timeEntries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  Future<void> addTimeEntry(TimeEntry entry) async {
    _entries.add(entry);
    await saveEntries();
    notifyListeners();
  }

  Future<void> deleteTimeEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await saveEntries();
    notifyListeners();
  }
}