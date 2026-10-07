import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zip_peer/models/payouts/payout_models.dart';
import 'package:zip_peer/services/payouts/payout_service.dart';
import 'package:zip_peer/views/screens/profile/edit_profile.dart';

class PayoutController extends GetxController {
  PayoutController({PayoutService? payoutService})
      : _service = payoutService ?? PayoutService();

  final PayoutService _service;

  PayoutAccountStatus? status;
  bool isLoading = false;
  bool isStartingOnboarding = false;
  String? errorMessage;

  /// Set when the most recent onboarding link reported `returnsTo: "web"` —
  /// there's no deep link coming back for that case, so [onAppResumed]
  /// re-checks status on the next foreground instead.
  bool _awaitingWebReturn = false;

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  Future<void> loadStatus() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _service.getStatus();

    isLoading = false;
    if (result.success) {
      status = result.status;
    } else {
      errorMessage = result.message;
    }
    update();
  }

  /// Requests a fresh, single-use Stripe onboarding link and opens it in
  /// the system browser (never cache/reuse a link — it expires in minutes).
  /// The app doesn't need to do anything with the redirect itself beyond
  /// refreshing status when the owner returns — see the deep-link listener
  /// in main.dart.
  Future<void> startOnboarding() async {
    if (isStartingOnboarding) return;
    isStartingOnboarding = true;
    update();

    final result = await _service.createOnboardingLink();

    isStartingOnboarding = false;
    update();

    if (!result.success || result.link == null) {
      if (_isMissingEmailError(result.message)) {
        _showMissingEmailPrompt(result.message);
      } else {
        _showSnackbar("Couldn't start payout setup", result.message);
      }
      return;
    }

    final uri = Uri.tryParse(result.link!.url);
    if (uri == null) {
      _showSnackbar(
        "Couldn't start payout setup",
        'The server returned an invalid link.',
      );
      return;
    }

    _awaitingWebReturn = result.link!.returnsToWeb;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      _showSnackbar('Couldn\'t open payout setup', 'Try again in a moment.');
    }
  }

  /// Raw Stripe/server error text can be arbitrarily long — confirmed live,
  /// 2026-10-07: a Stripe Accounts-v1-vs-v2 migration error came back as a
  /// multi-paragraph message with an embedded curl example, which overflowed
  /// a plain `Get.snackbar(title, message)` by 481px. Capping at a handful
  /// of lines with an ellipsis keeps the snackbar on-screen regardless of
  /// how verbose a future raw passthrough message turns out to be.
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      messageText: Text(message, maxLines: 6, overflow: TextOverflow.ellipsis),
    );
  }

  /// A phone-only signup can't start Stripe Connect onboarding — the v2
  /// Accounts API requires `contact_email`, and those accounts carry a
  /// placeholder address. Confirmed message per the backend team (their own
  /// suggestion: "worth a nicer in-app prompt if you can route it to the
  /// profile screen") — not yet independently live-confirmed since the fix
  /// that produces this specific message hadn't deployed as of this writing.
  bool _isMissingEmailError(String message) =>
      message.toLowerCase().contains('add an email address');

  /// Routes straight to Edit Profile instead of leaving the owner at a
  /// dead-end error — the fix for this error is adding an email, so the
  /// prompt might as well take them there directly.
  void _showMissingEmailPrompt(String message) {
    Get.snackbar(
      'Add an email to continue',
      message,
      messageText: Text(message, maxLines: 6, overflow: TextOverflow.ellipsis),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          Get.to(() => const EditProfileScreen());
        },
        child: const Text('Add Email', style: TextStyle(color: Colors.white)),
      ),
      duration: const Duration(seconds: 6),
    );
  }

  /// Call from the Payout Information screen's app-resumed lifecycle hook.
  /// Only re-fetches when the last onboarding attempt reported `returnsTo:
  /// "web"` — the `atussa://payouts/*` deep-link listener in main.dart
  /// already covers the "app" case, so this would otherwise double-fetch on
  /// every ordinary app resume.
  void onAppResumed() {
    if (!_awaitingWebReturn) return;
    _awaitingWebReturn = false;
    loadStatus();
  }
}
