// Validators implementation (T015). Return null when valid else an error code string.
// Keep error codes simple; UI layer can map to user-friendly text.
import 'package:ariokan_index/shared/constants/limits.dart';

final RegExp _usernameReg = RegExp(r'^[a-z0-9_]{3,20}$');
final RegExp _emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateUsername(String input) {
  final value = input.trim();
  if (!_usernameReg.hasMatch(value)) return 'username_invalid';
  return null;
}

String? validateEmail(String input) {
  final value = input.trim();
  if (!_emailReg.hasMatch(value)) return 'email_invalid';
  return null;
}

String? validatePassword(String input) {
  if (input.length < passwordMinLength) return 'password_too_short';
  if (input.length > passwordMaxLength) return 'password_too_long';
  return null;
}
