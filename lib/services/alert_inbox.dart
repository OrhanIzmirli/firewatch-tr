import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A bounded on-device history of alerts actually received by this app.
class AlertInbox {
  AlertInbox._();
  static final instance = AlertInbox._();
  final entries = ValueNotifier<List<Map<String, dynamic>>>([]);
  Future<void>? _initializing;
  Future<void> initialize() => _initializing ??= _load();
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      entries.value = (jsonDecode(prefs.getString('alert_inbox') ?? '[]') as List)
          .map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) { entries.value = []; }
  }
  Future<void> add(String title, String body, {String? payload, String? id}) async {
    await initialize();
    final key = id ?? '${DateTime.now().microsecondsSinceEpoch}';
    if (entries.value.any((e) => e['id'] == key)) return;
    entries.value = [{'id': key, 'title': title, 'body': body,
      'payload': payload, 'date': DateTime.now().toIso8601String(), 'read': false},
      ...entries.value].take(100).toList();
    await _save();
  }
  Future<void> markRead(String id) async {
    await initialize();
    entries.value = entries.value.map((e) => e['id'] == id ? {...e, 'read': true} : e).toList();
    await _save();
  }
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alert_inbox', jsonEncode(entries.value));
  }
}
