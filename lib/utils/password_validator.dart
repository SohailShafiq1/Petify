class PasswordValidator {
  static const String _passwordPattern =
      r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$';

  /// Validates if password meets strong password requirements:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one number
  /// - At least one special character
  static bool isStrong(String password) {
    final regex = RegExp(_passwordPattern);
    return regex.hasMatch(password);
  }

  /// Returns a list of validation errors for the password
  static List<String> getValidationErrors(String password) {
    final errors = <String>[];

    if (password.isEmpty) {
      errors.add('Password is required');
      return errors;
    }

    if (password.length < 8) {
      errors.add('At least 8 characters');
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('At least one uppercase letter (A-Z)');
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('At least one number (0-9)');
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('At least one special character (!@#\$%^&*)');
    }

    return errors;
  }

  /// Returns a formatted error message
  static String getErrorMessage(String password) {
    final errors = getValidationErrors(password);
    if (errors.isEmpty) return '';
    return errors.join('\n');
  }
}
