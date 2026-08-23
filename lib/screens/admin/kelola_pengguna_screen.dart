import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/widgets/admin_widgets.dart';
import 'package:flutter_application_1/widgets/mbg_text_field.dart';

class KelolaPenggunaScreen extends StatefulWidget {
  static const routeName = '/admin-kelola-pengguna';

  const KelolaPenggunaScreen({super.key});

  @override
  State<KelolaPenggunaScreen> createState() => _KelolaPenggunaScreenState();
}

class _KelolaPenggunaScreenState extends State<KelolaPenggunaScreen> {
  final _searchController = TextEditingController();
  UserRole? _roleFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppUser> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    return AuthService.instance.allUsers.where((u) {
      final matchesQuery = query.isEmpty ||
          u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
      final matchesRole = _roleFilter == null || u.role == _roleFilter;
      return matchesQuery && matchesRole;
    }).toList();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
      ),
    );
  }

  Future<void> _openUserForm({AppUser? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final passwordController = TextEditingController();
    var role = existing?.role ?? UserRole.pengguna;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null ? 'Tambah Pengguna' : 'Edit Pengguna',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    MbgTextField(
                      controller: nameController,
                      label: 'Nama lengkap',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    MbgTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Email tidak valid'
                          : null,
                    ),
                    if (existing == null) ...[
                      const SizedBox(height: 12),
                      MbgTextField(
                        controller: passwordController,
                        label: 'Kata sandi awal',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Minimal 6 karakter'
                            : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    const AdminSectionLabel('Peran'),
                    const SizedBox(height: 10),
                    AdminChipGroup<UserRole>(
                      options: UserRole.values,
                      labels: UserRole.values.map((r) => r.label).toList(),
                      selected: role,
                      onSelected: (r) => setSheetState(() => role = r),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        try {
                          if (existing == null) {
                            AuthService.instance.adminCreateUser(
                              name: nameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              role: role,
                            );
                            _showMessage('Pengguna baru berhasil ditambahkan.');
                          } else {
                            AuthService.instance.adminUpdateUserRole(
                              userId: existing.id,
                              role: role,
                            );
                            _showMessage('Peran pengguna berhasil diperbarui.');
                          }
                          Navigator.of(sheetContext).pop();
                          setState(() {});
                        } on AuthException catch (e) {
                          _showMessage(e.message, isError: true);
                        }
                      },
                      child: Text(existing == null ? 'Simpan Pengguna' : 'Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus pengguna?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('${user.name} (${user.email}) akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      AuthService.instance.adminDeleteUser(user.id);
      _showMessage('Pengguna berhasil dihapus.');
      setState(() {});
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    }
  }

  Future<void> _resetPassword(AppUser user) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset kata sandi', style: TextStyle(fontWeight: FontWeight.w800)),
        content: MbgTextField(
          controller: controller,
          label: 'Kata sandi baru',
          icon: Icons.lock_reset_outlined,
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      AuthService.instance.adminResetPassword(userId: user.id, newPassword: controller.text);
      _showMessage('Kata sandi ${user.name} berhasil direset.');
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    }
  }

  void _toggleActive(AppUser user, bool value) {
    try {
      AuthService.instance.adminSetUserActive(userId: user.id, active: value);
      setState(() {});
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              AdminScreenHeader(
                title: 'Kelola Pengguna',
                onBack: () => Navigator.of(context).pop(),
                trailing: IconButton(
                  onPressed: () => _openUserForm(),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  color: AppColors.accentDim,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cari nama atau email',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RoleFilterChip(
                      label: 'Semua',
                      selected: _roleFilter == null,
                      onTap: () => setState(() => _roleFilter = null),
                    ),
                    ...UserRole.values.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _RoleFilterChip(
                          label: r.label,
                          selected: _roleFilter == r,
                          onTap: () => setState(() => _roleFilter = r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: users.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada pengguna yang cocok.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isSelf = AuthService.instance.currentUser?.id == user.id;
                          return _UserCard(
                            user: user,
                            isSelf: isSelf,
                            onEdit: () => _openUserForm(existing: user),
                            onDelete: () => _confirmDelete(user),
                            onResetPassword: () => _resetPassword(user),
                            onToggleActive: (v) => _toggleActive(user, v),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final bool isSelf;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onResetPassword;
  final ValueChanged<bool> onToggleActive;

  const _UserCard({
    required this.user,
    required this.isSelf,
    required this.onEdit,
    required this.onDelete,
    required this.onResetPassword,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(color: AppColors.accentDim, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Switch(
                value: user.isActive,
                onChanged: isSelf ? null : onToggleActive,
                activeColor: AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Badge(text: user.role.label),
              const SizedBox(width: 8),
              _Badge(
                text: user.isActive ? 'Aktif' : 'Nonaktif',
                color: user.isActive ? AppColors.success : AppColors.textMuted,
              ),
              const Spacer(),
              IconButton(
                onPressed: onResetPassword,
                icon: const Icon(Icons.lock_reset_outlined, size: 20),
                color: AppColors.textSecondary,
                tooltip: 'Reset kata sandi',
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.textSecondary,
                tooltip: 'Edit peran',
              ),
              IconButton(
                onPressed: isSelf ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: isSelf ? AppColors.textMuted : AppColors.danger,
                tooltip: 'Hapus',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color? color;

  const _Badge({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accentDim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
