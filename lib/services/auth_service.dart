import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const String _demoResetCode = '123456';

  static final List<_DemoAccount> _demoAccounts = [
    _DemoAccount(
      email: 'admin@mbg.io',
      password: 'admin123',
      user: const AppUser(
        id: 'u-001',
        name: 'Admin MBG',
        email: 'admin@mbg.io',
        role: UserRole.administrator,
      ),
    ),
    _DemoAccount(
      email: 'user@mbg.io',
      password: 'user123',
      user: const AppUser(
        id: 'u-002',
        name: 'Pengguna MBG',
        email: 'user@mbg.io',
        role: UserRole.pengguna,
      ),
    ),
    _DemoAccount(
      email: 'teknisi@mbg.io',
      password: 'teknisi123',
      user: const AppUser(
        id: 'u-003',
        name: 'Teknisi MBG',
        email: 'teknisi@mbg.io',
        role: UserRole.teknisi,
      ),
    ),
  ];

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  String? _pendingResetEmail;
  bool _justResetPassword = false;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      throw const AuthException('Semua kolom wajib diisi.');
    }

    final alreadyExists = _demoAccounts.any(
      (account) => account.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (alreadyExists) {
      throw const AuthException('Email sudah terdaftar.');
    }

    final newUser = AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: UserRole.pengguna,
    );
    _demoAccounts.add(
      _DemoAccount(email: email.trim(), password: password, user: newUser),
    );
    _currentUser = newUser;
    return newUser;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final matches = _demoAccounts.where(
      (account) =>
          account.email.toLowerCase() == email.trim().toLowerCase() &&
          account.password == password,
    );

    if (matches.isEmpty) {
      throw const AuthException('Email atau kata sandi salah.');
    }

    _currentUser = matches.first.user;
    return _currentUser!;
  }

  // Social sign-in
  Future<AppUser> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _loginWithSocialProvider(
      email: 'google.user@mbg.io',
      name: 'Pengguna Google',
    );
  }

  Future<AppUser> loginWithApple() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _loginWithSocialProvider(
      email: 'apple.user@mbg.io',
      name: 'Pengguna Apple',
    );
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
    _currentUser = null;
  }

  // Profile
  Future<AppUser> updateProfile({
    required String firstName,
    required String lastName,
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

    final fullName =
        lastName.trim().isEmpty ? firstName.trim() : '${firstName.trim()} ${lastName.trim()}';
    final updated = user.copyWith(name: fullName, dateOfBirth: dateOfBirth);
    _persistCurrentUser(updated);
    return updated;
  }

  void updatePushNotifications(bool enabled) {
    final user = _currentUser;
    if (user == null) return;
    _persistCurrentUser(user.copyWith(pushNotificationsEnabled: enabled));
  }

  // Settings — change password while already logged in. Unlike
  // [resetPassword] (forgot-password flow), this requires the current
  // password to match before it's allowed to change.
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

  void _persistCurrentUser(AppUser updated) {
    _currentUser = updated;
    final index = _demoAccounts.indexWhere(
      (account) => account.email.toLowerCase() == updated.email.toLowerCase(),
    );
    if (index != -1) {
      _demoAccounts[index] = _DemoAccount(
        email: _demoAccounts[index].email,
        password: _demoAccounts[index].password,
        user: updated,
      );
    }
  }
}

class _DemoAccount {
  final String email;
  final String password;
  final AppUser user;

  const _DemoAccount({
    required this.email,
    required this.password,
    required this.user,
  });
}