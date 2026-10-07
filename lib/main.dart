import 'dart:async';
import 'dart:developer' as developer;
import 'package:app_links/app_links.dart' as deep_links;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:zip_peer/config/stripe/stripe_config.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:zip_peer/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/controllers/payouts/payout_controller.dart';
import 'package:zip_peer/services/auth/auth_session_store.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/auth/token_refresh_service.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';
import 'package:zip_peer/services/payments/payment_service.dart';
import 'package:zip_peer/views/screens/auth/login.dart';
import 'package:zip_peer/views/screens/payouts/payout_information_screen.dart';

// Stripe Connect payout onboarding return/refresh deep links
// (atussa://payouts/done, atussa://payouts/retry — see
// docs/backend-payout-onboarding.md). Neither URL carries data; both just
// mean "the owner is back, check payout status again". `restricted` is a
// normal outcome here (Stripe often wants one more document), so `done` and
// `retry` are handled identically — the status itself says what's next.
StreamSubscription<Uri>? _deepLinkSub;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _maybeInitStripe();
  _listenForSessionExpiry();
  _listenForPayoutDeepLinks();
  await _maybeStartTokenRefresh();
  runApp(MyApp());
}

/// Fetches `GET /payments/config` and applies it — "fetching it at launch
/// means a test→live switch, or a key rotation, needs no app release" (the
/// backend's own framing). Guarded by [StripeRuntimeConfig.fetched], so
/// this is skipped if it somehow already ran (it can't have, this early,
/// but [PaymentMethodController.ensureStripeConfigLoaded] uses the same
/// guard as a fallback in case this one failed, e.g. no network at boot).
/// A "Pay Now" attempt with Stripe still unconfigured is caught separately
/// and shown as a friendly message rather than crashing.
///
/// The whole body is wrapped defensively: `Stripe.instance.applySettings()`
/// previously threw an **unhandled** `PlatformException` here when the
/// native SDK couldn't initialize (confirmed live, 2026-10-06 — caused by
/// `MainActivity` extending `FlutterActivity` instead of the
/// `FlutterFragmentActivity` flutter_stripe's Android side requires), which
/// happened early enough in `main()` to block `runApp()` entirely — the app
/// never rendered. Fixed at the root (MainActivity.kt), but config-fetching
/// code this early in boot should never be able to take the whole app down
/// regardless of the specific cause, so every path here is now non-fatal.
Future<void> _maybeInitStripe() async {
  if (StripeRuntimeConfig.fetched) return;
  try {
    final result = await PaymentService().getPaymentsConfig();
    if (!result.success || result.config == null) return;

    StripeRuntimeConfig.applyFrom(result.config!);
    if (StripeRuntimeConfig.isConfigured) {
      Stripe.publishableKey = StripeRuntimeConfig.effectivePublishableKey;
      await Stripe.instance.applySettings();
    }
  } catch (e) {
    developer.log('Stripe init failed: $e', name: 'stripe');
  }
}

void _listenForPayoutDeepLinks() {
  final appLinks = deep_links.AppLinks();

  _deepLinkSub = appLinks.uriLinkStream.listen(
    _handlePayoutDeepLink,
    onError: (Object e) =>
        developer.log('payout deep link stream error: $e', name: 'payouts'),
  );


  WidgetsBinding.instance.addPostFrameCallback((_) {
    appLinks.getInitialLink().then((uri) {
      if (uri != null) _handlePayoutDeepLink(uri);
    });
  });
}

void _handlePayoutDeepLink(Uri uri) {
  if (uri.scheme != 'atussa' || uri.host != 'payouts') return;

  if (Get.isRegistered<PayoutController>()) {
    Get.find<PayoutController>().loadStatus();
  } else {
    // App was relaunched cold — there's no existing Payout Information
    // screen instance to refresh, so open one.
    Get.to(() => const PayoutInformationScreen());
  }
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
