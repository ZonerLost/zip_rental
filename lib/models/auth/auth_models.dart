enum AuthMethod { email, phone }

class LoginRequest {
  const LoginRequest({
    required this.method,
    required this.identifier,
    required this.password,
  });

  final AuthMethod method;
  final String identifier;
  final String password;
}

class SignupRequest {
  const SignupRequest({
    required this.method,
    required this.identifier,
    required this.password,
    required this.useFaceId,
  });

  final AuthMethod method;
  final String identifier;
  final String password;
  final bool useFaceId;
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;
}

class VerifyOtpRequest {
  const VerifyOtpRequest({required this.code});

  final String code;
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.password,
    required this.confirmPassword,
  });

  final String password;
  final String confirmPassword;
}

class AuthResult {
  const AuthResult({required this.success, required this.message});

  final bool success;
  final String message;
}
