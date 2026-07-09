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

  String get thumbnailUrl => photos.isNotEmpty ? photos.first : '';
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    this.bookingId,
    this.reviewer,
    this.revieweeId,
    this.reviewee,
    this.item,
    this.type,
    this.rating,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String? bookingId;
  final ReviewUserModel? reviewer;
  final String? revieweeId;
  final ReviewUserModel? reviewee;
  final ReviewItemModel? item;
  final String? type;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final bookingRaw = json['booking'];
    final reviewerRaw = json['reviewer'];
    final revieweeRaw = json['reviewee'];
    final itemRaw = json['item'];

    final reviewerMap = reviewerRaw is Map
        ? reviewerRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final revieweeMap = revieweeRaw is Map
        ? revieweeRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final itemMap = itemRaw is Map
        ? itemRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return ReviewModel(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      bookingId: bookingRaw is String
          ? bookingRaw
          : _asString(json['bookingId']) ?? _asString(json['booking_id']),
      reviewer: reviewerMap == null ? null : ReviewUserModel.fromJson(reviewerMap),
      revieweeId: revieweeRaw is String
          ? revieweeRaw
          : _asString(json['revieweeId']),
      reviewee: revieweeMap == null ? null : ReviewUserModel.fromJson(revieweeMap),
      item: itemMap == null ? null : ReviewItemModel.fromJson(itemMap),
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
      pendingTypes: _toStringList(json['pendingTypes']),
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
