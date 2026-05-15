class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _numberRegex = RegExp(r'\d');

  static bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

  static bool isStrongPassword(String value) {
    final password = value.trim();
    return password.length >= 8 &&
        _uppercaseRegex.hasMatch(password) &&
        _numberRegex.hasMatch(password);
  }
}
