class ReviewTypes {
  const ReviewTypes._();

  static const String renterToOwner = 'renter_to_owner';
  static const String ownerToRenter = 'owner_to_renter';
  static const String renterToItem = 'renter_to_item';

  static const List<String> all = <String>[
    renterToOwner,
    ownerToRenter,
    renterToItem,
  ];
}

class CreateReviewRequestModel {
  const CreateReviewRequestModel({
    required this.bookingId,
    required this.type,
    required this.rating,
    required this.comment,
  });

  final String bookingId;
  final String type;
  final int rating;
  final String comment;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bookingId': bookingId,
      'type': type,
      'rating': rating,
      'comment': comment,
    };
  }
}

class ReviewUserModel {
  const ReviewUserModel({this.id, this.firstName, this.lastName, this.profilePhoto});

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? profilePhoto;

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: _asString(json['_id']) ?? _asString(json['id']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      profilePhoto: _asString(json['profilePhoto']) ?? _asString(json['avatar']),
    );
  }

  /// `reviewee` arrives as a bare id string on some review-list endpoints
  /// (confirmed: `GET /reviews/user/:id`) rather than the populated object
  /// other endpoints send — this keeps at least the id instead of losing it.
  factory ReviewUserModel.fromId(String id) => ReviewUserModel(id: id);

  String get fullName {
    final combined = <String>[
      (firstName ?? '').trim(),
      (lastName ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    return combined.isNotEmpty ? combined : 'Zip Rental user';
  }
}

class ReviewItemModel {
  const ReviewItemModel({this.id, this.title, this.photos = const <String>[]});

  final String? id;
  final String? title;
  final List<String> photos;

  factory ReviewItemModel.fromJson(Map<String, dynamic> json) {
    return ReviewItemModel(
      id: _asString(json['_id']) ?? _asString(json['id']),
      title: _asString(json['title']),
      photos: _toStringList(json['photos']),
    );
  }

  /// `item` arrives as a bare id string on some review-list endpoints
  /// (confirmed: `GET /reviews/item/:id`) rather than the populated object
  /// other endpoints send — this keeps at least the id instead of losing it.
  factory ReviewItemModel.fromId(String id) => ReviewItemModel(id: id);

  String get thumbnailUrl => photos.isNotEmpty ? photos.first : '';
}

/// The populated `booking` on a review — confirmed shape (2026-09-29, via
/// `GET /reviews/admin/all` returning real seed data): `{ _id, startDate,
/// endDate }`, an object, not a bare id string.
class ReviewBookingInfo {
  const ReviewBookingInfo({required this.id, this.startDate, this.endDate});

  final String id;
  final DateTime? startDate;
  final DateTime? endDate;

  factory ReviewBookingInfo.fromJson(Map<String, dynamic> json) {
    return ReviewBookingInfo(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      startDate: _asDateTime(json['startDate']),
      endDate: _asDateTime(json['endDate']),
    );
  }
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    this.booking,
    this.reviewer,
    this.reviewee,
    this.item,
    this.type,
    this.rating,
    this.comment,
    this.createdAt,
  });

  final String id;
  final ReviewBookingInfo? booking;
  final ReviewUserModel? reviewer;
  /// Absent on `renter_to_item` reviews (confirmed) — those are about the
  /// item, not a person, so there's no reviewee to show.
  final ReviewUserModel? reviewee;
  final ReviewItemModel? item;
  final String? type;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;

  String? get bookingId => booking?.id.isNotEmpty == true ? booking!.id : null;
  String? get revieweeId => reviewee?.id;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final bookingRaw = json['booking'];
    final reviewerRaw = json['reviewer'];
    final revieweeRaw = json['reviewee'];
    final itemRaw = json['item'];

    final bookingMap = bookingRaw is Map
        ? bookingRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final reviewerMap = reviewerRaw is Map
        ? reviewerRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final revieweeMap = revieweeRaw is Map
        ? revieweeRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final itemMap = itemRaw is Map
        ? itemRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    ReviewBookingInfo? booking;
    if (bookingMap != null) {
      booking = ReviewBookingInfo.fromJson(bookingMap);
    } else if (bookingRaw is String && bookingRaw.trim().isNotEmpty) {
      booking = ReviewBookingInfo(id: bookingRaw.trim());
    } else {
      final fallbackId =
          _asString(json['bookingId']) ?? _asString(json['booking_id']);
      booking = fallbackId == null ? null : ReviewBookingInfo(id: fallbackId);
    }

    // `reviewer`/`reviewee`/`item` are populated objects on most endpoints
    // but confirmed as bare id strings on others (e.g. `reviewee` on
    // `GET /reviews/user/:id`, `item` on `GET /reviews/item/:id`) — keep at
    // least the id in that case rather than silently dropping it.
    ReviewUserModel? reviewer = reviewerMap == null
        ? null
        : ReviewUserModel.fromJson(reviewerMap);
    if (reviewer == null && reviewerRaw is String && reviewerRaw.trim().isNotEmpty) {
      reviewer = ReviewUserModel.fromId(reviewerRaw.trim());
    }

    ReviewUserModel? reviewee = revieweeMap == null
        ? null
        : ReviewUserModel.fromJson(revieweeMap);
    if (reviewee == null && revieweeRaw is String && revieweeRaw.trim().isNotEmpty) {
      reviewee = ReviewUserModel.fromId(revieweeRaw.trim());
    }

    ReviewItemModel? item = itemMap == null
        ? null
        : ReviewItemModel.fromJson(itemMap);
    if (item == null && itemRaw is String && itemRaw.trim().isNotEmpty) {
      item = ReviewItemModel.fromId(itemRaw.trim());
    }

    return ReviewModel(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      booking: booking,
      reviewer: reviewer,
      reviewee: reviewee,
      item: item,
      type: _asString(json['type']),
      rating: _asInt(json['rating']),
      comment: _asString(json['comment']),
      createdAt: _asDateTime(json['createdAt']),
    );
  }
}

