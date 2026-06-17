class BookingStatuses {
  const BookingStatuses._();

  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String active = 'active';
  static const String completed = 'completed';
  static const String declined = 'declined';
  static const String cancelled = 'cancelled';

  static const List<String> all = <String>[
    pending,
    accepted,
    active,
    completed,
    declined,
    cancelled,
  ];
}

class QuoteRequestModel {
  const QuoteRequestModel({
    required this.dailyRate,
    required this.startDate,
    required this.endDate,
    required this.deliveryType,
    this.discountCode,
  });

  final double dailyRate;
  final String startDate;
  final String endDate;
  final String deliveryType;
  final String? discountCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dailyRate': dailyRate,
      'startDate': startDate,
      'endDate': endDate,
      'deliveryType': deliveryType,
      if ((discountCode ?? '').trim().isNotEmpty)
        'discountCode': discountCode!.trim(),
    };
  }
}

class BookingAddressModel {
  const BookingAddressModel({
    this.label,
    this.street,
    this.city,
    this.province,
  });

  final String? label;
  final String? street;
  final String? city;
  final String? province;

  factory BookingAddressModel.fromJson(Map<String, dynamic> json) {
    return BookingAddressModel(
      label: _asString(json['label']),
      street: _asString(json['street']) ?? _asString(json['address']),
      city: _asString(json['city']),
      province: _asString(json['province']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if ((label ?? '').trim().isNotEmpty) 'label': label!.trim(),
      if ((street ?? '').trim().isNotEmpty) 'street': street!.trim(),
      if ((city ?? '').trim().isNotEmpty) 'city': city!.trim(),
      if ((province ?? '').trim().isNotEmpty) 'province': province!.trim(),
    };
  }

  String get fullAddress {
    return <String>[
      (label ?? '').trim(),
      (street ?? '').trim(),
      (city ?? '').trim(),
      (province ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(', ');
  }
}

class CreateBookingRequestModel {
  const CreateBookingRequestModel({
    required this.itemId,
    required this.startDate,
    required this.endDate,
    required this.deliveryType,
    this.deliveryAddress,
    this.pickupTimeFrom,
    this.pickupTimeTo,
    this.discountCode,
  });

  final String itemId;
  final String startDate;
  final String endDate;
  final String deliveryType;
  final BookingAddressModel? deliveryAddress;
  final String? pickupTimeFrom;
  final String? pickupTimeTo;
  final String? discountCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemId': itemId,
      'startDate': startDate,
      'endDate': endDate,
      'deliveryType': deliveryType,
      if (deliveryType == 'delivery' &&
          deliveryAddress != null &&
          deliveryAddress!.toJson().isNotEmpty)
        'deliveryAddress': deliveryAddress!.toJson(),
      if (deliveryType == 'pickup' &&
          (pickupTimeFrom ?? '').trim().isNotEmpty)
        'pickupTimeFrom': pickupTimeFrom!.trim(),
      if (deliveryType == 'pickup' && (pickupTimeTo ?? '').trim().isNotEmpty)
        'pickupTimeTo': pickupTimeTo!.trim(),
      if ((discountCode ?? '').trim().isNotEmpty)
        'discountCode': discountCode!.trim(),
    };
  }
}

class BookingPricingModel {
  const BookingPricingModel({
    this.dailyRate,
    this.basePrice,
    this.discountPercent,
    this.discountAmount,
    this.subtotal,
    this.serviceFee,
    this.securityDeposit,
    this.totalAmount,
  });

  final double? dailyRate;
  final double? basePrice;
  final double? discountPercent;
  final double? discountAmount;
  final double? subtotal;
  final double? serviceFee;
  final double? securityDeposit;
  final double? totalAmount;

  factory BookingPricingModel.fromJson(Map<String, dynamic> json) {
    return BookingPricingModel(
      dailyRate: _asDouble(json['dailyRate']),
      basePrice: _asDouble(json['basePrice']),
      discountPercent: _asDouble(json['discountPercent']),
      discountAmount: _asDouble(json['discountAmount']),
      subtotal: _asDouble(json['subtotal']),
      serviceFee: _asDouble(json['serviceFee']),
      securityDeposit: _asDouble(json['securityDeposit']),
      totalAmount: _asDouble(json['totalAmount']),
    );
  }
}

class QuoteResponseModel {
  const QuoteResponseModel({
    this.totalDays,
    this.deliveryFee,
    this.pricing,
  });

  final int? totalDays;
  final double? deliveryFee;
  final BookingPricingModel? pricing;

  factory QuoteResponseModel.fromJson(Map<String, dynamic> json) {
    final pricingRaw = json['pricing'];
    final pricingMap = pricingRaw is Map
        ? pricingRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return QuoteResponseModel(
      totalDays: _asInt(json['totalDays']),
      deliveryFee: _asDouble(json['deliveryFee']),
      pricing: pricingMap == null
          ? null
          : BookingPricingModel.fromJson(pricingMap),
    );
  }
}

class BookingUserModel {
  const BookingUserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.profilePhoto,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? profilePhoto;

  factory BookingUserModel.fromJson(Map<String, dynamic> json) {
    return BookingUserModel(
      id: _asString(json['_id']) ?? _asString(json['id']),
      firstName: _asString(json['firstName']) ?? _asString(json['first_name']),
      lastName: _asString(json['lastName']) ?? _asString(json['last_name']),
      name: _asString(json['name']) ?? _asString(json['fullName']),
      profilePhoto:
          _asString(json['profilePhoto']) ?? _asString(json['avatar']),
    );
  }

