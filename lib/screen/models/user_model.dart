class UserModel {
  String firstName;
  String lastName;
  String avatarPath;

  String email;
  String phoneNumber;
  String address;
  String role;
  String subscription;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.avatarPath,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.subscription,
  });

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? avatarPath,
    String? email,
    String? phoneNumber,
    String? address,
    String? role,
    String? subscription,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarPath: avatarPath ?? this.avatarPath,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      subscription: subscription ?? this.subscription,
      address: address ?? this.address,
    );
  }
}
