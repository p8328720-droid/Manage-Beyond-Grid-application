import 'package:flutter_application_1/services/app_settings.dart';

class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _dict = {
    'welcome': {'id': 'Selamat datang di MBG', 'en': 'Welcome to MBG'},
    'system_status': {'id': 'Status Sistem', 'en': 'System Status'},
    'manage_monitor': {'id': 'Kelola & Pantau', 'en': 'Manage & Monitor'},
    'cloud_sync': {'id': 'Cloud Synchronization', 'en': 'Cloud Synchronization'},
    'cloud_sync_sub': {
      'id': 'Sinkronisasi data perangkat otomatis',
      'en': 'Automatic device data synchronization',
    },
    'smart_alert': {'id': 'Smart Alert & Notification', 'en': 'Smart Alert & Notification'},
    'smart_alert_sub': {
      'id': 'Notifikasi kondisi penting secara real-time',
      'en': 'Real-time alerts for important conditions',
    },
    'dashboard': {'id': 'Smart Dashboard', 'en': 'Smart Dashboard'},
    'dashboard_sub': {
      'id': 'Semua status perangkat, satu layar',
      'en': 'All device status, one screen',
    },
    'remote_control': {'id': 'Remote Device Control', 'en': 'Remote Device Control'},
    'remote_control_sub': {
      'id': 'Kontrol perangkat dari mana saja',
      'en': 'Control devices from anywhere',
    },
    'ai_insights': {'id': 'AI Smart Insights', 'en': 'AI Smart Insights'},
    'ai_insights_sub': {
      'id': 'Deteksi & prediksi gangguan otomatis',
      'en': 'Automatic fault detection & prediction',
    },
    'analytics': {'id': 'Analytics & Reports', 'en': 'Analytics & Reports'},
    'analytics_sub': {
      'id': 'Grafik energi & riwayat aktivitas',
      'en': 'Energy graphs & activity history',
    },
    'nav_dashboard': {'id': 'Dashboard', 'en': 'Dashboard'},
    'nav_report': {'id': 'Laporan', 'en': 'Reports'},
    'nav_profile': {'id': 'Profil', 'en': 'Profile'},
    'settings_title': {'id': 'Settings', 'en': 'Settings'},
    'section_display': {'id': 'Tampilan', 'en': 'Display'},
    'section_notification': {'id': 'Notifikasi', 'en': 'Notifications'},
    'section_language': {'id': 'Bahasa', 'en': 'Language'},
    'section_units': {'id': 'Satuan', 'en': 'Units'},
    'section_datetime': {'id': 'Format Waktu & Tanggal', 'en': 'Date & Time Format'},
    'section_account': {'id': 'Akun', 'en': 'Account'},
    'font_size': {'id': 'Ukuran Teks', 'en': 'Text Size'},
    'sound': {'id': 'Suara', 'en': 'Sound'},
    'vibration': {'id': 'Getar', 'en': 'Vibration'},
    'temperature_unit': {'id': 'Satuan Suhu', 'en': 'Temperature Unit'},
    'datetime_mode': {'id': 'Mode', 'en': 'Mode'},
    'datetime_auto': {'id': 'Otomatis (ikuti region)', 'en': 'Automatic (follow region)'},
    'datetime_manual': {'id': 'Manual', 'en': 'Manual'},
    'time_format': {'id': 'Format Jam', 'en': 'Time Format'},
    'date_order': {'id': 'Urutan Tanggal', 'en': 'Date Order'},
    'delete_account': {'id': 'Hapus Akun', 'en': 'Delete Account'},
  };

  static String t(String key) {
    final entry = _dict[key];
    if (entry == null) return key;
    return entry[AppSettings.instance.language] ?? entry['id'] ?? key;
  }
}