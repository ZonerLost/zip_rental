/// Fixed badge thresholds documented by the API (Module 6 spec). The backend
/// is still the source of truth for which badge a user currently holds
/// (see [EcoBadgeModel] from `badge`/`nextBadge` in the my-impact response);
/// this table exists so the UI can render progress for badges the backend
/// doesn't explicitly return (e.g. tiers already cleared, or all four tiers
/// at once).
class EcoBadgeThresholds {
  const EcoBadgeThresholds._();

  static const String ecoStarter = 'eco_starter';
  static const String greenAchiever = 'green_achiever';
  static const String planetHero = 'planet_hero';
  static const String impactLegend = 'impact_legend';

  static const List<EcoBadgeModel> all = <EcoBadgeModel>[
    EcoBadgeModel(id: ecoStarter, label: 'Eco Starter', minCO2: 0),
    EcoBadgeModel(id: greenAchiever, label: 'Green Achiever', minCO2: 50),
    EcoBadgeModel(id: planetHero, label: 'Planet Hero', minCO2: 200),
    EcoBadgeModel(id: impactLegend, label: 'Impact Legend', minCO2: 500),
  ];
}

class EcoBadgeModel {
  const EcoBadgeModel({
    required this.id,
    required this.label,
    required this.minCO2,
    this.co2Remaining,
  });

  final String id;
  final String label;
  final double minCO2;
  /// Only present on `nextBadge` — how much more CO2 (kg) is needed to reach it.
  final double? co2Remaining;

  factory EcoBadgeModel.fromJson(Map<String, dynamic> json) {
    return EcoBadgeModel(
      id: _asString(json['id']) ?? _asString(json['badgeId']) ?? '',
      label: _asString(json['label']) ?? _asString(json['name']) ?? '',
      minCO2: _asDouble(json['minCO2']) ?? 0,
      co2Remaining: _asDouble(json['co2Remaining']),
    );
  }
}

class EcoLifetimeStatsModel {
  const EcoLifetimeStatsModel({
    this.totalCO2 = 0,
    this.totalKm = 0,
    this.totalRentals = 0,
    this.equivalence,
  });

  final double totalCO2;
  final double totalKm;
  final int totalRentals;
  final String? equivalence;

  factory EcoLifetimeStatsModel.fromJson(Map<String, dynamic> json) {
    return EcoLifetimeStatsModel(
      totalCO2: _asDouble(json['totalCO2']) ?? 0,
      totalKm: _asDouble(json['totalKm']) ?? 0,
      totalRentals: _asInt(json['totalRentals']) ?? 0,
      equivalence: _asString(json['equivalence']),
    );
  }
}

class MyEcoImpactModel {
  const MyEcoImpactModel({
    required this.lifetime,
    this.period,
    this.badge,
    this.nextBadge,
  });

  final EcoLifetimeStatsModel lifetime;
  /// Populated when the `period` (month/year) query param is used. The spec
  /// only documents the lifetime-only response shape, so this is parsed
  /// defensively from a `period` key if the backend includes one alongside
  /// `lifetime`.
  final EcoLifetimeStatsModel? period;
  final EcoBadgeModel? badge;
  final EcoBadgeModel? nextBadge;

  factory MyEcoImpactModel.fromJson(Map<String, dynamic> json) {
    final lifetimeRaw = json['lifetime'];
    final periodRaw = json['period'];
    final badgeRaw = json['badge'];
    final nextBadgeRaw = json['nextBadge'];

    return MyEcoImpactModel(
      lifetime: lifetimeRaw is Map
          ? EcoLifetimeStatsModel.fromJson(_stringKeyMap(lifetimeRaw))
          // Fall back to reading the stats straight off the root object, in
          // case the backend flattens the response instead of nesting it.
          : EcoLifetimeStatsModel.fromJson(json),
      period: periodRaw is Map
          ? EcoLifetimeStatsModel.fromJson(_stringKeyMap(periodRaw))
          : null,
      badge: badgeRaw is Map ? EcoBadgeModel.fromJson(_stringKeyMap(badgeRaw)) : null,
      nextBadge: nextBadgeRaw is Map
          ? EcoBadgeModel.fromJson(_stringKeyMap(nextBadgeRaw))
          : null,
    );
  }
}

