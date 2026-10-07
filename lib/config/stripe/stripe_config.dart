import 'package:zip_peer/models/payments/payment_models.dart';

class StripeConfig {
  const StripeConfig._();

 
  static const String publishableKeyOverride =
      '';
      // '';


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
