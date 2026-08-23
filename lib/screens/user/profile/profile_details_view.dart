import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/screens/user/profile/widgets/profile_sub_page_header.dart';

class ProfileDetailsView extends StatefulWidget {
  final VoidCallback onBack;

  const ProfileDetailsView({super.key, required this.onBack});

  @override
  State<ProfileDetailsView> createState() => _ProfileDetailsViewState();
}

class _ProfileDetailsViewState extends State<ProfileDetailsView> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  DateTime? _dateOfBirth;
  bool _saving = false;

  static const _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  AppUser? get _user => AuthService.instance.currentUser;

  @override
  void initState() {
    super.initState();
    final user = _user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dateOfBirth = user?.dateOfBirth;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}, ${date.year}';

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        dateOfBirth: _dateOfBirth,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      widget.onBack();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSubPageHeader(title: 'Profile details', onBack: widget.onBack),
          const SizedBox(height: 24),
          TextFormField(
            controller: _firstNameController,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(hintText: 'Nama depan'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _lastNameController,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(hintText: 'Nama belakang'),
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickDateOfBirth,
            child: InputDecorator(
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(
                _dateOfBirth != null
                    ? _formatDate(_dateOfBirth!)
                    : 'Tanggal lahir',
                style: TextStyle(
                  fontSize: 15,
                  color: _dateOfBirth != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(fontSize: 15),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'bagas@example.com'),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gunakan alamat email yang aktif',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(hintText: 'Nomor telepon'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Text('Simpan Perubahan'),
            ),
          ),
        ],
      ),
    );
  }
}
