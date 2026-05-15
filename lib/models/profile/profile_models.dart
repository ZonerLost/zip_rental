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
  const ProfileLocation({this.city, this.province, this.coordinates});

  final String? city;
  final String? province;
  final ProfileCoordinates? coordinates;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (province != null && province!.trim().isNotEmpty)
        'province': province!.trim(),
      if (coordinates != null && coordinates!.toJson().isNotEmpty)
        'coordinates': coordinates!.toJson(),
    };
  }

  factory ProfileLocation.fromJson(Map<String, dynamic> json) {
    final rawCoordinates = json['coordinates'];
    return ProfileLocation(
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      coordinates: rawCoordinates is Map<String, dynamic>
          ? ProfileCoordinates.fromJson(rawCoordinates)
          : null,
    );
  }
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phone,
    this.language,
    this.location,
  });

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? language;
  final ProfileLocation? location;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (firstName != null && firstName!.trim().isNotEmpty)
        'firstName': firstName!.trim(),
      if (lastName != null && lastName!.trim().isNotEmpty)
        'lastName': lastName!.trim(),
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
      if (language != null && language!.trim().isNotEmpty)
        'language': language!.trim(),
      if (location != null && location!.toJson().isNotEmpty)
        'location': location!.toJson(),
    };
  }
}

class UserProfile {
  const UserProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.language,
    this.profilePhoto,
    this.location,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? language;
  final String? profilePhoto;
  final ProfileLocation? location;

  String get fullName =>
      '${(firstName ?? '').trim()} ${(lastName ?? '').trim()}'.trim();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'];
    return UserProfile(
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      language: json['language']?.toString(),
      profilePhoto: json['profilePhoto']?.toString(),
      location: rawLocation is Map<String, dynamic>
          ? ProfileLocation.fromJson(rawLocation)
          : null,
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
