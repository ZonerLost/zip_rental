import 'dart:async';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:zip_peer/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/services/auth/auth_session_store.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/token_refresh_service.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';
import 'package:zip_peer/views/screens/auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _listenForSessionExpiry();
  await _maybeStartTokenRefresh();
  runApp(MyApp());
}

Future<void> _maybeStartTokenRefresh() async {
  final store = AuthSessionStore();
  final refreshToken = await store.getRefreshToken();
  if (refreshToken == null || refreshToken.isEmpty) return;
  final authService = AuthService();
  await authService.ensureAccessToken();
  unawaited(TokenRefreshService.start());
}

void _listenForSessionExpiry() {
  AuthService.onSessionExpired.listen((_) {
    ChatSocketService.resetShared();
    Get.offAll(() => const LoginScreen());
    Get.snackbar('Session Expired', 'Please sign in again to continue.');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kbackground,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      initialRoute: AppLinks.splash_screen,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
