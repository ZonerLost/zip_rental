/// Confirmed shape (`payout-information-answer.md`, 2026-09-29) — Stripe
/// Connect Express onboarding. The backend never receives bank details or
/// identity documents; those go straight to Stripe.
class PayoutStates {
  const PayoutStates._();

  static const String notConnected = 'not_connected';
  static const String pending = 'pending';
  static const String restricted = 'restricted';
  static const String active = 'active';
}

class PayoutBankInfo {
  const PayoutBankInfo({this.last4, this.name});

  final String? last4;
  final String? name;

  factory PayoutBankInfo.fromJson(Map<String, dynamic> json) {
    return PayoutBankInfo(
      last4: json['last4']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

class PayoutAccountStatus {
  const PayoutAccountStatus({
    required this.state,
    this.connected = false,
    this.payoutsEnabled = false,
    this.chargesEnabled = false,
    this.detailsSubmitted = false,
    this.actionRequired = false,
    this.requirementsDue = const [],
    this.disabledReason,
    this.country,
    this.currency,
    this.bank,
  });

  final String state;
  final bool connected;
  final bool payoutsEnabled;
  final bool chargesEnabled;
  final bool detailsSubmitted;
  final bool actionRequired;
  /// Stripe's own wording (e.g. `individual.verification.document`) — fine
  /// to show verbatim, it's what tells the owner why they're blocked.
  final List<String> requirementsDue;
  final String? disabledReason;
  final String? country;
  final String? currency;
  /// Absent until Stripe has an account on file — not the same as `null`
  /// meaning "no bank", just "nothing to show yet".
  final PayoutBankInfo? bank;

  bool get isNotConnected => state == PayoutStates.notConnected;
  bool get isPending => state == PayoutStates.pending;
  bool get isRestricted => state == PayoutStates.restricted;
  bool get isActive => state == PayoutStates.active;

  factory PayoutAccountStatus.fromJson(Map<String, dynamic> json) {
    final bankRaw = json['bank'];
    final requirementsRaw = json['requirementsDue'];
    return PayoutAccountStatus(
      state: json['state']?.toString() ?? PayoutStates.notConnected,
      connected: json['connected'] == true,
      payoutsEnabled: json['payoutsEnabled'] == true,
      chargesEnabled: json['chargesEnabled'] == true,
      detailsSubmitted: json['detailsSubmitted'] == true,
      actionRequired: json['actionRequired'] == true,
      requirementsDue: requirementsRaw is List
          ? requirementsRaw.map((e) => e.toString()).toList()
          : const <String>[],
      disabledReason: json['disabledReason']?.toString(),
      country: json['country']?.toString(),
      currency: json['currency']?.toString(),
      bank: bankRaw is Map
          ? PayoutBankInfo.fromJson(Map<String, dynamic>.from(bankRaw))
          : null,
    );
  }
}

class PayoutOnboardingLink {
  const PayoutOnboardingLink({required this.url, this.expiresAt, this.accountId});

  final String url;
  final DateTime? expiresAt;
  final String? accountId;

  factory PayoutOnboardingLink.fromJson(Map<String, dynamic> json) {
    return PayoutOnboardingLink(
      url: json['url']?.toString() ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      accountId: json['accountId']?.toString(),
    );
  }
}

class PayoutStatusResult {
  const PayoutStatusResult({
    required this.success,
    required this.message,
    this.status,
  });

  final bool success;
  final String message;
  final PayoutAccountStatus? status;
}

class PayoutOnboardingLinkResult {
  const PayoutOnboardingLinkResult({
    required this.success,
    required this.message,
    this.link,
  });

  final bool success;
  final String message;
  final PayoutOnboardingLink? link;
}