class ReviewPaginationModel {
  const ReviewPaginationModel({
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

  factory ReviewPaginationModel.fromJson(Map<String, dynamic> json) {
    return ReviewPaginationModel(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 10,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 0,
      hasNext: _asBool(json['hasNext']) ?? false,
      hasPrev: _asBool(json['hasPrev']) ?? false,
    );
  }
}

class PaginatedReviewsResponse {
  const PaginatedReviewsResponse({
    required this.success,
    required this.message,
    this.reviews = const <ReviewModel>[],
    this.pagination,
  });

  final bool success;
  final String message;
  final List<ReviewModel> reviews;
  final ReviewPaginationModel? pagination;
}

class PendingReviewModel {
  const PendingReviewModel({
    required this.bookingId,
    this.itemTitle,
    this.itemPhoto,
    this.pendingTypes = const <String>[],
  });

  final String bookingId;
  final String? itemTitle;
  final String? itemPhoto;
  final List<String> pendingTypes;

  factory PendingReviewModel.fromJson(Map<String, dynamic> json) {
    final bookingRaw = json['booking'];
    final bookingMap = bookingRaw is Map
        ? bookingRaw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final itemRaw = bookingMap['item'];
    final itemMap = itemRaw is Map
        ? itemRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final photos = itemMap == null ? const <String>[] : _toStringList(itemMap['photos']);

    return PendingReviewModel(
      bookingId: _asString(bookingMap['_id']) ?? _asString(bookingMap['id']) ?? '',
      itemTitle: itemMap == null ? null : _asString(itemMap['title']),
      itemPhoto: photos.isNotEmpty ? photos.first : null,
      // Growable, unlike `_toStringList`'s own fixed-length result —
      // ReviewController.submitReview() calls `.remove()` on this list in
      // place, which throws UnsupportedError on a fixed-length list.
      pendingTypes: List<String>.from(_toStringList(json['pendingTypes'])),
    );
  }
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
