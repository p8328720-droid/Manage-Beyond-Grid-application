import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';

class AdminScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  const AdminScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AdminSectionLabel extends StatelessWidget {
  final String text;

  const AdminSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        letterSpacing: 0.6,
      ),
    );
  }
}

class AdminTileShell extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final Color? iconColor;

  const AdminTileShell({
    super.key,
    required this.icon,
    required this.child,
    this.iconColor,
  });

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
              child: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AdminSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AdminSwitchTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdminTileShell(
      icon: icon,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.accent),
        ],
      ),
    );
  }
}

class AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;

  const AdminActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing! else if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminChipGroup<T> extends StatelessWidget {
  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;

  const AdminChipGroup({
    super.key,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                labels[i],
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
    );
  }
}

class AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accentColor;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.accentDim;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AdminProgressBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const AdminProgressBar({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              '${percent.round()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(height: 10, color: AppColors.border),
                  Container(
                    height: 10,
                    width: constraints.maxWidth * (percent.clamp(0, 100) / 100),
                    color: color,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class AdminHistoryBars extends StatelessWidget {
  final List<double> values;
  final Color color;

  const AdminHistoryBars({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              height: (v.clamp(0, 100) / 100) * 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
