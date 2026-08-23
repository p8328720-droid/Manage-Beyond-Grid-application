import '../models/app_user.dart';
import 'audit_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._internal() {
    _initSupabaseListener();
  }
  static final AuthService instance = AuthService._internal();

  // Subscribe to Supabase auth state when initialized
  void _initSupabaseListener() {
    if (!SupabaseService.isInitialized) return;

    try {
      // populate initial session
      final supaUser = Supabase.instance.client.auth.currentUser;
      if (supaUser != null) {
        _loadUserFromSupabaseUser(supaUser);
      }

      // listen to auth changes
      Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        final user = event.session?.user;
        if (user != null) {
          _loadUserFromSupabaseUser(user);
        } else {
          _currentUser = null;
        }
      });
    } catch (_) {
      // ignore if Supabase not ready
    }
  }

  Future<void> _loadUserFromSupabaseUser(User user) async {
    try {
      final profileRes = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      Map<String, dynamic>? profile;
      if (profileRes is Map<String, dynamic>) profile = profileRes;

      final appUser = AppUser(
        id: user.id,
        name: profile?['name'] ?? user.email ?? 'Pengguna',
        email: user.email ?? '',
        phone: profile?['phone'] ?? '',
        role: profile != null
            ? UserRoleX.fromApiValue(profile['role'] ?? '')
            : UserRole.pengguna,
        isActive: profile?['is_active'] ?? true,
        createdAt: profile != null && profile['created_at'] != null
            ? DateTime.tryParse(profile['created_at'])
            : null,
      );
      _currentUser = appUser;
    } catch (e) {
      // ignore mapping errors
    }
  }

  static const String _demoResetCode = '123456';

  static final List<_DemoAccount> _demoAccounts = [
    _DemoAccount(
      email: 'admin@mbg.io',
      password: 'admin123',
      user: AppUser(
        id: 'u-001',
        name: 'Admin MBG',
        email: 'admin@mbg.io',
        role: UserRole.administrator,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
    ),
    _DemoAccount(
      email: 'user@mbg.io',
      password: 'user123',
      user: AppUser(
        id: 'u-002',
        name: 'Pengguna MBG',
        email: 'user@mbg.io',
        role: UserRole.pengguna,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ),
    _DemoAccount(
      email: 'teknisi@mbg.io',
      password: 'teknisi123',
      user: AppUser(
        id: 'u-003',
        name: 'Teknisi MBG',
        email: 'teknisi@mbg.io',
        role: UserRole.teknisi,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ),
  ];

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  String? _pendingResetEmail;
  bool _justResetPassword = false;

  Future<AppUser> register({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().length < 5) {
      throw const AuthException('Nama lengkap minimal 5 karakter.');
    }
    if (username.trim().isEmpty || phone.trim().isEmpty) {
      throw const AuthException('Username dan nomor telepon wajib diisi.');
    }
    if (!email.contains('@')) {
      throw const AuthException('Format email tidak valid.');
    }
    if (password != confirmPassword) {
      throw const AuthException('Password dan konfirmasi password harus sama.');
    }

    // Try Supabase sign up if initialized
    if (SupabaseService.isInitialized) {
      final res = await Supabase.instance.client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException('Gagal mendaftar menggunakan Supabase.');
      }

      // Insert profile into "profiles" table
      final profile = {
        'id': user.id,
        'name': name.trim(),
        'username': username.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'role': 'pengguna',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      // insert profile (modern supabase client resolves when awaited)
      await Supabase.instance.client.from('profiles').insert(profile).select();

      final appUser = AppUser(
        id: user.id,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: UserRole.pengguna,
        createdAt: DateTime.now(),
      );
      _currentUser = appUser;
      return appUser;
    }

    // Fallback: in-memory demo
    await Future.delayed(const Duration(milliseconds: 700));

    final alreadyExists = _demoAccounts.any(
      (account) => account.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (alreadyExists) {
      throw const AuthException('Email sudah terdaftar.');
    }
    final usernameExists = _demoAccounts.any(
      (account) =>
          account.username.toLowerCase() == username.trim().toLowerCase(),
    );
    if (usernameExists) {
      throw const AuthException('Username sudah digunakan.');
    }

    final newUser = AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: UserRole.pengguna,
    );
    _demoAccounts.add(
      _DemoAccount(
        email: email.trim(),
        username: username.trim(),
        phone: phone.trim(),
        password: password,
        user: newUser,
      ),
    );
    _currentUser = newUser;
    return newUser;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    // If Supabase configured, use it
    if (SupabaseService.isInitialized) {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException('Email atau kata sandi salah.');
      }

      // fetch profile
      final profileRes = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      Map<String, dynamic>? profile;
      if (profileRes is Map<String, dynamic>) profile = profileRes;

      final appUser = AppUser(
        id: user.id,
        name: profile?['name'] ?? user.email ?? 'Pengguna',
        email: user.email ?? email.trim(),
        role: profile != null
            ? UserRoleX.fromApiValue(profile['role'] ?? '')
            : UserRole.pengguna,
        isActive: profile?['is_active'] ?? true,
        createdAt: profile != null && profile['created_at'] != null
            ? DateTime.tryParse(profile['created_at'])
            : null,
      );

      if (!appUser.isActive) {
        throw const AuthException(
          'Akun ini telah dinonaktifkan oleh administrator.',
        );
      }

      _currentUser = appUser;
      AuditLogService.instance.log(
        actor: appUser.name,
        category: AuditCategory.autentikasi,
        action: 'Masuk ke aplikasi',
        detail: '${appUser.email} (${appUser.role.label}) berhasil masuk.',
      );
      return _currentUser!;
    }

    // Fallback: demo
    await Future.delayed(const Duration(milliseconds: 700));

    final matches = _demoAccounts.where(
      (account) =>
          account.email.toLowerCase() == email.trim().toLowerCase() &&
          account.password == password,
    );

    if (matches.isEmpty) {
      throw const AuthException('Email atau kata sandi salah.');
    }

    final matchedUser = matches.first.user;
    if (!matchedUser.isActive) {
      throw const AuthException(
        'Akun ini telah dinonaktifkan oleh administrator.',
      );
    }

    _currentUser = matchedUser;
    AuditLogService.instance.log(
      actor: matchedUser.name,
      category: AuditCategory.autentikasi,
      action: 'Masuk ke aplikasi',
      detail:
          '${matchedUser.email} (${matchedUser.role.label}) berhasil masuk.',
    );
    return _currentUser!;
  }

  // Social sign-in
  Future<AppUser> loginWithGoogle() async {
    // Use Supabase OAuth if available
    if (SupabaseService.isInitialized) {
      await Supabase.instance.client.auth.signInWithOAuth(Provider.google);
      // The OAuth flow will redirect; auth listener will populate currentUser.
      final user = _currentUser;
      if (user != null) return user;
      throw const AuthException(
        'Proses OAuth dimulai. Selesaikan autentikasi di browser.',
      );
    }

    await Future.delayed(const Duration(milliseconds: 900));
    return _loginWithSocialProvider(
      email: 'google.user@mbg.io',
      name: 'Pengguna Google',
    );
  }

  Future<AppUser> loginWithApple() async {
    if (SupabaseService.isInitialized) {
      await Supabase.instance.client.auth.signInWithOAuth(Provider.apple);
      final user = _currentUser;
      if (user != null) return user;
      throw const AuthException(
        'Proses OAuth dimulai. Selesaikan autentikasi di browser.',
      );
    }

    await Future.delayed(const Duration(milliseconds: 900));
    return _loginWithSocialProvider(
      email: 'apple.user@mbg.io',
      name: 'Pengguna Apple',
    );
  }

  // OAuth with GitHub via Supabase
  Future<void> loginWithGithub() async {
    if (!SupabaseService.isInitialized) {
      throw const AuthException('Supabase belum dikonfigurasi.');
    }

    await Supabase.instance.client.auth.signInWithOAuth(Provider.github);
  }

  AppUser _loginWithSocialProvider({
    required String email,
    required String name,
  }) {
    final existing = _demoAccounts.where(
      (account) => account.email.toLowerCase() == email.toLowerCase(),
    );

    final user = existing.isNotEmpty
        ? existing.first.user
        : AppUser(
            id: 'u-${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            email: email,
            role: UserRole.pengguna,
          );

    if (existing.isEmpty) {
      _demoAccounts.add(_DemoAccount(email: email, password: '', user: user));
    }

    _currentUser = user;
    return user;
  }

  // Forgot password flow
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final trimmed = email.trim().toLowerCase();
    final exists = _demoAccounts.any(
      (account) => account.email.toLowerCase() == trimmed,
    );
    if (!exists) {
      throw const AuthException('Email tidak terdaftar.');
    }

    _pendingResetEmail = trimmed;
  }

  Future<void> verifyResetCode({required String code}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_pendingResetEmail == null) {
      throw const AuthException('Silakan mulai ulang proses reset password.');
    }
    if (code.trim() != _demoResetCode) {
      throw const AuthException('Kode verifikasi salah.');
    }
  }

  Future<void> resetPassword({required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (_pendingResetEmail == null) {
      throw const AuthException('Sesi reset password sudah berakhir.');
    }

    final index = _demoAccounts.indexWhere(
      (account) => account.email.toLowerCase() == _pendingResetEmail,
    );
    if (index != -1) {
      _demoAccounts[index] = _DemoAccount(
        email: _demoAccounts[index].email,
        username: _demoAccounts[index].username,
        phone: _demoAccounts[index].phone,
        password: newPassword,
        user: _demoAccounts[index].user,
      );
    }

    _pendingResetEmail = null;
    _justResetPassword = true;
  }

  bool consumePasswordResetSuccess() {
    final value = _justResetPassword;
    _justResetPassword = false;
    return value;
  }

  void logout() {
    if (SupabaseService.isInitialized) {
      Supabase.instance.client.auth.signOut();
    }
    _currentUser = null;
  }

  // Profile
  Future<AppUser> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    DateTime? dateOfBirth,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _currentUser;
    if (user == null) {
      throw const AuthException('Sesi berakhir, silakan masuk kembali.');
    }
    if (firstName.trim().isEmpty) {
      throw const AuthException('Nama depan wajib diisi.');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw const AuthException('Alamat email tidak valid.');
    }
    if (phone.trim().isEmpty) {
      throw const AuthException('Nomor telepon wajib diisi.');
    }

    final emailChanged = email.trim().toLowerCase() != user.email.toLowerCase();
    if (emailChanged &&
        _demoAccounts.any(
          (account) =>
              account.email.toLowerCase() == email.trim().toLowerCase(),
        )) {
      throw const AuthException('Email sudah digunakan.');
    }

    final fullName = lastName.trim().isEmpty
        ? firstName.trim()
        : '${firstName.trim()} ${lastName.trim()}';
    final updated = user.copyWith(
      name: fullName,
      email: email.trim(),
      phone: phone.trim(),
      dateOfBirth: dateOfBirth,
    );
    if (SupabaseService.isInitialized && user.id.isNotEmpty) {
      if (emailChanged) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: email.trim()),
        );
      }
      await Supabase.instance.client
          .from('profiles')
          .update({
            'name': fullName,
            'email': email.trim(),
            'phone': phone.trim(),
          })
          .eq('id', user.id);
    }
    _persistCurrentUser(updated, email: email.trim());
    return updated;
  }

  void updatePushNotifications(bool enabled) {
    final user = _currentUser;
    if (user == null) return;
    _persistCurrentUser(user.copyWith(pushNotificationsEnabled: enabled));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _currentUser;
    if (user == null) {
      throw const AuthException('Sesi berakhir, silakan masuk kembali.');
    }

    final index = _demoAccounts.indexWhere(
      (account) => account.email.toLowerCase() == user.email.toLowerCase(),
    );
    if (index == -1) {
      throw const AuthException('Akun tidak ditemukan.');
    }
    if (_demoAccounts[index].password != currentPassword) {
      throw const AuthException('Kata sandi saat ini salah.');
    }
    if (newPassword.length < 8) {
      throw const AuthException('Kata sandi baru minimal 8 karakter.');
    }

    _demoAccounts[index] = _DemoAccount(
      email: _demoAccounts[index].email,
      username: _demoAccounts[index].username,
      phone: _demoAccounts[index].phone,
      password: newPassword,
      user: _demoAccounts[index].user,
    );
  }

  // Settings — permanently remove the current account and sign out.
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _currentUser;
    if (user == null) return;

    _demoAccounts.removeWhere(
      (account) => account.email.toLowerCase() == user.email.toLowerCase(),
    );
    _currentUser = null;
  }

  void _persistCurrentUser(AppUser updated, {String? email}) {
    _currentUser = updated;
    final index = _demoAccounts.indexWhere(
      (account) => account.email.toLowerCase() == updated.email.toLowerCase(),
    );
    if (index != -1) {
      _demoAccounts[index] = _DemoAccount(
        email: email ?? _demoAccounts[index].email,
        username: _demoAccounts[index].username,
        phone: updated.phone,
        password: _demoAccounts[index].password,
        user: updated,
      );
    }
  }

  List<AppUser> get allUsers =>
      _demoAccounts.map((a) => a.user).toList(growable: false);

  String get _adminActorName => _currentUser?.name ?? 'Administrator';

  AppUser adminCreateUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    final trimmedEmail = email.trim().toLowerCase();
    if (name.trim().isEmpty || trimmedEmail.isEmpty || password.length < 6) {
      throw const AuthException(
        'Nama, email wajib diisi dan kata sandi minimal 6 karakter.',
      );
    }
    final exists = _demoAccounts.any(
      (a) => a.email.toLowerCase() == trimmedEmail,
    );
    if (exists) {
      throw const AuthException('Email sudah terdaftar.');
    }

    final newUser = AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: trimmedEmail,
      role: role,
      createdAt: DateTime.now(),
    );
    _demoAccounts.add(
      _DemoAccount(email: trimmedEmail, password: password, user: newUser),
    );

    AuditLogService.instance.log(
      actor: _adminActorName,
      category: AuditCategory.pengguna,
      action: 'Menambahkan pengguna',
      detail: '${newUser.name} (${newUser.email}) sebagai ${role.label}.',
    );
    return newUser;
  }

  void adminUpdateUserRole({required String userId, required UserRole role}) {
    final index = _demoAccounts.indexWhere((a) => a.user.id == userId);
    if (index == -1) throw const AuthException('Pengguna tidak ditemukan.');

    final current = _demoAccounts[index].user;
    final updated = current.copyWith(role: role);
    _demoAccounts[index] = _DemoAccount(
      email: _demoAccounts[index].email,
      username: _demoAccounts[index].username,
      phone: _demoAccounts[index].phone,
      password: _demoAccounts[index].password,
      user: updated,
    );
    if (_currentUser?.id == userId) _currentUser = updated;

    AuditLogService.instance.log(
      actor: _adminActorName,
      category: AuditCategory.pengguna,
      action: 'Mengubah peran pengguna',
      detail: '${updated.name} menjadi ${role.label}.',
    );
  }

  void adminSetUserActive({required String userId, required bool active}) {
    if (_currentUser?.id == userId) {
      throw const AuthException('Tidak dapat menonaktifkan akun sendiri.');
    }
    final index = _demoAccounts.indexWhere((a) => a.user.id == userId);
    if (index == -1) throw const AuthException('Pengguna tidak ditemukan.');

    final current = _demoAccounts[index].user;
    final updated = current.copyWith(isActive: active);
    _demoAccounts[index] = _DemoAccount(
      email: _demoAccounts[index].email,
      password: _demoAccounts[index].password,
      user: updated,
    );

    AuditLogService.instance.log(
      actor: _adminActorName,
      category: AuditCategory.pengguna,
      action: active ? 'Mengaktifkan pengguna' : 'Menonaktifkan pengguna',
      detail: '${updated.name} (${updated.email}).',
    );
  }

  void adminDeleteUser(String userId) {
    if (_currentUser?.id == userId) {
      throw const AuthException('Tidak dapat menghapus akun sendiri.');
    }
    final index = _demoAccounts.indexWhere((a) => a.user.id == userId);
    if (index == -1) throw const AuthException('Pengguna tidak ditemukan.');

    final removed = _demoAccounts[index].user;
    _demoAccounts.removeAt(index);

    AuditLogService.instance.log(
      actor: _adminActorName,
      category: AuditCategory.pengguna,
      action: 'Menghapus pengguna',
      detail: '${removed.name} (${removed.email}).',
    );
  }

  void adminResetPassword({
    required String userId,
    required String newPassword,
  }) {
    if (newPassword.length < 6) {
      throw const AuthException('Kata sandi baru minimal 6 karakter.');
    }
    final index = _demoAccounts.indexWhere((a) => a.user.id == userId);
    if (index == -1) throw const AuthException('Pengguna tidak ditemukan.');

    _demoAccounts[index] = _DemoAccount(
      email: _demoAccounts[index].email,
      username: _demoAccounts[index].username,
      phone: _demoAccounts[index].phone,
      password: newPassword,
      user: _demoAccounts[index].user,
    );

    AuditLogService.instance.log(
      actor: _adminActorName,
      category: AuditCategory.pengguna,
      action: 'Mereset kata sandi pengguna',
      detail:
          '${_demoAccounts[index].user.name} (${_demoAccounts[index].user.email}).',
    );
  }
}

class _DemoAccount {
  final String email;
  final String username;
  final String phone;
  final String password;
  final AppUser user;

  const _DemoAccount({
    required this.email,
    this.username = '',
    this.phone = '',
    required this.password,
    required this.user,
  });
}
