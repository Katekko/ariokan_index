final RegExp _usernameReg = RegExp(r'^[a-z0-9_]{3,20}$');
final RegExp _emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

const int _passwordMinLength = 6;
const int _passwordMaxLength = 128;

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
  if (input.length < _passwordMinLength) return 'password_too_short';
  if (input.length > _passwordMaxLength) return 'password_too_long';
  return null;
}
