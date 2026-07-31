import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audit_log_service.dart';
import 'auth_service.dart';

class SystemConfigService extends ChangeNotifier {
  SystemConfigService._();
  static final SystemConfigService instance = SystemConfigService._();

  static const _keyAppName = 'sysconf_app_name';
  static const _keyMaintenance = 'sysconf_maintenance_mode';
  static const _keyAllowRegistration = 'sysconf_allow_registration';
  static const _keyMaxDevices = 'sysconf_max_devices_per_user';
  static const _keySessionTimeout = 'sysconf_session_timeout_minutes';
  static const _keyAlertNotif = 'sysconf_alert_notifications';
  static const _keyAutoBackup = 'sysconf_auto_backup_enabled';
  static const _keyBackupFreq = 'sysconf_backup_frequency_days';
  static const _keyLastBackup = 'sysconf_last_backup_at';

  static const List<int> sessionTimeoutOptions = [15, 30, 60, 120];
  static const List<int> backupFrequencyOptions = [1, 7, 30];

  String _appName = 'MBG - Manage Beyond Grid';
  bool _maintenanceMode = false;
  bool _allowRegistration = true;
  int _maxDevicesPerUser = 8;
  int _sessionTimeoutMinutes = 30;
  bool _alertNotificationsEnabled = true;
  bool _autoBackupEnabled = true;
  int _backupFrequencyDays = 7;
  DateTime? _lastBackupAt;
  bool _loaded = false;

  String get appName => _appName;
  bool get maintenanceMode => _maintenanceMode;
  bool get allowRegistration => _allowRegistration;
  int get maxDevicesPerUser => _maxDevicesPerUser;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;
  bool get alertNotificationsEnabled => _alertNotificationsEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  int get backupFrequencyDays => _backupFrequencyDays;
  DateTime? get lastBackupAt => _lastBackupAt;
  bool get isLoaded => _loaded;

  String get _actor => AuthService.instance.currentUser?.name ?? 'Administrator';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _appName = prefs.getString(_keyAppName) ?? _appName;
    _maintenanceMode = prefs.getBool(_keyMaintenance) ?? false;
    _allowRegistration = prefs.getBool(_keyAllowRegistration) ?? true;
    _maxDevicesPerUser = prefs.getInt(_keyMaxDevices) ?? 8;
    _sessionTimeoutMinutes = prefs.getInt(_keySessionTimeout) ?? 30;
    _alertNotificationsEnabled = prefs.getBool(_keyAlertNotif) ?? true;
    _autoBackupEnabled = prefs.getBool(_keyAutoBackup) ?? true;
    _backupFrequencyDays = prefs.getInt(_keyBackupFreq) ?? 7;
    final lastBackupIso = prefs.getString(_keyLastBackup);
    _lastBackupAt = lastBackupIso == null ? null : DateTime.tryParse(lastBackupIso);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAppName(String value) async {
    if (value.trim().isEmpty) return;
    _appName = value.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppName, _appName);
    _logChange('Nama aplikasi', _appName);
  }

  Future<void> setMaintenanceMode(bool value) async {
    _maintenanceMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMaintenance, value);
    _logChange('Mode pemeliharaan', value ? 'diaktifkan' : 'dinonaktifkan');
  }

  Future<void> setAllowRegistration(bool value) async {
    _allowRegistration = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAllowRegistration, value);
    _logChange('Pendaftaran pengguna baru', value ? 'diizinkan' : 'ditutup');
  }

  Future<void> setMaxDevicesPerUser(int value) async {
    _maxDevicesPerUser = value.clamp(1, 20).toInt();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxDevices, _maxDevicesPerUser);
    _logChange('Batas perangkat per pengguna', '$_maxDevicesPerUser perangkat');
  }

  Future<void> setSessionTimeoutMinutes(int value) async {
    _sessionTimeoutMinutes = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySessionTimeout, value);
    _logChange('Batas waktu sesi', '$value menit');
  }

  Future<void> setAlertNotificationsEnabled(bool value) async {
    _alertNotificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlertNotif, value);
    _logChange('Notifikasi peringatan sistem', value ? 'diaktifkan' : 'dinonaktifkan');
  }

  Future<void> setAutoBackupEnabled(bool value) async {
    _autoBackupEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackup, value);
    _logChange('Backup otomatis', value ? 'diaktifkan' : 'dinonaktifkan');
  }

  Future<void> setBackupFrequencyDays(int value) async {
    _backupFrequencyDays = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBackupFreq, value);
    _logChange('Frekuensi backup', 'setiap $value hari');
  }

  Future<void> runBackupNow() async {
    _lastBackupAt = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBackup, _lastBackupAt!.toIso8601String());
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.konfigurasi,
      action: 'Menjalankan backup manual',
      detail: 'Backup sistem selesai dijalankan.',
    );
  }

  void _logChange(String field, String value) {
    AuditLogService.instance.log(
      actor: _actor,
      category: AuditCategory.konfigurasi,
      action: 'Mengubah konfigurasi sistem',
      detail: '$field diubah menjadi $value.',
    );
  }
}
