import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _keyFontScale = 'settings_font_scale';
  static const _keyLanguage = 'settings_language';
  static const _keySound = 'settings_sound_enabled';
  static const _keyVibrate = 'settings_vibrate_enabled';
  static const _keyTempUnit = 'settings_temp_unit';
  static const _keyDateTimeMode = 'settings_datetime_mode';
  static const _keyManual24h = 'settings_manual_24h';
  static const _keyManualDateOrder = 'settings_manual_date_order';

  static const List<double> fontScaleSteps = [0.85, 1.0, 1.15, 1.3];
  static const List<String> fontScaleLabels = ['Kecil', 'Normal', 'Besar', 'Sangat Besar'];

  double _fontScale = 1.0;
  String _language = 'id';
  bool _soundEnabled = true;
  bool _vibrateEnabled = true;
  String _tempUnit = 'c';
  String _dateTimeMode = 'auto';
  bool _manualUse24Hour = true;
  String _manualDateOrder = 'dmy';
  bool _loaded = false;

  double get fontScale => _fontScale;
  String get language => _language;
  bool get soundEnabled => _soundEnabled;
  bool get vibrateEnabled => _vibrateEnabled;
  String get tempUnit => _tempUnit;
  String get dateTimeMode => _dateTimeMode;
  bool get manualUse24Hour => _manualUse24Hour;
  String get manualDateOrder => _manualDateOrder;
  bool get isLoaded => _loaded;

  int get fontScaleIndex {
    var closestIndex = 1;
    var closestDiff = double.infinity;
    for (var i = 0; i < fontScaleSteps.length; i++) {
      final diff = (fontScaleSteps[i] - _fontScale).abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = prefs.getDouble(_keyFontScale) ?? 1.0;
    _language = prefs.getString(_keyLanguage) ?? 'id';
    _soundEnabled = prefs.getBool(_keySound) ?? true;
    _vibrateEnabled = prefs.getBool(_keyVibrate) ?? true;
    _tempUnit = prefs.getString(_keyTempUnit) ?? 'c';
    _dateTimeMode = prefs.getString(_keyDateTimeMode) ?? 'auto';
    _manualUse24Hour = prefs.getBool(_keyManual24h) ?? true;
    _manualDateOrder = prefs.getString(_keyManualDateOrder) ?? 'dmy';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setFontScale(double value) async {
    _fontScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontScale, value);
  }

  Future<void> setFontScaleIndex(int index) async {
    final clamped = index.clamp(0, fontScaleSteps.length - 1);
    await setFontScale(fontScaleSteps[clamped]);
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
    if (value) SystemSound.play(SystemSoundType.click);
  }

  Future<void> setVibrateEnabled(bool value) async {
    _vibrateEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrate, value);
    if (value) HapticFeedback.mediumImpact();
  }

  Future<void> setTempUnit(String value) async {
    _tempUnit = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTempUnit, value);
  }

  Future<void> setDateTimeMode(String value) async {
    _dateTimeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDateTimeMode, value);
  }

  Future<void> setManualUse24Hour(bool value) async {
    _manualUse24Hour = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyManual24h, value);
  }

  Future<void> setManualDateOrder(String value) async {
    _manualDateOrder = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyManualDateOrder, value);
  }

  void feedback() {
    if (_soundEnabled) SystemSound.play(SystemSoundType.click);
    if (_vibrateEnabled) HapticFeedback.lightImpact();
  }

  String get tempUnitSuffix => _tempUnit == 'f' ? '°F' : '°C';

  num celsiusToDisplay(num celsius) =>
      _tempUnit == 'f' ? (celsius * 9 / 5 + 32).round() : celsius;

  num displayToCelsius(num displayValue) =>
      _tempUnit == 'f' ? ((displayValue - 32) * 5 / 9).round() : displayValue;

  bool get _autoUse24Hour {
    final countryCode = ui.PlatformDispatcher.instance.locale.countryCode;
    return countryCode != 'US' && countryCode != 'PH';
  }

  String get _autoDateOrder {
    final countryCode = ui.PlatformDispatcher.instance.locale.countryCode;
    return countryCode == 'US' ? 'mdy' : 'dmy';
  }

  String formatDateTime(DateTime dt) {
    final use24Hour = _dateTimeMode == 'auto' ? _autoUse24Hour : _manualUse24Hour;
    final dateOrder = _dateTimeMode == 'auto' ? _autoDateOrder : _manualDateOrder;

    final hour24 = dt.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final hh = (use24Hour ? hour24 : hour12).toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = hour24 < 12 ? 'AM' : 'PM';
    final timeStr = use24Hour ? '$hh:$mm' : '$hh:$mm $ampm';

    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();

    late final String dateStr;
    switch (dateOrder) {
      case 'mdy':
        dateStr = '$mo/$d/$y';
        break;
      case 'ymd':
        dateStr = '$y-$mo-$d';
        break;
      default:
        dateStr = '$d/$mo/$y';
    }

    return '$dateStr  $timeStr';
  }
}