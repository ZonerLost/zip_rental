import 'package:zip_peer/models/payments/payment_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

/// Wraps the "07 · Payments" section of the Atussa API — saved payment
/// methods and payment/transaction records, plus the real Stripe Connect
/// checkout (`createPaymentIntent` + the `paymentIntentId` path on
/// `recordPayment`). See docs/backend-payment-methods-integration.md for the
/// original (pre-Stripe) methods-CRUD contract, and the "Payments & Stripe
/// Connect — App Developer Guide" (2026-10-05) for create-intent/PaymentSheet.
class PaymentService extends ApiServiceBase {
  PaymentService({AuthService? authService}) : super(authService: authService);

  /// `GET /payments/config` — public, no auth, drives [StripeRuntimeConfig].
  Future<PaymentsConfigResult> getPaymentsConfig() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/payments/config',
      requiresAuth: false,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return PaymentsConfigResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? map;
    final config = raw is Map
        ? PaymentsConfigModel.fromJson(stringKeyMap(raw))
        : null;
    // A null/empty publishableKey is a legitimate response, not a failure
    // — confirmed live, 2026-10-06: `{ publishableKey: null, paymentsEnabled:
    // false, ... }` is exactly what the server sends before the real key is
    // in its environment. Only an unparseable body (raw wasn't even a Map)
    // counts as a failure here; StripeRuntimeConfig.isConfigured is what
    // actually gates checkout on paymentsEnabled.
    if (config == null) {
      return const PaymentsConfigResult(
        success: false,
        message: "Couldn't load payment configuration from the server.",
      );
    }
    return PaymentsConfigResult(success: true, message: message, config: config);
  }

  Future<PaymentMethodsResult> getPaymentMethods() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/payments/methods',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return PaymentMethodsResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? map['methods'];
    List<dynamic>? list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      list = raw['methods'] as List<dynamic>?;
    }

    final methods = (list ?? const [])
        .whereType<Map>()
        .map((m) => PaymentMethodModel.fromJson(stringKeyMap(m)))
        .where((m) => m.id.isNotEmpty)
        .toList();

    return PaymentMethodsResult(success: true, message: message, methods: methods);
  }

  Future<PaymentMethodResult> savePaymentMethod(
    SavePaymentMethodRequest requestBody,
  ) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/payments/methods',
      requiresAuth: true,
      body: requestBody.toJson(),
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return PaymentMethodResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? map;
    final method = raw is Map
        ? PaymentMethodModel.fromJson(stringKeyMap(raw))
        : null;
    return PaymentMethodResult(success: true, message: message, method: method);
  }

  /// Returns the *remaining* saved methods on success — confirmed response
  /// shape — so callers can refresh a picker without a second `GET`. The
  /// server also re-promotes a new default if the deleted method was it, so
  /// this list already reflects that.
  Future<PaymentMethodsResult> deletePaymentMethod(String id) async {
    final response = await request(
      method: ApiHttpMethod.delete,
      path: '/payments/methods/${Uri.encodeComponent(id)}',
      requiresAuth: true,
    );
    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: 'Payment method not found.',
    );
    if (!success) return PaymentMethodsResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data');
    final methods = raw is List
        ? raw
            .whereType<Map>()
            .map((m) => PaymentMethodModel.fromJson(stringKeyMap(m)))
            .where((m) => m.id.isNotEmpty)
            .toList()
        : <PaymentMethodModel>[];
    return PaymentMethodsResult(success: true, message: message, methods: methods);
  }

  Future<PaymentActionResult> setDefaultPaymentMethod(String id) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/payments/methods/${Uri.encodeComponent(id)}/default',
      requiresAuth: true,
    );
    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: 'Payment method not found.',
    );
    return PaymentActionResult(success: success, message: message);
  }

  /// Records a payment against a booking. **Only succeeds once the booking
  /// has been accepted by its owner** — confirmed 2026-09-28; calling this
  /// right after `POST /bookings` always 400s, since every booking starts
  /// `pending`.
  ///
  /// Pass [paymentIntentId] after a real Stripe PaymentSheet confirmation
  /// (see [createPaymentIntent]) — this path is verified against Stripe and
  /// actually moves money. [paymentMethodId]/[method] are the older,
  /// no-gateway "just record it" path (confirmed 2026-09-28 to not move
  /// money or touch any gateway) — still here for saved-method bookkeeping,
  /// but [paymentIntentId] is what a real "Pay Now" action should use.
  /// [externalReference] is for a genuine future gateway reference, not a
  /// stand-in id — the backend explicitly asked us to stop using it as one.
  Future<PaymentResult> recordPayment({
    required String bookingId,
    String? paymentIntentId,
    String? paymentMethodId,
    String? method,
    String? externalReference,
  }) async {
    assert(
      (paymentIntentId ?? '').trim().isNotEmpty ||
          (paymentMethodId ?? '').trim().isNotEmpty ||
          (method ?? '').trim().isNotEmpty,
      'recordPayment needs paymentIntentId, paymentMethodId, or method',
    );
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/payments',
      requiresAuth: true,
      body: <String, dynamic>{
        'bookingId': bookingId,
        if ((paymentIntentId ?? '').trim().isNotEmpty)
          'paymentIntentId': paymentIntentId!.trim(),
        if ((paymentMethodId ?? '').trim().isNotEmpty)
          'paymentMethodId': paymentMethodId!.trim(),
        if ((method ?? '').trim().isNotEmpty) 'method': method!.trim(),
        if ((externalReference ?? '').trim().isNotEmpty)
          'externalReference': externalReference!.trim(),
      },
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return PaymentResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? map;
    final payment = raw is Map
        ? PaymentTransactionModel.fromJson(stringKeyMap(raw))
        : null;
    return PaymentResult(success: true, message: message, payment: payment);
  }

  /// `POST /payments/create-intent` — step 1 of real Stripe checkout. Only
  /// valid once the booking is `accepted`; the amount is server-derived from
  /// `booking.pricing.totalAmount`, same as the no-gateway record path.
  Future<PaymentIntentResult> createPaymentIntent(String bookingId) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/payments/create-intent',
      requiresAuth: true,
      body: <String, dynamic>{'bookingId': bookingId},
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: 'Booking not found',
    );
    if (!success) return PaymentIntentResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? map;
    final intent = raw is Map
        ? PaymentIntentModel.fromJson(stringKeyMap(raw))
        : null;
    if (intent == null || intent.clientSecret.isEmpty) {
      return const PaymentIntentResult(
        success: false,
        message: "Couldn't start checkout — missing payment details from the server.",
      );
    }
    return PaymentIntentResult(success: true, message: message, intent: intent);
  }

  /// [role] — `payer` (default; money out), `payee` (money in, e.g. an
  /// owner's income), or `all`.
  Future<TransactionsResult> getMyTransactions({
    int page = 1,
    int limit = 10,
    String role = 'payer',
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/payments/my',
      requiresAuth: true,
      query: {'page': '$page', 'limit': '$limit', 'role': role},
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return TransactionsResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data');
    final transactions = raw is List
        ? raw
            .whereType<Map>()
            .map((m) => PaymentTransactionModel.fromJson(stringKeyMap(m)))
            .toList()
        : <PaymentTransactionModel>[];

    final paginationRaw = map['pagination'];
    final pagination = paginationRaw is Map
        ? PaymentsPagination.fromJson(stringKeyMap(paginationRaw))
        : null;

    return TransactionsResult(
      success: true,
      message: message,
      transactions: transactions,
      pagination: pagination,
    );
  }

  Future<PaymentResult> getPaymentDetail(String id) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/payments/${Uri.encodeComponent(id)}',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: 'Payment not found.',
    );
    if (!success) return PaymentResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? map;
    final payment = raw is Map
        ? PaymentTransactionModel.fromJson(stringKeyMap(raw))
        : null;
    return PaymentResult(success: true, message: message, payment: payment);
  }
}
