enum UserRole { administrator, pengguna, teknisi }

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.administrator => 'Administrator',
    UserRole.pengguna => 'Pengguna',
    UserRole.teknisi => 'Teknisi / Maintenance',
  };

  static UserRole fromApiValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'administrator':
      case 'admin':
        return UserRole.administrator;
      case 'teknisi':
      case 'maintenance':
        return UserRole.teknisi;
      case 'pengguna':
      case 'user':
      default:
        return UserRole.pengguna;
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final DateTime? dateOfBirth;
  final bool pushNotificationsEnabled;
  final bool isActive;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.dateOfBirth,
    this.pushNotificationsEnabled = true,
    this.isActive = true,
    this.createdAt,
  });

  // Profile details screen splits the full name into first/last name.
  String get firstName => name.trim().split(' ').first;

  String get lastName {
    final parts = name.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['user_id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: UserRoleX.fromApiValue(json['role'] as String),
    );
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    DateTime? dateOfBirth,
    bool? pushNotificationsEnabled,
    bool? isActive,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
