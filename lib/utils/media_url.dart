import '../config/api/api_config.dart';

/// Normalizes a possibly-relative media URL (photo, avatar, etc.) returned
/// by the API into an absolute URL the app can load with `Image.network`.
///
/// Some endpoints (e.g. chat conversation participants) return a
/// server-relative path like `/uploads/xyz.jpg` instead of a full URL, which
/// silently fails any `startsWith('http')` check downstream. This mirrors
/// the normalization already used for the user's own profile photo
/// (see `ProfileService._normalizePhotoUrl`) so every screen that renders a
/// user's photo behaves consistently.
String? normalizeMediaUrl(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty || value.toLowerCase() == 'null') {
    return null;
  }
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('//')) {
    return 'https:$value';
  }

  final baseUri = Uri.tryParse(ApiConfig.baseUrl);
  if (baseUri == null || baseUri.host.isEmpty || baseUri.scheme.isEmpty) {
    return value;
  }

  final origin =
      '${baseUri.scheme}://${baseUri.host}'
      '${baseUri.hasPort ? ':${baseUri.port}' : ''}';
  if (value.startsWith('/')) {
    return '$origin$value';
  }
  return '$origin/$value';
}
