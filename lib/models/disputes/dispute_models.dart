/// Reason enum confirmed live (2026-09-29) via a validation error from
/// `POST /disputes` with a bogus reason: the API rejected it with
/// `"reason" must be one of [item_damaged, item_not_returned,
/// item_not_as_described, late_return, no_show, payment_issue, other]`.
class DisputeReasons {
  const DisputeReasons._();

  static const String itemDamaged = 'item_damaged';
  static const String itemNotReturned = 'item_not_returned';
  static const String itemNotAsDescribed = 'item_not_as_described';
  static const String lateReturn = 'late_return';
  static const String noShow = 'no_show';
  static const String paymentIssue = 'payment_issue';
  static const String other = 'other';

  static const List<String> all = <String>[
    itemDamaged,
    itemNotReturned,
    itemNotAsDescribed,
    lateReturn,
    noShow,
    paymentIssue,
    other,
  ];

  static const Map<String, String> labels = <String, String>{
    itemDamaged: 'Item Damaged',
    itemNotReturned: 'Item Not Returned',
    itemNotAsDescribed: 'Item Not As Described',
    lateReturn: 'Late Return',
    noShow: 'No Show',
    paymentIssue: 'Payment Issue',
    other: 'Other',
  };

  static String labelFor(String? reason) => labels[reason] ?? 'Other';
}

/// `open`/`closed` are the only statuses this app ever sets (cancelling a
/// dispute moves it to `closed`, confirmed live — there's no separate
/// `cancelled` value). The other four are admin-only outcomes (confirmed as
/// the full, validated set via `GET /disputes/my?status=` live, 2026-10-01)
/// that can still show up on a dispute the other party had resolved; status
/// display falls back to a prettified raw string rather than restricting to
/// these, so an admin outcome always renders sensibly without a dedicated tab.
class DisputeStatuses {
  const DisputeStatuses._();

  static const String open = 'open';
  static const String closed = 'closed';
  static const String underReview = 'under_review';
  static const String resolvedForRenter = 'resolved_for_renter';
  static const String resolvedForOwner = 'resolved_for_owner';
  static const String resolvedMutually = 'resolved_mutually';
}

/// Who the current user is on a given dispute, as told directly by the
/// server (`myRole`, added 2026-10-01) rather than inferred by comparing
/// ids client-side. Confirmed live on `GET /disputes/my`, `GET /disputes/:id`
/// and the evidence-upload response; not confirmed on the create/cancel
/// action responses, so callers should fall back to an id comparison when
/// `myRole` is absent.
class DisputeRoles {
  const DisputeRoles._();

  static const String reporter = 'reporter';
  static const String reportedAgainst = 'reported_against';
}

class CreateDisputeRequestModel {
  const CreateDisputeRequestModel({
    required this.bookingId,
    required this.reason,
    required this.description,
  });

  final String bookingId;
  final String reason;
  final String description;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bookingId': bookingId,
      'reason': reason,
      'description': description,
    };
  }
}

class DisputeUserModel {
  const DisputeUserModel({this.id, this.firstName, this.lastName, this.profilePhoto});

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? profilePhoto;

