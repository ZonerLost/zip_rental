enum AuthMethod { email, phone }

enum VerifyOtpType { emailVerification, passwordReset }

extension VerifyOtpTypeX on VerifyOtpType {
  String get value {
    switch (this) {
      case VerifyOtpType.emailVerification:
        return 'email_verification';
      case VerifyOtpType.passwordReset:
        return 'password_reset';
    }
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.language,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? language;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (language != null && language!.isNotEmpty) 'language': language,
    };
  }
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'password': password};
  }
}

class GoogleAuthRequest {
  const GoogleAuthRequest({required this.idToken, this.language});

  final String idToken;
  final String? language;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'idToken': idToken,
      if (language != null && language!.isNotEmpty) 'language': language,
    };
  }
}

class VerifyEmailRequest {
  const VerifyEmailRequest({
    required this.email,
    required this.otp,
    required this.type,
  });

  final String email;
  final String otp;
  final VerifyOtpType type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'otp': otp, 'type': type.value};
  }
}

class ResendVerificationRequest {
  const ResendVerificationRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email};
  }
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email};
  }
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  final String email;
  final String otp;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    };
  }
}

class UpdatePasswordRequest {
  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'refreshToken': refreshToken};
  }
}

class LogoutRequest {
  const LogoutRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'refreshToken': refreshToken};
  }
}

class PhoneSendOtpRequest {
  const PhoneSendOtpRequest({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => {'phone': phone};
}

class PhoneVerifyOtpRequest {
  const PhoneVerifyOtpRequest({
    required this.phone,
    required this.otp,
    this.firstName,
    this.lastName,
  });

  final String phone;
  final String otp;
  final String? firstName;
  final String? lastName;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
        if ((firstName ?? '').trim().isNotEmpty) 'firstName': firstName!.trim(),
        if ((lastName ?? '').trim().isNotEmpty) 'lastName': lastName!.trim(),
      };
}

class PhoneResendOtpRequest {
  const PhoneResendOtpRequest({required this.phone});

  final String phone;

  Map<String, dynamic> toJson() => {'phone': phone};
}

class PhoneAuthResult {
  const PhoneAuthResult({
    required this.success,
    required this.message,
    this.tokens,
    this.isNewUser = false,
    this.data,
  });

  final bool success;
  final String message;
  final AuthTokens? tokens;
  final bool isNewUser;
  final Map<String, dynamic>? data;
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.tokens,
    this.data,
  });

  final bool success;
  final String message;
  final AuthTokens? tokens;
  final Map<String, dynamic>? data;
}
