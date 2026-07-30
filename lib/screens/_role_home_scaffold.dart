import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/brand_widgets.dart';
import 'package:flutter_application_1/widgets/grid_motifs.dart';

/// A single tappable menu entry shown on a role's home dashboard.
class RoleMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const RoleMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// Shared "home dashboard" shell reused by Administrator, Pengguna, and
/// Teknisi home screens. Keeps the header, greeting, logout affordance, and
/// menu grid consistent across roles while each screen only supplies its own
/// [roleLabel] and [menuItems].
class RoleHomeScaffold extends StatelessWidget {
  final String roleLabel;
  final String welcomeName;
  final List<RoleMenuItem> menuItems;
  final VoidCallback onLogout;

  const RoleHomeScaffold({
    super.key,
    required this.roleLabel,
    required this.welcomeName,
    required this.menuItems,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              roleLabel: roleLabel,
              welcomeName: welcomeName,
              onLogout: onLogout,
            ),
            Expanded(
              child: menuItems.isEmpty
                  ? const _EmptyMenuState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      itemCount: menuItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return _MenuCard(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String roleLabel;
  final String welcomeName;
  final VoidCallback onLogout;

  const _Header({
    required this.roleLabel,
    required this.welcomeName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        color: AppColors.night,
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 26),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CircuitGridBackground(opacity: 0.10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandIcon(size: 40),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'MBG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onLogout,
                      tooltip: 'Keluar',
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Selamat datang, $welcomeName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final RoleMenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.label} — segera hadir')),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.accentDim, size: 24),
              ),
              Text(
                item.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Belum ada menu tersedia.',
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}