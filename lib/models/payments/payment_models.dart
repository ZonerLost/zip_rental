// ─────────────────────────────────────────────
//  Payment method (saved card reference)
// ─────────────────────────────────────────────
class PaymentCardInfo {
  const PaymentCardInfo({
    required this.brand,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
  });

  final String brand;
  final String last4;
  final int expiryMonth;
  final int expiryYear;

  factory PaymentCardInfo.fromJson(Map<String, dynamic> json) {
    return PaymentCardInfo(
      brand: json['brand']?.toString() ?? '',
      last4: json['last4']?.toString() ?? '',
      expiryMonth: int.tryParse(json['expiryMonth']?.toString() ?? '') ?? 0,
      expiryYear: int.tryParse(json['expiryYear']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'brand': brand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
    };
  }

  String get expiryLabel {
    final mm = expiryMonth.toString().padLeft(2, '0');
    final yy = expiryYear.toString().length >= 2
        ? expiryYear.toString().substring(expiryYear.toString().length - 2)
        : expiryYear.toString();
    return '$mm/$yy';
  }
}

class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.label,
    required this.isDefault,
    this.card,
  });

  final String id;
  final String type;
  final String label;
  final bool isDefault;
  final PaymentCardInfo? card;

  /// What the checkout sheet / list actually shows — the saved label when
  /// present, otherwise a sensible fallback built from the card info.
  String get displayLabel {
    if (label.trim().isNotEmpty) return label;
    if (card != null) return '${card!.brand} •••• ${card!.last4}';
    return type;
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final cardRaw = json['card'];
    return PaymentMethodModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'credit_card',
      label: json['label']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
      card: cardRaw is Map
          ? PaymentCardInfo.fromJson(Map<String, dynamic>.from(cardRaw))
          : null,
    );
  }
}

class SavePaymentMethodRequest {
  const SavePaymentMethodRequest({
    this.type = 'credit_card',
    required this.label,
    required this.isDefault,
    required this.card,
  });

  final String type;
  final String label;
  final bool isDefault;
  final PaymentCardInfo card;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'label': label,
      'isDefault': isDefault,
      'card': card.toJson(),
    };
  }
}

// ─────────────────────────────────────────────
//  Payment / transaction record
// ─────────────────────────────────────────────

/// The `payer`/`payee` side of a populated payment — confirmed shape:
/// `{ _id, firstName, lastName }`.
class PaymentPartyInfo {
  const PaymentPartyInfo({
    required this.id,
    this.firstName = '',
    this.lastName = '',
  });

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName'.trim();

  factory PaymentPartyInfo.fromJson(Map<String, dynamic> json) {
    return PaymentPartyInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
    );
  }
}

/// The populated `booking` on a payment — confirmed shape:
/// `{ _id, item, startDate, endDate }` (a bare id string, not an object).
class PaymentBookingInfo {
  const PaymentBookingInfo({
    required this.id,
    this.itemId,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String? itemId;
  final DateTime? startDate;
  final DateTime? endDate;

  factory PaymentBookingInfo.fromJson(Map<String, dynamic> json) {
    return PaymentBookingInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      itemId: json['item']?.toString(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }
}

class PaymentTransactionModel {
  const PaymentTransactionModel({
    required this.id,
    this.booking,
    this.payer,
    this.payee,
    this.paymentMethod,
    this.method,
    this.externalReference,
    this.receiptUrl,
    this.status,
    this.amount,
    this.currency,
    this.createdAt,
  });

  final String id;
  final PaymentBookingInfo? booking;
  final PaymentPartyInfo? payer;
  final PaymentPartyInfo? payee;
  final PaymentMethodModel? paymentMethod;
  final String? method;
  final String? externalReference;
  final String? receiptUrl;
  final String? status;
  final double? amount;
  final String? currency;
  final DateTime? createdAt;

  /// Confirmed as always populated on `POST /payments` and `GET /payments/
  /// {id}` — this bare id is a fallback for any response shape that ever
  /// sends `booking` unpopulated instead.
  String? get bookingId =>
      booking?.id.isNotEmpty == true ? booking!.id : null;

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    final bookingRaw = json['booking'] ?? json['bookingId'];
    PaymentBookingInfo? booking;
    if (bookingRaw is Map) {
      booking = PaymentBookingInfo.fromJson(Map<String, dynamic>.from(bookingRaw));
    } else if (bookingRaw != null && bookingRaw.toString().isNotEmpty) {
      booking = PaymentBookingInfo(id: bookingRaw.toString());
    }

    final payerRaw = json['payer'];
    final payeeRaw = json['payee'];
    final methodRaw = json['paymentMethod'];

    return PaymentTransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      booking: booking,
      payer: payerRaw is Map
          ? PaymentPartyInfo.fromJson(Map<String, dynamic>.from(payerRaw))
          : null,
      payee: payeeRaw is Map
          ? PaymentPartyInfo.fromJson(Map<String, dynamic>.from(payeeRaw))
          : null,
      paymentMethod: methodRaw is Map
          ? PaymentMethodModel.fromJson(Map<String, dynamic>.from(methodRaw))
          : null,
      method: json['method']?.toString(),
      externalReference: json['externalReference']?.toString(),
      receiptUrl: json['receiptUrl']?.toString(),
      status: json['status']?.toString(),
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : null,
      currency: json['currency']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

/// `{ total, page, limit, totalPages, hasNext, hasPrev }`, confirmed shape
/// for `GET /payments/my`.
class PaymentsPagination {
  const PaymentsPagination({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 0,
    this.hasNext = false,
    this.hasPrev = false,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  factory PaymentsPagination.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return PaymentsPagination(
      total: asInt(json['total']),
      page: asInt(json['page']),
      limit: asInt(json['limit']),
      totalPages: asInt(json['totalPages']),
      hasNext: json['hasNext'] == true,
      hasPrev: json['hasPrev'] == true,
    );
  }
}

// ─────────────────────────────────────────────
//  Result wrappers
// ─────────────────────────────────────────────
class PaymentMethodsResult {
  const PaymentMethodsResult({
    required this.success,
    required this.message,
    this.methods = const [],
  });

  final bool success;
  final String message;
  final List<PaymentMethodModel> methods;
}

class PaymentMethodResult {
  const PaymentMethodResult({
    required this.success,
    required this.message,
    this.method,
  });

  final bool success;
  final String message;
  final PaymentMethodModel? method;
}

class PaymentActionResult {
  const PaymentActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.message,
    this.payment,
  });

  final bool success;
  final String message;
  final PaymentTransactionModel? payment;
}

class TransactionsResult {
  const TransactionsResult({
    required this.success,
    required this.message,
    this.transactions = const [],
    this.pagination,
  });

  final bool success;
  final String message;
  final List<PaymentTransactionModel> transactions;
  final PaymentsPagination? pagination;
}
