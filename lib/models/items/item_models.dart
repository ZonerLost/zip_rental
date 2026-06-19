class DeliveryPricingTier {
  const DeliveryPricingTier({required this.maxKm, required this.price});

  final int maxKm;
  final double price;

  factory DeliveryPricingTier.fromJson(Map<String, dynamic> json) {
    return DeliveryPricingTier(
      maxKm: _asInt(json['maxKm']) ?? 0,
      price: _asDouble(json['price']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'maxKm': maxKm, 'price': price};
}

class DayScheduleModel {
  const DayScheduleModel({
    required this.enabled,
    this.startTime,
    this.endTime,
  });

  final bool enabled;
  final String? startTime;
  final String? endTime;

  Map<String, dynamic> toJson() {
    if (!enabled) return {'enabled': false};
    return {
      'enabled': true,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}

class WeeklyScheduleModel {
  const WeeklyScheduleModel({
    required this.recurringDays,
    this.scheduleType = 'recurring',
  });

  final Map<String, DayScheduleModel> recurringDays;
  final String scheduleType;

  Map<String, dynamic> toJson() {
    return {
      'scheduleType': scheduleType,
      'recurringDays': recurringDays.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}

class FormConfigModel {
  const FormConfigModel({
    this.categories = const [],
    this.conditions = const [],
    this.bookingTypes = const [],
  });

  final List<String> categories;
  final List<String> conditions;
  final List<String> bookingTypes;

  factory FormConfigModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map
        ? data.map((k, v) => MapEntry(k.toString(), v))
        : json;
    return FormConfigModel(
      categories: _toConfigStringList(map['categories']),
      conditions: _toConfigStringList(map['conditions']),
      bookingTypes: _toStringList(map['bookingTypes']),
    );
  }
}

class BoostConfigModel {
  const BoostConfigModel({
    this.price = 9.99,
    this.currency = 'CAD',
    this.durationDays = 7,
  });

  final double price;
  final String currency;
  final int durationDays;

  factory BoostConfigModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final map = data is Map
        ? data.map((k, v) => MapEntry(k.toString(), v))
        : json;
    return BoostConfigModel(
      price: _asDouble(map['price']) ?? 9.99,
      currency: _asString(map['currency']) ?? 'CAD',
      durationDays: _asInt(map['durationDays']) ?? 7,
    );
  }
}

class BoostResult {
  const BoostResult({
    required this.success,
    required this.message,
    this.isBoosted,
    this.boostedAt,
    this.boostExpiresAt,
    this.noCredits = false,
  });

  final bool success;
  final String message;
  final bool? isBoosted;
  final DateTime? boostedAt;
  final DateTime? boostExpiresAt;
  final bool noCredits;
}

class LanguageModel {
  const LanguageModel({required this.code, required this.label, required this.nativeLabel});

  final String code;
  final String label;
  final String nativeLabel;

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: _asString(json['code']) ?? '',
      label: _asString(json['label']) ?? '',
      nativeLabel: _asString(json['nativeLabel']) ?? '',
    );
  }
}

class CoordinatesModel {
  const CoordinatesModel({this.lat, this.lng});

  final double? lat;
  final double? lng;

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }
}

class ItemLocationModel {
  const ItemLocationModel({
    this.address,
    this.city,
    this.province,
    this.country,
    this.coordinates,
  });

  final String? address;
  final String? city;
  final String? province;
  final String? country;
  final CoordinatesModel? coordinates;

  factory ItemLocationModel.fromJson(Map<String, dynamic> json) {
    final rawCoordinates = json['coordinates'];
    final coordinatesMap = rawCoordinates is Map
        ? rawCoordinates.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return ItemLocationModel(
      address: _asString(json['address']),
      city: _asString(json['city']),
      province: _asString(json['province']),
      country: _asString(json['country']),
      coordinates: coordinatesMap == null
          ? null
          : CoordinatesModel.fromJson(coordinatesMap),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if ((address ?? '').trim().isNotEmpty) 'address': address!.trim(),
      if ((city ?? '').trim().isNotEmpty) 'city': city!.trim(),
      if ((province ?? '').trim().isNotEmpty) 'province': province!.trim(),
      if ((country ?? '').trim().isNotEmpty) 'country': country!.trim(),
      if (coordinates != null && coordinates!.toJson().isNotEmpty)
        'coordinates': coordinates!.toJson(),
    };
  }

  String get fullLocation {
    final parts = <String>[
      (city ?? '').trim(),
      (province ?? '').trim(),
      (country ?? '').trim(),
    ].where((part) => part.isNotEmpty).toList(growable: false);

    return parts.join(', ');
  }
}

class OwnerModel {
  const OwnerModel({
    this.id,
    this.firstName,
    this.lastName,
    this.averageRating,
    this.profilePhoto,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final double? averageRating;
  final String? profilePhoto;

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: _asString(json['_id']) ?? _asString(json['id']),
      firstName: _asString(json['firstName']) ?? _asString(json['first_name']),
      lastName: _asString(json['lastName']) ?? _asString(json['last_name']),
      averageRating:
          _asDouble(json['averageRating']) ?? _asDouble(json['rating']),
      profilePhoto:
          _asString(json['profilePhoto']) ?? _asString(json['avatar']),
    );
  }

  String get fullName =>
      '${(firstName ?? '').trim()} ${(lastName ?? '').trim()}'.trim();
}

class ItemAvailabilityModel {
  const ItemAvailabilityModel({this.isAvailable, this.blockedDates = const []});

  final bool? isAvailable;
  final List<String> blockedDates;

  factory ItemAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return ItemAvailabilityModel(
      isAvailable: _asBool(json['isAvailable']),
      blockedDates: _toStringList(json['blockedDates']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (blockedDates.isNotEmpty) 'blockedDates': blockedDates,
    };
  }
}

class ItemModel {
  const ItemModel({
    required this.id,
    this.ownerId,
    this.owner,
    this.location,
    this.availability,
    this.title,
    this.description,
    this.category,
    this.subCategory,
    this.photos = const [],
    this.dailyRate,
    this.currency,
    this.condition,
    this.bookingType,
    this.deliveryFee,
    this.deliveryPricing = const [],
    this.isFeatured,
    this.isBoosted,
    this.boostedAt,
    this.boostExpiresAt,
    this.averageRating,
    this.totalReviews,
    this.totalRentals,
    this.isActive,
    this.isPaused,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? ownerId;
  final OwnerModel? owner;
  final ItemLocationModel? location;
  final ItemAvailabilityModel? availability;
  final String? title;
  final String? description;
  final String? category;
  final String? subCategory;
  final List<String> photos;
  final double? dailyRate;
  final String? currency;
  final String? condition;
  final String? bookingType;
  final double? deliveryFee;
  final List<DeliveryPricingTier> deliveryPricing;
  final bool? isFeatured;
  final bool? isBoosted;
  final DateTime? boostedAt;
  final DateTime? boostExpiresAt;
  final double? averageRating;
  final int? totalReviews;
  final int? totalRentals;
  final bool? isActive;
  final bool? isPaused;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final ownerRaw = json['owner'];
    final ownerMap = ownerRaw is Map
        ? ownerRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;
    final ownerId = ownerRaw is String
        ? ownerRaw
        : _asString(json['ownerId']) ??
            _asString(json['owner_id']) ??
            _asString(json['owner']);

    final locationRaw = json['location'];
    final locationMap = locationRaw is Map
        ? locationRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    final availabilityRaw = json['availability'];
    final availabilityMap = availabilityRaw is Map
        ? availabilityRaw.map((key, value) => MapEntry(key.toString(), value))
        : null;

    return ItemModel(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? '',
      ownerId: ownerId,
      owner: ownerMap == null ? null : OwnerModel.fromJson(ownerMap),
      location: locationMap == null
          ? null
          : ItemLocationModel.fromJson(locationMap),
      availability: availabilityMap == null
          ? null
          : ItemAvailabilityModel.fromJson(availabilityMap),
      title: _asString(json['title']),
      description: _asString(json['description']),
      category: _asString(json['category']),
      subCategory: _asString(json['subCategory']),
      photos: _toStringList(json['photos']),
      dailyRate: _asDouble(json['dailyRate']),
      currency: _asString(json['currency']),
      condition: _asString(json['condition']),
      bookingType: _asString(json['bookingType']),
      deliveryFee: _asDouble(json['deliveryFee']),
      deliveryPricing: _parseDeliveryPricing(json['deliveryPricing']),
      isFeatured: _asBool(json['isFeatured']),
      isBoosted: _asBool(json['isBoosted']),
      boostedAt: _asDateTime(json['boostedAt']),
      boostExpiresAt: _asDateTime(json['boostExpiresAt']),
      averageRating: _asDouble(json['averageRating']),
      totalReviews: _asInt(json['totalReviews']),
      totalRentals: _asInt(json['totalRentals']),
      isActive: _asBool(json['isActive']),
      isPaused: _asBool(json['isPaused']),
      tags: _toStringList(json['tags']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  String get thumbnailUrl => photos.isNotEmpty ? photos.first : '';

  String get ownerName {
    final name = owner?.fullName ?? '';
    return name.isEmpty ? 'Unknown owner' : name;
  }

  ItemModel copyWith({
    OwnerModel? owner,
    ItemLocationModel? location,
    ItemAvailabilityModel? availability,
    String? title,
    String? description,
    String? category,
    String? subCategory,
    List<String>? photos,
    double? dailyRate,
    String? currency,
    String? condition,
    String? bookingType,
    double? deliveryFee,
    List<DeliveryPricingTier>? deliveryPricing,
    bool? isFeatured,
    bool? isBoosted,
    DateTime? boostedAt,
    DateTime? boostExpiresAt,
    double? averageRating,
    int? totalReviews,
    int? totalRentals,
    bool? isActive,
    bool? isPaused,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id,
      ownerId: ownerId,
      owner: owner ?? this.owner,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      photos: photos ?? this.photos,
      dailyRate: dailyRate ?? this.dailyRate,
      currency: currency ?? this.currency,
      condition: condition ?? this.condition,
      bookingType: bookingType ?? this.bookingType,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryPricing: deliveryPricing ?? this.deliveryPricing,
      isFeatured: isFeatured ?? this.isFeatured,
      isBoosted: isBoosted ?? this.isBoosted,
      boostedAt: boostedAt ?? this.boostedAt,
      boostExpiresAt: boostExpiresAt ?? this.boostExpiresAt,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalRentals: totalRentals ?? this.totalRentals,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FeedResponse {
  const FeedResponse({
    required this.success,
    required this.message,
    this.nearMe = const [],
    this.popular = const [],
    this.recent = const [],
  });

  final bool success;
  final String message;
  final List<ItemModel> nearMe;
  final List<ItemModel> popular;
  final List<ItemModel> recent;
}

class PaginationModel {
  const PaginationModel({
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

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 10,
      total: _asInt(json['total']) ?? 0,
      totalPages: _asInt(json['totalPages']) ?? 0,
      hasNext: _asBool(json['hasNext']) ?? false,
      hasPrev: _asBool(json['hasPrev']) ?? false,
    );
  }
}

class ItemsResponseModel {
  const ItemsResponseModel({
    required this.success,
    required this.message,
    this.items = const [],
    this.pagination,
    this.raw,
  });

  final bool success;
  final String message;
  final List<ItemModel> items;
  final PaginationModel? pagination;
  final Map<String, dynamic>? raw;
}

class PaginatedItemsResponse {
  const PaginatedItemsResponse({
    required this.success,
    required this.message,
    this.items = const [],
    this.pagination,
    this.raw,
  });

  final bool success;
  final String message;
  final List<ItemModel> items;
  final PaginationModel? pagination;
  final Map<String, dynamic>? raw;
}

class DeliveryOptionsModel {
  const DeliveryOptionsModel({
    this.pickup = false,
    this.delivery = false,
    this.deliveryRadius,
  });

  final bool pickup;
  final bool delivery;
  final int? deliveryRadius;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pickup': pickup,
        'delivery': delivery,
        if (deliveryRadius != null) 'deliveryRadius': deliveryRadius,
      };
}

class ItemAvailabilityRangeModel {
  const ItemAvailabilityRangeModel({
    required this.availableFrom,
    required this.availableTo,
  });

  final String availableFrom; // ISO date string e.g. "2026-06-01"
  final String availableTo;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'availableFrom': availableFrom,
        'availableTo': availableTo,
      };
}

class CreateItemRequest {
  const CreateItemRequest({
    required this.title,
    required this.description,
    required this.category,
    this.subCategory,
    required this.dailyRate,
    this.weeklyRate,
    this.monthlyRate,
    this.depositAmount,
    this.minRentalDays = 1,
    this.maxRentalDays = 30,
    this.quantity = 1,
    this.currency = 'CAD',
    required this.condition,
    this.bookingType,
    required this.location,
    this.deliveryOptions,
    this.deliveryFee,
    this.deliveryPricing = const [],
    this.availability,
    this.tags = const [],
  });

  final String title;
  final String description;
  final String category;
  final String? subCategory;
  final double dailyRate;
  final double? weeklyRate;
  final double? monthlyRate;
  final double? depositAmount;
  final int minRentalDays;
  final int maxRentalDays;
  final int quantity;
  final String currency;
  final String condition;
  final String? bookingType;
  final ItemLocationModel location;
  final DeliveryOptionsModel? deliveryOptions;
  final double? deliveryFee;
  final List<DeliveryPricingTier> deliveryPricing;
  final ItemAvailabilityRangeModel? availability;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'category': category.trim(),
      if ((subCategory ?? '').trim().isNotEmpty)
        'subCategory': subCategory!.trim(),
      'dailyRate': dailyRate,
      if (weeklyRate != null) 'weeklyRate': weeklyRate,
      if (monthlyRate != null) 'monthlyRate': monthlyRate,
      if (depositAmount != null) 'depositAmount': depositAmount,
      'minRentalDays': minRentalDays,
      'maxRentalDays': maxRentalDays,
      'quantity': quantity,
      'currency': currency,
      'condition': condition.trim(),
      if ((bookingType ?? '').trim().isNotEmpty) 'bookingType': bookingType!.trim(),
      'location': location.toJson(),
      if (deliveryOptions != null) 'deliveryOptions': deliveryOptions!.toJson(),
      if (deliveryFee != null) 'deliveryFee': deliveryFee,
      if (deliveryPricing.isNotEmpty)
        'deliveryPricing': deliveryPricing.map((t) => t.toJson()).toList(),
      if (availability != null) 'availability': availability!.toJson(),
      if (tags.isNotEmpty) 'tags': tags,
    };
  }
}

class UpdateItemRequest {
  const UpdateItemRequest({
    this.title,
    this.description,
    this.dailyRate,
    this.condition,
    this.bookingType,
    this.deliveryFee,
    this.deliveryPricing,
    this.tags,
  });

  final String? title;
  final String? description;
  final double? dailyRate;
  final String? condition;
  final String? bookingType;
  final double? deliveryFee;
  final List<DeliveryPricingTier>? deliveryPricing;
  final List<String>? tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      if (dailyRate != null) 'dailyRate': dailyRate,
      if (condition != null && condition!.trim().isNotEmpty)
        'condition': condition!.trim(),
      if (bookingType != null && bookingType!.trim().isNotEmpty)
        'bookingType': bookingType!.trim(),
      if (deliveryFee != null) 'deliveryFee': deliveryFee,
      if (deliveryPricing != null && deliveryPricing!.isNotEmpty)
        'deliveryPricing': deliveryPricing!.map((t) => t.toJson()).toList(),
      if (tags != null) 'tags': tags,
    };
  }
}

List<DeliveryPricingTier> _parseDeliveryPricing(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => DeliveryPricingTier.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
      .toList(growable: false);
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

// Used for form-config categories/conditions: extracts 'label' when the API
// returns objects like {label: 'Electronics', value: 'electronics'}, falls
// back to 'value', then plain string conversion.
List<String> _toConfigStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value.map<String?>((element) {
    if (element is Map) {
      final label = element['label']?.toString().trim();
      if (label != null && label.isNotEmpty) return label;
      final v = element['value']?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
      return null;
    }
    return _asString(element);
  }).whereType<String>().where((s) => s.isNotEmpty).toList(growable: false);
}
