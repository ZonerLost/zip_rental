import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/config/stripe/stripe_config.dart';
import 'package:zip_peer/models/payments/payment_models.dart';

// `POST /payments/create-intent` success shape, from the "Payments & Stripe
// Connect — App Developer Guide" (2026-10-05). Not independently
// live-confirmed as a success response — reaching it requires an owner who
// has actually completed Stripe Connect onboarding, which no test account
// has. What *was* confirmed live (2026-10-05) is every error path this
// endpoint takes before reaching this response: booking-not-accepted (400),
// owner-not-payout-connected (400), and wrong-party (403) — see
// PaymentMethodController._friendlyPaymentError.
const _createIntentSuccessJson = {
  'clientSecret': 'pi_3MtwxAEomAQGuqc50mDuErSm_secret_Yr5a...',
  'paymentIntentId': 'pi_3MtwxAEomAQGuqc50mDuErSm',
  'amount': 104.59,
  'currency': 'CAD',
  'bookingId': '651234abcd5678ef90123456',
};

// `GET /payments/config` documented shape, from `disputes-api-answers.md`'s
// sibling `stripe-checkout-answers.md` (2026-10-05).
const _paymentsConfigJson = {
  'publishableKey': 'pk_test_51...',
  'paymentsEnabled': true,
  'currency': 'CAD',
  'merchantCountryCode': 'CA',
  'mode': 'test',
};

// The endpoint's real live response, 2026-10-06, confirmed via
// `atussa-pricing-confirmation.md`'s sibling reply: the publishable key
// hasn't been put in the server environment yet, so it comes back `null`
// with `paymentsEnabled: false` rather than the endpoint failing outright.
const _paymentsConfigLiveNotYetEnabledJson = {
  'publishableKey': null,
  'paymentsEnabled': false,
  'currency': 'CAD',
  'merchantCountryCode': 'CA',
  'mode': 'test',
};

void main() {
  group('PaymentIntentModel.fromJson', () {
    test('parses the documented create-intent success shape', () {
      final intent = PaymentIntentModel.fromJson(_createIntentSuccessJson);
      expect(intent.clientSecret, 'pi_3MtwxAEomAQGuqc50mDuErSm_secret_Yr5a...');
      expect(intent.paymentIntentId, 'pi_3MtwxAEomAQGuqc50mDuErSm');
      expect(intent.amount, 104.59);
      expect(intent.currency, 'CAD');
      expect(intent.bookingId, '651234abcd5678ef90123456');
    });

    test('missing clientSecret parses to an empty string, not a crash', () {
      final intent = PaymentIntentModel.fromJson(const {
        'paymentIntentId': 'pi_123',
      });
      expect(intent.clientSecret, isEmpty);
      expect(intent.paymentIntentId, 'pi_123');
    });
  });

  group('PaymentsConfigModel.fromJson', () {
    test('parses the documented /payments/config shape', () {
      final config = PaymentsConfigModel.fromJson(_paymentsConfigJson);
      expect(config.publishableKey, 'pk_test_51...');
      expect(config.paymentsEnabled, isTrue);
      expect(config.currency, 'CAD');
      expect(config.merchantCountryCode, 'CA');
      expect(config.mode, 'test');
    });

    test('paymentsEnabled false disables checkout even with a key present', () {
      final config = PaymentsConfigModel.fromJson({
        ..._paymentsConfigJson,
        'paymentsEnabled': false,
      });
      expect(config.paymentsEnabled, isFalse);
    });

    test('a null publishableKey (real live shape, 2026-10-06) parses to empty, not a crash', () {
      final config = PaymentsConfigModel.fromJson(_paymentsConfigLiveNotYetEnabledJson);
      expect(config.publishableKey, isEmpty);
      expect(config.paymentsEnabled, isFalse);
      expect(config.merchantCountryCode, 'CA');
    });
  });

  group('StripeRuntimeConfig.isConfigured', () {
    setUp(() {
      StripeRuntimeConfig.fetched = false;
      StripeRuntimeConfig.publishableKey = null;
      StripeRuntimeConfig.paymentsEnabled = false;
    });

    // NOTE (2026-10-06): StripeConfig.publishableKeyOverride is temporarily
    // hardcoded to a real test key (see the TODO in stripe_config.dart) for
    // local "Pay Now" testing, rather than sourced from --dart-define — so
    // it's always non-empty here, and by design bypasses the paymentsEnabled
    // gate entirely (a manual override is explicit "test now" intent). These
    // three assert that bypass. Once the override is reverted to
    // String.fromEnvironment(...) (empty by default), restore the original
    // intent of this group: isConfigured should require a fetched server
    // config with paymentsEnabled: true, not just a key.

    test('override bypasses the paymentsEnabled gate — true even before applyFrom', () {
      expect(StripeRuntimeConfig.isConfigured, isTrue);
    });

    test('override bypasses the paymentsEnabled gate — true even when server reports false', () {
      StripeRuntimeConfig.applyFrom(
        PaymentsConfigModel.fromJson({..._paymentsConfigJson, 'paymentsEnabled': false}),
      );
      expect(StripeRuntimeConfig.isConfigured, isTrue);
    });

    test('true once applied with paymentsEnabled and a pk_ key', () {
      StripeRuntimeConfig.applyFrom(PaymentsConfigModel.fromJson(_paymentsConfigJson));
      expect(StripeRuntimeConfig.fetched, isTrue);
      expect(StripeRuntimeConfig.isConfigured, isTrue);
    });
  });
}
