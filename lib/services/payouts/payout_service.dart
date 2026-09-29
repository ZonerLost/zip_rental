import 'package:zip_peer/models/payouts/payout_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

/// Stripe Connect Express payout onboarding — confirmed shape,
/// `payout-information-answer.md` (2026-09-29). See
/// docs/backend-payout-information.md for the original request and
/// docs/backend-payout-onboarding.md for what's confirmed.
class PayoutService extends ApiServiceBase {
  PayoutService({AuthService? authService}) : super(authService: authService);

  /// Built not to fail per the backend: if Stripe is unreachable this still
  /// answers 200 with the last known status rather than an error.
  Future<PayoutStatusResult> getStatus() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/users/payout-account',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return PayoutStatusResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data');
    final status = raw is Map
        ? PayoutAccountStatus.fromJson(stringKeyMap(raw))
        : null;
    return PayoutStatusResult(success: true, message: message, status: status);
  }

  /// 503 until the backend has both Stripe keys and our two deep links
  /// configured — surfaced as a plain failure with the server's own
  /// message, not a crash.
  Future<PayoutOnboardingLinkResult> createOnboardingLink() async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/users/payout-account/onboarding-link',
      requiresAuth: true,
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      return PayoutOnboardingLinkResult(success: false, message: message);
    }

    final map = asMap(response.body);
    // The documented success response for this one endpoint is a bare
    // `{ url, expiresAt, accountId }`, not the usual `{ success, message,
    // data }` envelope the rest of the API uses — accept either shape.
    final raw = getByPath(map, 'data') ?? (map.containsKey('url') ? map : null);
    final link = raw is Map
        ? PayoutOnboardingLink.fromJson(stringKeyMap(raw))
        : null;

    if (link == null || link.url.isEmpty) {
      return const PayoutOnboardingLinkResult(
        success: false,
        message: "Couldn't get a payout setup link from the server.",
      );
    }
    return PayoutOnboardingLinkResult(success: true, message: message, link: link);
  }
}
