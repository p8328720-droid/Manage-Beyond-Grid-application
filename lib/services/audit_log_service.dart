import 'package:flutter/foundation.dart';

enum AuditCategory { pengguna, konfigurasi, sistem, autentikasi }

class AuditLogEntry {
  final DateTime time;
  final String actor;
  final AuditCategory category;
  final String action;
  final String detail;

  const AuditLogEntry({
    required this.time,
    required this.actor,
    required this.category,
    required this.action,
    required this.detail,
  });
}

class AuditLogService extends ChangeNotifier {
  AuditLogService._internal() {
    _entries.add(
      AuditLogEntry(
        time: DateTime.now(),
        actor: 'Sistem',
        category: AuditCategory.sistem,
        action: 'Aplikasi dimulai',
        detail: 'Sesi monitoring dan konfigurasi siap digunakan.',
      ),
    );
  }
  static final AuditLogService instance = AuditLogService._internal();

  static const int maxEntries = 300;

  final List<AuditLogEntry> _entries = [];

  List<AuditLogEntry> get entries => List.unmodifiable(_entries);

  int get totalCount => _entries.length;

  int get todayCount {
    final now = DateTime.now();
    return _entries
        .where((e) =>
            e.time.year == now.year &&
            e.time.month == now.month &&
            e.time.day == now.day)
        .length;
  }

  List<AuditLogEntry> byCategory(AuditCategory? category) {
    if (category == null) return entries;
    return _entries.where((e) => e.category == category).toList();
  }

  void log({
    required String actor,
    required AuditCategory category,
    required String action,
    required String detail,
  }) {
    _entries.insert(
      0,
      AuditLogEntry(
        time: DateTime.now(),
        actor: actor,
        category: category,
        action: action,
        detail: detail,
      ),
    );
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    notifyListeners();
  }
}
