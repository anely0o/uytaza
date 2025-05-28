// user_role.dart
enum UserRole {
  admin,
  client,
  cleaner;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
        return UserRole.client;
      case 'cleaner':
        return UserRole.cleaner;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }
}