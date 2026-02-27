import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';

/// Manages real search/recommendation history via SharedPreferences.
class HistoryProvider extends ChangeNotifier {
  static const _storageKey = 'recommendation_history';
  static const _maxEntries = 50;

  List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  int get count => _entries.length;

  /// Load saved history from disk.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _entries = list
            .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        // Sort newest first
        _entries.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      } catch (e) {
        debugPrint('History load error: $e');
      }
    }
  }

  /// Add a new recommendation to history.
  Future<void> addEntry(HistoryEntry entry) async {
    // Remove duplicate if same crop + location on same day
    _entries.removeWhere(
      (e) =>
          e.cropName == entry.cropName &&
          e.location == entry.location &&
          e.date.day == entry.date.day &&
          e.date.month == entry.date.month &&
          e.date.year == entry.date.year,
    );

    _entries.insert(0, entry); // newest first

    // Cap at max entries
    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }

    notifyListeners();
    await _save();
  }

  /// Clear all history.
  Future<void> clearAll() async {
    _entries.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Delete a single entry by ID.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  /// Persist to SharedPreferences.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }
}