  String get fullName {
    final combined = <String>[
      (firstName ?? '').trim(),
      (lastName ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    if (combined.isNotEmpty) {
      return combined;
    }
    return (name ?? '').trim();
  }
}

class BookingItemModel {
  const BookingItemModel({
    this.id,
    this.title,
    this.category,
    this.photos = const <String>[],
    this.dailyRate,
    this.currency,
  });

  final String? id;
  final String? title;
  final String? category;
  final List<String> photos;
  final double? dailyRate;
  final String? currency;

  factory BookingItemModel.fromJson(Map<String, dynamic> json) {
    return BookingItemModel(
      id: _asString(json['_id']) ?? _asString(json['id']),
      title: _asString(json['title']) ?? _asString(json['name']),
      category: _asString(json['category']),
      photos: _toStringList(json['photos']),
      dailyRate: _asDouble(json['dailyRate']),
      currency: _asString(json['currency']),
    );
  }

  String get thumbnailUrl => photos.isNotEmpty ? photos.first : '';
}

class BookingModel {
  const BookingModel({
    required this.id,
    this.itemId,
    this.item,
    this.renterId,
    this.renter,
    this.ownerId,
    this.owner,
    this.startDate,
    this.endDate,
    this.deliveryType,
    this.deliveryAddress,
    this.pickupTimeFrom,
    this.pickupTimeTo,
    this.status,
    this.pricing,
    this.preRentalPhotos = const <String>[],
    this.postRentalPhotos = const <String>[],
    this.declineReason,
    this.cancelReason,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? itemId;
  final BookingItemModel? item;
  final String? renterId;
  final BookingUserModel? renter;
  final String? ownerId;
  final BookingUserModel? owner;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? deliveryType;
  final BookingAddressModel? deliveryAddress;
  final String? pickupTimeFrom;
  final String? pickupTimeTo;
  final String? status;
  final BookingPricingModel? pricing;
  final List<String> preRentalPhotos;
  final List<String> postRentalPhotos;
  final String? declineReason;
  final String? cancelReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final itemRaw = json['item'];
    final renterRaw = json['renter'];
    final ownerRaw = json['owner'];
    final addressRaw = json['deliveryAddress'];
    final pricingRaw = json['pricing'];

    final itemMap = itemRaw is Map
        ? itemRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final renterMap = renterRaw is Map
        ? renterRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final ownerMap = ownerRaw is Map
        ? ownerRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final addressMap = addressRaw is Map
        ? addressRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final pricingMap = pricingRaw is Map
        ? pricingRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return BookingModel(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      itemId: itemRaw is String
          ? itemRaw
          : _asString(json['itemId']) ?? _asString(json['item_id']),
      item: itemMap == null ? null : BookingItemModel.fromJson(itemMap),
      renterId: renterRaw is String
          ? renterRaw
          : _asString(json['renterId']) ?? _asString(json['renter_id']),
      renter: renterMap == null ? null : BookingUserModel.fromJson(renterMap),
      ownerId: ownerRaw is String
          ? ownerRaw
          : _asString(json['ownerId']) ?? _asString(json['owner_id']),
      owner: ownerMap == null ? null : BookingUserModel.fromJson(ownerMap),
      startDate: _asDateTime(json['startDate']),
      endDate: _asDateTime(json['endDate']),
      deliveryType: _asString(json['deliveryType']),
      deliveryAddress: addressMap == null
          ? null
          : BookingAddressModel.fromJson(addressMap),
      pickupTimeFrom: _asString(json['pickupTimeFrom']),
      pickupTimeTo: _asString(json['pickupTimeTo']),
      status: _asString(json['status']),
      pricing: pricingMap == null
          ? null
          : BookingPricingModel.fromJson(pricingMap),
      preRentalPhotos: _toStringList(json['preRentalPhotos']),
      postRentalPhotos: _toStringList(json['postRentalPhotos']),
      declineReason: _asString(json['declineReason']),
      cancelReason: _asString(json['cancelReason']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  BookingModel copyWith({
    String? status,
    BookingPricingModel? pricing,
    List<String>? preRentalPhotos,
    List<String>? postRentalPhotos,
    String? declineReason,
    String? cancelReason,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id,
      itemId: itemId,
      item: item,
      renterId: renterId,
      renter: renter,
      ownerId: ownerId,
      owner: owner,
      startDate: startDate,
      endDate: endDate,
      deliveryType: deliveryType,
      deliveryAddress: deliveryAddress,
      pickupTimeFrom: pickupTimeFrom,
      pickupTimeTo: pickupTimeTo,
      status: status ?? this.status,
      pricing: pricing ?? this.pricing,
      preRentalPhotos: preRentalPhotos ?? this.preRentalPhotos,
      postRentalPhotos: postRentalPhotos ?? this.postRentalPhotos,
      declineReason: declineReason ?? this.declineReason,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get itemTitle => (item?.title ?? '').trim().isNotEmpty
      ? item!.title!.trim()
      : 'Booking Item';

  String get partnerName {
    if ((owner?.fullName ?? '').isNotEmpty) {
      return owner!.fullName;
    }
    if ((renter?.fullName ?? '').isNotEmpty) {
      return renter!.fullName;
    }
    return 'Unknown user';
  }
}

class BookingPaginationModel {
  const BookingPaginationModel({
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

  factory BookingPaginationModel.fromJson(Map<String, dynamic> json) {
    return BookingPaginationModel(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 10,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 0,
      hasNext: _asBool(json['hasNext']) ?? false,
      hasPrev: _asBool(json['hasPrev']) ?? false,
    );
  }
}

class PaginatedBookingsResponse {
  const PaginatedBookingsResponse({
    required this.success,
    required this.message,
    this.bookings = const <BookingModel>[],
    this.pagination,
  });

  final bool success;
  final String message;
  final List<BookingModel> bookings;
  final BookingPaginationModel? pagination;
}

double? _asDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
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
