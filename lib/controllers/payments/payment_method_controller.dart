import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:zip_peer/config/stripe/stripe_config.dart';
import 'package:zip_peer/models/payments/payment_models.dart';
import 'package:zip_peer/services/payments/payment_service.dart';


class PaymentConfirmOutcome {
  const PaymentConfirmOutcome({
    required this.success,
    this.payment,
    this.bookingLikelyUpdated = false,
  });

  final bool success;
  final PaymentTransactionModel? payment;
  final bool bookingLikelyUpdated;
}

class PaymentMethodController extends GetxController {
  PaymentMethodController({PaymentService? paymentService})
      : _service = paymentService ?? PaymentService();

  final PaymentService _service;

  List<PaymentMethodModel> methods = const [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadMethods();
    ensureStripeConfigLoaded();
  }

  /// Fetches `GET /payments/config` once per app session (guarded by
  /// [StripeRuntimeConfig.fetched], which survives this controller being
  /// recreated) and, when the server reports payments enabled, sets
  /// `Stripe.publishableKey` and applies it — so the SDK is ready before
  /// the user ever taps "Pay Now".
  /// Wrapped defensively for the same reason as `main.dart`'s
  /// `_maybeInitStripe` — `Stripe.instance.applySettings()` must never be
  /// able to throw unhandled out of here (confirmed live, 2026-10-06; see
  /// that doc comment for the root cause and fix).
  Future<void> ensureStripeConfigLoaded() async {
    if (StripeRuntimeConfig.fetched) return;
    try {
      final result = await _service.getPaymentsConfig();
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

  /// The method checkout should preselect — the one marked `isDefault`, or
  /// simply the first saved one if none is (the API always returns at least
  /// the order it was saved in, and only ever has one method to begin with
  /// for most users).
  PaymentMethodModel? get defaultMethod {
    for (final m in methods) {
      if (m.isDefault) return m;
    }
    return methods.isNotEmpty ? methods.first : null;
  }

  Future<void> loadMethods() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _service.getPaymentMethods();

    isLoading = false;
    if (result.success) {
      methods = result.methods;
    } else {
      errorMessage = result.message;
    }
    update();
  }

  Future<PaymentMethodModel?> addMethod(SavePaymentMethodRequest request) async {
    isSaving = true;
    update();

    final result = await _service.savePaymentMethod(request);

    isSaving = false;
    if (!result.success) {
      _showSnackbar('Couldn\'t save card', result.message);
      update();
      return null;
    }

    await loadMethods();
    return result.method;
  }

  Future<void> deleteMethod(String id) async {
    final result = await _service.deletePaymentMethod(id);
    if (result.success) {
      // Server response is authoritative — it already reflects any default
      // re-promotion that happened as a side effect of this delete.
      methods = result.methods;
      update();
    } else {
      _showSnackbar('Error', result.message);
    }
  }

  Future<void> setDefault(String id) async {
    final result = await _service.setDefaultPaymentMethod(id);
    if (result.success) {
      await loadMethods();
    } else {
      _showSnackbar('Error', result.message);
    }
  }

  // ── Real Stripe checkout ("Pay Now") ───────────────────────────────────

  bool isCreatingIntent = false;
  bool isConfirmingPayment = false;

  Future<PaymentIntentModel?> createPaymentIntent(String bookingId) async {
    isCreatingIntent = true;
    update();

    final result = await _service.createPaymentIntent(bookingId);

    isCreatingIntent = false;
    update();

    if (!result.success) {
      _showSnackbar('Payment Failed', _friendlyPaymentError(result.message));
      return null;
    }
    return result.intent;
  }

  /// Call once Stripe's PaymentSheet reports success — tells the backend to
  /// verify the PaymentIntent with Stripe and mark the booking paid.
  ///
  /// A 409 here can mean the payment already succeeded (a retry landing in
  /// the webhook-pending window) or is still `processing` — both are
  /// "booking state changed," not a dead end, hence [bookingLikelyUpdated]
  /// rather than just `success`.
  Future<PaymentConfirmOutcome> confirmPayment({
    required String bookingId,
    required String paymentIntentId,
  }) async {
    isConfirmingPayment = true;
    update();

    final result = await _service.recordPayment(
      bookingId: bookingId,
      paymentIntentId: paymentIntentId,
    );

    isConfirmingPayment = false;
    update();

    if (!result.success) {
      final lower = result.message.toLowerCase();
      final alreadyHandled =
          lower.contains('already recorded') || lower.contains('being processed');
      _showSnackbar(
        alreadyHandled ? 'Payment Status' : 'Payment Failed',
        _friendlyPaymentError(result.message),
      );
      return PaymentConfirmOutcome(success: false, bookingLikelyUpdated: alreadyHandled);
    }
    return PaymentConfirmOutcome(success: true, payment: result.payment, bookingLikelyUpdated: true);
  }

  /// Raw server/Stripe error text can be arbitrarily long — confirmed live,
  /// 2026-10-07 on the payout screen (a Stripe Accounts-v1-vs-v2 migration
  /// error came back as a multi-paragraph message with an embedded curl
  /// example, overflowing a plain `Get.snackbar(title, message)` by 481px).
  /// `_friendlyPaymentError` already rewrites the known messages, but
  /// anything it doesn't recognize still passes through raw, so every
  /// snackbar here goes through this cap rather than only the ones already
  /// known to be risky.
  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      messageText: Text(message, maxLines: 6, overflow: TextOverflow.ellipsis),
    );
  }

  /// Reword the messages the payments guide specifically calls out as
  /// needing friendlier copy (§4/§7); everything else — including the two
  /// 409s and the legacy-pricing 400 — passes through the server's own
  /// message, which the guide's own wording is already clear on.
  ///
  /// The two substring checks below are confirmed live, 2026-10-05: the
  /// "not accepted" message reads `"...can only be created once the
  /// booking is accepted (this one is \"pending\")"`, and the payout one
  /// reads "...has not connected their Stripe payout account yet...". The
  /// 409s and legacy-pricing 400 are documented, not yet live-reachable
  /// (need a Stripe-connected owner and/or a pre-29-Sep booking).
  String _friendlyPaymentError(String serverMessage) {
    final lower = serverMessage.toLowerCase();
    if (lower.contains('booking is accepted') ||
        lower.contains('is "pending"') ||
        lower.contains("is 'pending'")) {
      return 'Waiting for the owner to accept this booking before checkout can proceed.';
    }
    if (lower.contains('payout account') || lower.contains('stripe payout')) {
      return 'The owner is still completing their payout setup. Please notify them in chat.';
    }
    if (lower.contains('already recorded')) {
      return 'This booking has already been paid.';
    }
    return serverMessage;
  }
}
