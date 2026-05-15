import 'package:get/get.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class DashboardController extends GetxController {
  DashboardController({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  final ProfileService _profileService;

  bool isLoading = false;
  UserProfile? profile;
  String? profilePhotoUrl;

  int rentedOutCount = 0;
  int rentedFromOthersCount = 0;
  int listedItemsCount = 0;
  double rating = 0;
  double earnings = 0;
  double co2SavedKg = 0;
  String co2EquivalentText = "That's equivalent to 0 km driven by car";

  String get fullName {
    final value = profile?.fullName ?? '';
    return value.isEmpty ? 'User' : value;
  }

  String get email {
    final value = (profile?.email ?? '').trim();
    return value.isEmpty ? 'No email available' : value;
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    update();

    final result = await _profileService.getProfile();
    if (!result.success || result.profile == null) {
      isLoading = false;
      update();
      return;
    }

    profile = result.profile;
    profilePhotoUrl = result.profilePhoto ?? result.profile?.profilePhoto;

    final root = result.data ?? <String, dynamic>{};
    rentedOutCount = _readInt(root, const [
      'rentedOutCount',
      'stats.rentedOutCount',
      'stats.timesRentedOut',
    ]);
    rentedFromOthersCount = _readInt(root, const [
      'rentedFromOthersCount',
      'stats.rentedFromOthersCount',
      'stats.timesRentedFromOthers',
    ]);
    listedItemsCount = _readInt(root, const [
      'listedItemsCount',
      'stats.listedItemsCount',
      'stats.itemsListed',
    ]);
    rating = _readDouble(root, const [
      'rating',
      'stats.rating',
      'stats.overallRating',
    ]);
    earnings = _readDouble(root, const [
      'earnings',
      'stats.earnings',
      'stats.totalEarnings',
    ]);
    co2SavedKg = _readDouble(root, const [
      'co2SavedKg',
      'ecoImpact.co2SavedKg',
      'stats.co2SavedKg',
    ]);
    final distanceKm = _readInt(root, const [
      'ecoImpact.distanceKm',
      'stats.equivalentDistanceKm',
    ]);
    if (distanceKm > 0) {
      co2EquivalentText = "That's equivalent to $distanceKm km driven by car";
    }

    isLoading = false;
    update();
  }

  int _readInt(Map<String, dynamic> root, List<String> candidates) {
    for (final key in candidates) {
      final raw = _getValueByPath(root, key);
      if (raw == null) {
        continue;
      }
      if (raw is int) {
        return raw;
      }
      if (raw is num) {
        return raw.toInt();
      }
      final parsed = int.tryParse(raw.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  double _readDouble(Map<String, dynamic> root, List<String> candidates) {
    for (final key in candidates) {
      final raw = _getValueByPath(root, key);
      if (raw == null) {
        continue;
      }
      if (raw is num) {
        return raw.toDouble();
      }
      final parsed = double.tryParse(raw.toString());
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
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
}
