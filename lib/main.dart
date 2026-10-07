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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Synchronous only: these just install listeners, so they cannot delay the first frame.
  _listenForSessionExpiry();
  _listenForPayoutDeepLinks();

  runApp(MyApp());

  // Deliberately NOT awaited, and deliberately after runApp().
  //
  // Both of these make network calls, and ApiServiceBase has a 25s timeout — so awaiting them before
  // runApp() meant a cold start on a flaky network could sit on a blank screen for up to ~50s with
  // nothing rendered. That reads as a crash to a user and as a hang to an app reviewer.
  //
  // Neither is needed for correctness before the first frame:
  //   - the Stripe config has two independent fallbacks (PaymentMethodController.onInit and
  //     ensureStripeConfigLoaded), and a Pay Now tap with Stripe unconfigured is already handled
  //     with a message rather than a crash;
  //   - the access token is ensured per-request inside ApiServiceBase, which also refreshes and
  //     retries once on a 401, so the only thing _maybeStartTokenRefresh adds is the background
  //     refresh timer — useful, but not something to hold the UI for.
  unawaited(_maybeInitStripe());
  unawaited(_maybeStartTokenRefresh());
}

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
