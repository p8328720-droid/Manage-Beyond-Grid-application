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
  final UserRole role;
  final DateTime? dateOfBirth;
  final bool pushNotificationsEnabled;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.dateOfBirth,
    this.pushNotificationsEnabled = true,
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
      role: UserRoleX.fromApiValue(json['role'] as String),
    );
  }

  AppUser copyWith({
    String? name,
    DateTime? dateOfBirth,
    bool? pushNotificationsEnabled,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }
}