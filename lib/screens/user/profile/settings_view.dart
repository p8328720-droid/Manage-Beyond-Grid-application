import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/app_settings.dart';
import 'package:flutter_application_1/services/app_strings.dart';
import 'package:flutter_application_1/screens/user/profile/widgets/profile_sub_page_header.dart';

class SettingsView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onAccountDeleted;

  const SettingsView({
    super.key,
    required this.onBack,
    required this.onAccountDeleted,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hapus akun?',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        content: Text(
          'Tindakan ini permanen. Semua data akun Anda akan dihapus dan '
          'Anda akan keluar dari aplikasi.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await AuthService.instance.deleteAccount();
    if (!mounted) return;
    widget.onAccountDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSubPageHeader(title: AppStrings.t('settings_title'), onBack: widget.onBack),
              const SizedBox(height: 24),

              _SectionLabel(AppStrings.t('section_display')),
              const SizedBox(height: 10),
              _FontSizeTile(
                selectedIndex: settings.fontScaleIndex,
                onSelected: (i) => settings.setFontScaleIndex(i),
              ),
              const SizedBox(height: 24),

              _SectionLabel(AppStrings.t('section_notification')),
              const SizedBox(height: 10),
              _SwitchTile(
                icon: Icons.volume_up_rounded,
                label: AppStrings.t('sound'),
                value: settings.soundEnabled,
                onChanged: (v) => settings.setSoundEnabled(v),
              ),
              const SizedBox(height: 10),
              _SwitchTile(
                icon: Icons.vibration_rounded,
                label: AppStrings.t('vibration'),
                value: settings.vibrateEnabled,
                onChanged: (v) => settings.setVibrateEnabled(v),
              ),
              const SizedBox(height: 24),

              _SectionLabel(AppStrings.t('section_language')),
              const SizedBox(height: 10),
              _OptionRowTile(
                icon: Icons.language_rounded,
                options: const ['id', 'en'],
                optionLabels: const ['Indonesia', 'English'],
                selected: settings.language,
                onSelected: (v) => settings.setLanguage(v),
              ),
              const SizedBox(height: 24),

              _SectionLabel(AppStrings.t('section_units')),
              const SizedBox(height: 10),
              _OptionRowTile(
                icon: Icons.thermostat_rounded,
                label: AppStrings.t('temperature_unit'),
                options: const ['c', 'f'],
                optionLabels: const ['Celsius (°C)', 'Fahrenheit (°F)'],
                selected: settings.tempUnit,
                onSelected: (v) => settings.setTempUnit(v),
              ),
              const SizedBox(height: 24),

              _SectionLabel(AppStrings.t('section_datetime')),
              const SizedBox(height: 10),
              _DateTimeTile(settings: settings),
              const SizedBox(height: 24),

              _SectionLabel(AppStrings.t('section_account')),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                label: AppStrings.t('delete_account'),
                onTap: _confirmDeleteAccount,
                destructive: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _TileShell extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _TileShell({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      icon: icon,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _FontSizeTile extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FontSizeTile({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      icon: Icons.text_fields_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t('font_size'),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(AppSettings.fontScaleLabels.length, (i) {
              final active = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: i == AppSettings.fontScaleLabels.length - 1 ? 0 : 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppSettings.fontScaleLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OptionRowTile extends StatelessWidget {
  final IconData icon;
  final String? label;
  final List<String> options;
  final List<String> optionLabels;
  final String selected;
  final ValueChanged<String> onSelected;

  const _OptionRowTile({
    required this.icon,
    this.label,
    required this.options,
    required this.optionLabels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _TileShell(
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: List.generate(options.length, (i) {
              final active = options[i] == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(options[i]),
                  child: Container(
                    margin: EdgeInsets.only(right: i == options.length - 1 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      optionLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final AppSettings settings;

  const _DateTimeTile({required this.settings});

  @override
  Widget build(BuildContext context) {
    final isAuto = settings.dateTimeMode == 'auto';

    return _TileShell(
      icon: Icons.schedule_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settings.formatDateTime(DateTime.now()),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => settings.setDateTimeMode('auto'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isAuto ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppStrings.t('datetime_auto'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isAuto ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => settings.setDateTimeMode('manual'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isAuto ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      AppStrings.t('datetime_manual'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !isAuto ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isAuto) ...[
            const SizedBox(height: 16),
            Text(
              AppStrings.t('time_format'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => settings.setManualUse24Hour(true),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: settings.manualUse24Hour ? AppColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '24 Jam',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: settings.manualUse24Hour
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => settings.setManualUse24Hour(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !settings.manualUse24Hour ? AppColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '12 Jam (AM/PM)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !settings.manualUse24Hour
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('date_order'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _DateOrderChip(
                  label: 'DD/MM/YYYY',
                  value: 'dmy',
                  selected: settings.manualDateOrder,
                  onTap: settings.setManualDateOrder,
                ),
                const SizedBox(width: 8),
                _DateOrderChip(
                  label: 'MM/DD/YYYY',
                  value: 'mdy',
                  selected: settings.manualDateOrder,
                  onTap: settings.setManualDateOrder,
                ),
                const SizedBox(width: 8),
                _DateOrderChip(
                  label: 'YYYY-MM-DD',
                  value: 'ymd',
                  selected: settings.manualDateOrder,
                  onTap: settings.setManualDateOrder,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DateOrderChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _DateOrderChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.textPrimary;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (!destructive)
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}