import 'package:zip_peer/models/payments/payment_models.dart';

class StripeConfig {
  const StripeConfig._();

  /// An escape hatch for local "pay now" testing, empty in every normal build.
  ///
  /// Pass `--dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...` to set it. Sourcing it from the
  /// environment rather than hardcoding it keeps a key out of the repo while still letting a
  /// developer test before the server has one, and it deliberately bypasses the `paymentsEnabled`
  /// gate: supplying this is explicit "I know what I am doing" intent.
  static const String publishableKeyOverride = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );


  static const String merchantDisplayName = 'Atussa Rental Marketplace';
}

class StripeRuntimeConfig {
  StripeRuntimeConfig._();

  static bool fetched = false;
  static String? publishableKey;
  static bool paymentsEnabled = false;
  static String currency = 'CAD';
  static String merchantCountryCode = 'CA';

  static String mode = 'test';

  static String get effectivePublishableKey =>
      StripeConfig.publishableKeyOverride.isNotEmpty
      ? StripeConfig.publishableKeyOverride
      : (publishableKey ?? '');

  static bool get isConfigured =>
      effectivePublishableKey.startsWith('pk_') &&
      (StripeConfig.publishableKeyOverride.isNotEmpty || paymentsEnabled);

  static void applyFrom(PaymentsConfigModel config) {
    publishableKey = config.publishableKey;
    paymentsEnabled = config.paymentsEnabled;
    currency = config.currency;
    merchantCountryCode = config.merchantCountryCode;
    mode = config.mode;
    fetched = true;
  }
}