  factory DisputeUserModel.fromJson(Map<String, dynamic> json) {
    return DisputeUserModel(
      id: _asString(json['_id']) ?? _asString(json['id']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      profilePhoto: _asString(json['profilePhoto']),
    );
  }

  /// `reportedBy`/`reportedAgainst` arrive as a bare id string on some
  /// responses (confirmed live: both on `POST /disputes`, and `reportedBy`
  /// alone on `GET /disputes/my`) rather than the populated object other
  /// responses send — this keeps at least the id instead of losing it.
  factory DisputeUserModel.fromId(String id) => DisputeUserModel(id: id);

  String get fullName {
    final combined = <String>[
      (firstName ?? '').trim(),
      (lastName ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    return combined.isNotEmpty ? combined : 'Zip Rental user';
  }
}

/// The `booking` field on a dispute — confirmed shape (2026-09-29, live):
/// a bare id string on `POST /disputes`, `{_id, startDate, endDate,
/// status}` on `GET /disputes/my`, and additionally an `item` id string on
/// `GET /disputes/:id`.
class DisputeBookingInfo {
  const DisputeBookingInfo({
    required this.id,
    this.itemId,
    this.startDate,
    this.endDate,
    this.status,
  });

  final String id;
  final String? itemId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;

  factory DisputeBookingInfo.fromJson(Map<String, dynamic> json) {
    return DisputeBookingInfo(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      itemId: _asString(json['item']),
      startDate: _asDateTime(json['startDate']),
      endDate: _asDateTime(json['endDate']),
      status: _asString(json['status']),
    );
  }
}

class DisputeModel {
  const DisputeModel({
    required this.id,
    this.booking,
    this.reportedBy,
    this.reportedAgainst,
    this.reason,
    this.description,
    this.evidence = const <String>[],
    this.status,
    this.createdAt,
    this.updatedAt,
    this.myRole,
    this.evidenceUrlsExpireAt,
  });

  final String id;
  final DisputeBookingInfo? booking;
  final DisputeUserModel? reportedBy;
  final DisputeUserModel? reportedAgainst;
  final String? reason;
  final String? description;
  final List<String> evidence;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? myRole;

  /// `evidence[]` URLs are presigned S3 links valid for ~1 hour (added
  /// 2026-10-01, fixing a prior 403 on raw unsigned URLs). Never persist
  /// these — re-fetch the dispute for fresh links once they're close to or
  /// past this timestamp.
  final DateTime? evidenceUrlsExpireAt;

  String? get bookingId => booking?.id.isNotEmpty == true ? booking!.id : null;
  bool get isOpen => (status ?? '').toLowerCase() == DisputeStatuses.open;

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    final bookingRaw = json['booking'];
    final reportedByRaw = json['reportedBy'];
    final reportedAgainstRaw = json['reportedAgainst'];

    final bookingMap = bookingRaw is Map
        ? bookingRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final reportedByMap = reportedByRaw is Map
        ? reportedByRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final reportedAgainstMap = reportedAgainstRaw is Map
        ? reportedAgainstRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    DisputeBookingInfo? booking;
    if (bookingMap != null) {
      booking = DisputeBookingInfo.fromJson(bookingMap);
    } else if (bookingRaw is String && bookingRaw.trim().isNotEmpty) {
      booking = DisputeBookingInfo(id: bookingRaw.trim());
    } else {
      final fallbackId =
          _asString(json['bookingId']) ?? _asString(json['booking_id']);
      booking = fallbackId == null ? null : DisputeBookingInfo(id: fallbackId);
    }

    DisputeUserModel? reportedBy = reportedByMap == null
        ? null
        : DisputeUserModel.fromJson(reportedByMap);
    if (reportedBy == null &&
        reportedByRaw is String &&
        reportedByRaw.trim().isNotEmpty) {
      reportedBy = DisputeUserModel.fromId(reportedByRaw.trim());
    }

    DisputeUserModel? reportedAgainst = reportedAgainstMap == null
        ? null
        : DisputeUserModel.fromJson(reportedAgainstMap);
    if (reportedAgainst == null &&
        reportedAgainstRaw is String &&
        reportedAgainstRaw.trim().isNotEmpty) {
      reportedAgainst = DisputeUserModel.fromId(reportedAgainstRaw.trim());
    }

    return DisputeModel(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      booking: booking,
      reportedBy: reportedBy,
      reportedAgainst: reportedAgainst,
      reason: _asString(json['reason']),
      description: _asString(json['description']),
      evidence: _toStringList(json['evidence']),
      status: _asString(json['status']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      myRole: _asString(json['myRole']),
      evidenceUrlsExpireAt: _asDateTime(json['evidenceUrlsExpireAt']),
    );
  }
}

class DisputePaginationModel {
  const DisputePaginationModel({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 0,
    this.hasNext = false,
    this.hasPrev = false,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  factory DisputePaginationModel.fromJson(Map<String, dynamic> json) {
    return DisputePaginationModel(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 10,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 0,
      hasNext: _asBool(json['hasNext']) ?? false,
      hasPrev: _asBool(json['hasPrev']) ?? false,
    );
  }
}

class PaginatedDisputesResponse {
  const PaginatedDisputesResponse({
    required this.success,
    required this.message,
    this.disputes = const <DisputeModel>[],
    this.pagination,
  });

  final bool success;
  final String message;
  final List<DisputeModel> disputes;
  final DisputePaginationModel? pagination;
}

int? _asInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1') {
    return true;
  }
  if (normalized == 'false' || normalized == '0') {
    return false;
  }
  return null;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value.toString());
}

String? _asString(dynamic value) {
  if (value == null) {
    return null;
  }
  final normalized = value.toString().trim();
  if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
    return null;
  }
  return normalized;
}

List<String> _toStringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .map((element) => _asString(element))
      .whereType<String>()
      .toList(growable: false);
}
