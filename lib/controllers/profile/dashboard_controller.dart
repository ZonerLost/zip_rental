import 'package:get/get.dart';
import 'package:zip_peer/models/profile/dashboard_models.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/dashboard/dashboard_service.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class DashboardController extends GetxController {
  DashboardController({
    ProfileService? profileService,
    DashboardService? dashboardService,
  }) : _profileService = profileService ?? ProfileService(),
       _dashboardService = dashboardService ?? DashboardService();

  final ProfileService _profileService;
  final DashboardService _dashboardService;

  bool isLoading = false;
  UserProfile? profile;
  String? profilePhotoUrl;

  DashboardStats? stats;
  String? statsErrorMessage;

  // ── Convenience accessors over `stats` — kept so the existing dashboard
  // widgets (which read these directly) didn't need to change shape. ──
  int get rentedOutCount => stats?.lending.total ?? 0;
  int get rentedFromOthersCount => stats?.rentals.total ?? 0;
  int get listedItemsCount => stats?.items.total ?? 0;
  double get rating => stats?.rating.average ?? 0;
  double get earnings => stats?.earnings.total ?? 0;
  String get earningsCurrency => stats?.earnings.currency ?? 'CAD';

  String get fullName {
    final value = profile?.fullName ?? '';
    return value.isEmpty ? 'User' : value;
  }

  String get email {
    final value = (profile?.email ?? '').trim();
    return value.isEmpty ? 'No email available' : value;
  }

  String get phone {
    final value = (profile?.phone ?? '').trim();
    return value.isEmpty ? 'No phone added' : value;
  }

  String get locationLabel {
    final value = (profile?.locationLabel ?? '').trim();
    return value.isEmpty ? 'No location added' : value;
  }

  String get language {
    final value = (profile?.language ?? '').trim();
    return value.isEmpty ? 'en' : value;
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    update();

    // Profile identity (name/email/photo) and dashboard stats come from two
    // different endpoints — load them together.
    final results = await Future.wait([
      _profileService.getProfile(),
      _dashboardService.getDashboard(),
    ]);
    final profileResult = results[0] as ProfileResult;
    final dashboardResult = results[1] as DashboardResult;

    if (profileResult.success && profileResult.profile != null) {
      profile = profileResult.profile;
      profilePhotoUrl = _withCacheBust(
        _bestPhotoUrl(profileResult),
        _resolvePhotoVersion(profileResult),
      );
    }

    if (dashboardResult.success) {
      stats = dashboardResult.stats;
      statsErrorMessage = null;
    } else {
      statsErrorMessage = dashboardResult.message;
    }

    isLoading = false;
    update();
  }

  dynamic _getValueByPath(Map<String, dynamic> root, String path) {
    final parts = path.split('.');
    dynamic current = root;
    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }
    return current;
  }

  String? _bestPhotoUrl(ProfileResult result) {
    final candidates = <String?>[
      result.profilePhoto,
      result.profile?.profilePhoto,
      _getValueByPath(
        result.data ?? <String, dynamic>{},
        'data.profilePhoto',
      )?.toString(),
      _getValueByPath(
        result.data ?? <String, dynamic>{},
        'profilePhoto',
      )?.toString(),
    ];
    for (final candidate in candidates) {
      final value = candidate?.trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return value;
      }
    }
    return null;
  }

  String? _resolvePhotoVersion(ProfileResult result) {
    final updatedAtFromProfile = result.profile?.updatedAt;
    if (updatedAtFromProfile != null) {
      return updatedAtFromProfile.millisecondsSinceEpoch.toString();
    }

    final rawUpdatedAt =
        _getValueByPath(
          result.data ?? <String, dynamic>{},
          'data.updatedAt',
        )?.toString() ??
        _getValueByPath(
          result.data ?? <String, dynamic>{},
          'updatedAt',
        )?.toString();
    if (rawUpdatedAt == null || rawUpdatedAt.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(rawUpdatedAt.trim());
    if (parsed == null) {
      return null;
    }
    return parsed.millisecondsSinceEpoch.toString();
  }

  String? _withCacheBust(String? url, String? version) {
    final value = (url ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    if (version == null || version.trim().isEmpty) {
      return value;
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return value;
    }
    final query = Map<String, String>.from(uri.queryParameters);
    query['v'] = version.trim();
    return uri.replace(queryParameters: query).toString();
  }
}