class BookingEcoImpactModel {
  const BookingEcoImpactModel({
    this.co2SavedKg = 0,
    this.kmEquivalent = 0,
    this.category,
    this.message,
  });

  final double co2SavedKg;
  final double kmEquivalent;
  final String? category;
  final String? message;

  factory BookingEcoImpactModel.fromJson(Map<String, dynamic> json) {
    return BookingEcoImpactModel(
      co2SavedKg: _asDouble(json['co2SavedKg']) ?? 0,
      kmEquivalent: _asDouble(json['kmEquivalent']) ?? 0,
      category: _asString(json['category']),
      message: _asString(json['message']),
    );
  }
}

class EcoLeaderboardUserModel {
  const EcoLeaderboardUserModel({
    this.id,
    this.totalCO2 = 0,
    this.totalRentals = 0,
    this.firstName,
    this.lastName,
    this.city,
    this.profilePhoto,
  });

  final String? id;
  final double totalCO2;
  final int totalRentals;
  final String? firstName;
  final String? lastName;
  final String? city;
  final String? profilePhoto;

  factory EcoLeaderboardUserModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    final userMap = userRaw is Map ? _stringKeyMap(userRaw) : const <String, dynamic>{};
    final locationRaw = userMap['location'];
    final locationMap = locationRaw is Map ? _stringKeyMap(locationRaw) : const <String, dynamic>{};

    return EcoLeaderboardUserModel(
      id: _asString(json['_id']) ?? _asString(json['id']) ?? _asString(json['userId']),
      totalCO2: _asDouble(json['totalCO2']) ?? 0,
      totalRentals: _asInt(json['totalRentals']) ?? 0,
      firstName: _asString(userMap['firstName']),
      lastName: _asString(userMap['lastName']),
      city: _asString(locationMap['city']),
      profilePhoto: _asString(userMap['profilePhoto']),
    );
  }

  String get fullName {
    final combined = <String>[
      (firstName ?? '').trim(),
      (lastName ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    return combined.isEmpty ? 'Anonymous' : combined;
  }
}

class EcoLeaderboardCityModel {
  const EcoLeaderboardCityModel({
    this.city,
    this.province,
    this.totalCO2 = 0,
    this.totalRentals = 0,
  });

  final String? city;
  final String? province;
  final double totalCO2;
  final int totalRentals;

  factory EcoLeaderboardCityModel.fromJson(Map<String, dynamic> json) {
    return EcoLeaderboardCityModel(
      city: _asString(json['city']),
      province: _asString(json['province']),
      totalCO2: _asDouble(json['totalCO2']) ?? 0,
      totalRentals: _asInt(json['totalRentals']) ?? 0,
    );
  }

  String get displayName {
    final parts = <String>[
      (city ?? '').trim(),
      (province ?? '').trim(),
    ].where((part) => part.isNotEmpty).toList(growable: false);
    return parts.isEmpty ? 'Unknown' : parts.join(', ');
  }
}

class EcoCategoryModel {
  const EcoCategoryModel({
    required this.category,
    this.co2SavedKg = 0,
    this.kmEquivalent = 0,
    this.description,
  });

  final String category;
  final double co2SavedKg;
  final double kmEquivalent;
  final String? description;

  factory EcoCategoryModel.fromJson(Map<String, dynamic> json) {
    return EcoCategoryModel(
      category: _asString(json['category']) ?? '',
      co2SavedKg: _asDouble(json['co2SavedKg']) ?? 0,
      kmEquivalent: _asDouble(json['kmEquivalent']) ?? 0,
      description: _asString(json['description']),
    );
  }
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  if (normalized.isEmpty || normalized.toLowerCase() == 'null') return null;
  return normalized;
}

Map<String, dynamic> _stringKeyMap(Map<dynamic, dynamic> source) {
  return source.map((key, value) => MapEntry(key.toString(), value));
}
