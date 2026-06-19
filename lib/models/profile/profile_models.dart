class ProfileCoordinates {
  const ProfileCoordinates({this.lat, this.lng});

  final double? lat;
  final double? lng;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    };
  }

  factory ProfileCoordinates.fromJson(Map<String, dynamic> json) {
    return ProfileCoordinates(
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
    );
  }
}

class ProfileLocation {
  const ProfileLocation({
    this.country,
    this.city,
    this.province,
    this.coordinates,
  });

  final String? country;
  final String? city;
  final String? province;
  final ProfileCoordinates? coordinates;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (country != null && country!.trim().isNotEmpty)
        'country': country!.trim(),
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (province != null && province!.trim().isNotEmpty)
        'province': province!.trim(),
      if (coordinates != null && coordinates!.toJson().isNotEmpty)
        'coordinates': coordinates!.toJson(),
    };
  }

  factory ProfileLocation.fromJson(Map<String, dynamic> json) {
    final rawCoordinates = json['coordinates'];
    final coordinatesMap = rawCoordinates is Map
        ? rawCoordinates.map((key, value) => MapEntry(key.toString(), value))
        : null;
    return ProfileLocation(
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      coordinates: coordinatesMap != null
          ? ProfileCoordinates.fromJson(coordinatesMap)
          : null,
    );
  }
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.language,
    this.location,
  });

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? language;
  final ProfileLocation? location;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (firstName != null && firstName!.trim().isNotEmpty)
        'firstName': firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty)
        'lastName': lastName!.trim(),
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (language != null && language!.trim().isNotEmpty)
        'language': language!.trim(),
      if (location != null && location!.toJson().isNotEmpty)
        'location': location!.toJson(),
    };
  }
}

class UserProfile {
  const UserProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.language,
    this.profilePhoto,
    this.location,
    this.role,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.isIdentityVerified,
    this.updatedAt,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? language;
  final String? profilePhoto;
  final ProfileLocation? location;
  final String? role;
  final bool? isEmailVerified;
  final bool? isPhoneVerified;
  final bool? isIdentityVerified;
  final DateTime? updatedAt;

  String get fullName =>
      '${(firstName ?? '').trim()} ${(lastName ?? '').trim()}'.trim();

  String get locationLabel {
    final parts = <String>[
      (location?.city ?? '').trim(),
      (location?.province ?? '').trim(),
      (location?.country ?? '').trim(),
    ].where((value) => value.isNotEmpty).toList(growable: false);
    return parts.join(', ');
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'];
    final locationMap = rawLocation is Map
        ? rawLocation.map((key, value) => MapEntry(key.toString(), value))
        : null;
    return UserProfile(
      id: _firstString(json, const ['_id', 'id']),
      firstName: _firstString(json, const ['firstName', 'first_name']),
      lastName: _firstString(json, const ['lastName', 'last_name']),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      language: json['language']?.toString(),
      profilePhoto: _firstString(json, const [
        'profilePhoto',
        'profile_photo',
        'avatar',
        'avatarUrl',
        'avatar_url',
        'photo',
        'image',
      ]),
      location: locationMap != null
          ? ProfileLocation.fromJson(locationMap)
          : null,
      role: json['role']?.toString(),
      isEmailVerified: _asBool(json['isEmailVerified']),
      isPhoneVerified: _asBool(json['isPhoneVerified']),
      isIdentityVerified: _asBool(json['isIdentityVerified']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }
}

class ProfileResult {
  const ProfileResult({
    required this.success,
    required this.message,
    this.data,
    this.profile,
    this.profilePhoto,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final UserProfile? profile;
  final String? profilePhoto;
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

String? _firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) {
      continue;
    }
    final normalized = value.toString().trim();
    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      continue;
    }
    return normalized;
  }
  return null;
}

class AddressModel {
  const AddressModel({
    required this.id,
    this.label,
    this.addressLine,
    this.city,
    this.province,
    this.country,
    this.postalCode,
    this.isDefault = false,
    this.coordinates,
  });

  final String id;
  final String? label;
  final String? addressLine;
  final String? city;
  final String? province;
  final String? country;
  final String? postalCode;
  final bool isDefault;
  final ProfileCoordinates? coordinates;

  String get displayAddress {
    final parts = <String>[
      if ((addressLine ?? '').isNotEmpty) addressLine!,
      if ((city ?? '').isNotEmpty) city!,
      if ((province ?? '').isNotEmpty) province!,
      if ((country ?? '').isNotEmpty) country!,
      if ((postalCode ?? '').isNotEmpty) postalCode!,
    ];
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['coordinates'];
    final coordsMap = rawCoords is Map
        ? rawCoords.map((k, v) => MapEntry(k.toString(), v))
        : null;
    return AddressModel(
      id: _firstString(json, const ['_id', 'id']) ?? '',
      label: json['label']?.toString(),
      addressLine: json['addressLine']?.toString(),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postalCode']?.toString(),
      isDefault: _asBool(json['isDefault']) ?? false,
      coordinates: coordsMap != null ? ProfileCoordinates.fromJson(coordsMap) : null,
    );
  }
}

class AddAddressRequest {
  const AddAddressRequest({
    required this.label,
    required this.addressLine,
    required this.city,
    required this.province,
    required this.country,
    required this.postalCode,
    this.coordinates,
  });

  final String label;
  final String addressLine;
  final String city;
  final String province;
  final String country;
  final String postalCode;
  final ProfileCoordinates? coordinates;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label.trim(),
      'addressLine': addressLine.trim(),
      'city': city.trim(),
      'province': province.trim(),
      'country': country.trim(),
      'postalCode': postalCode.trim(),
      if (coordinates != null && coordinates!.toJson().isNotEmpty)
        'coordinates': coordinates!.toJson(),
    };
  }
}

class AddressResult {
  const AddressResult({
    required this.success,
    required this.message,
    this.addresses = const [],
    this.address,
  });

  final bool success;
  final String message;
  final List<AddressModel> addresses;
  final AddressModel? address;
}
