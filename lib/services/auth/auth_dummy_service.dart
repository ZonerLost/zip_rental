import 'package:zip_peer/models/auth/auth_models.dart';

class AuthDummyService {
  Future<AuthResult> login(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (request.identifier.isEmpty || request.password.isEmpty) {
      return const AuthResult(success: false, message: 'Missing credentials');
    }
    return const AuthResult(success: true, message: 'Login successful');
  }

  Future<AuthResult> signup(SignupRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (request.identifier.isEmpty || request.password.isEmpty) {
      return const AuthResult(success: false, message: 'Missing information');
    }
    return const AuthResult(success: true, message: 'Signup successful');
  }

  Future<AuthResult> sendResetLink(ForgotPasswordRequest request) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (request.email.isEmpty) {
      return const AuthResult(success: false, message: 'Email is required');
    }
    return const AuthResult(success: true, message: 'Reset link sent');
  }

  Future<AuthResult> verifyOtp(VerifyOtpRequest request) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (request.code.length != 6) {
      return const AuthResult(success: false, message: 'Invalid OTP');
    }
    return const AuthResult(success: true, message: 'OTP verified');
  }

  Future<AuthResult> resendOtp() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthResult(success: true, message: 'OTP resent');
  }

  Future<AuthResult> resetPassword(ResetPasswordRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (request.password.isEmpty || request.confirmPassword.isEmpty) {
      return const AuthResult(success: false, message: 'Password is required');
    }
    if (request.password != request.confirmPassword) {
      return const AuthResult(
        success: false,
        message: 'Passwords do not match',
      );
    }
    return const AuthResult(
      success: true,
      message: 'Password reset successful',
    );
  }
}
