// utils/mock_user_db.dart
import 'package:flutter/material.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/screen/login/mobile_verify_screen.dart';

class MockUserDB {
  static final Map<String, String> _users = {}; // email: password
  static final Set<String> _temporaryPasswords = {}; // временные пароли

  static bool userExists(String email) => _users.containsKey(email);

  static void registerUser(String email, String tempPassword) {
    _users[email] = tempPassword;
    _temporaryPasswords.add(email);
    print("Временный пароль отправлен на почту ($email): $tempPassword");
  }

  static bool validateUser(String email, String password) {
    return _users[email] == password;
  }

  static bool isTemporary(String email) {
    return _temporaryPasswords.contains(email);
  }

  static void updatePassword(String email, String newPassword) {
    _users[email] = newPassword;
    _temporaryPasswords.remove(email);
  }

  void registerUserAndNavigate(
    String email,
    String firstName,
    String lastName,
    String address,
    String mobile,
    String temporaryPassword,
    BuildContext context,
  ) {
    // Регистрируем пользователя с временным паролем
    MockUserDB.registerUser(email, temporaryPassword);

    // Здесь ты можешь сохранить другие данные пользователя, например, в базе данных или другом месте
    // Например, создадим модель для хранения информации о пользователе, если необходимо

    // Переход на экран для подтверждения номера телефона
    context.push(const MobileVerifyScreen());
  }
}
