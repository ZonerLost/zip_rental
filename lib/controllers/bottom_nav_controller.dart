import 'package:get/get.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class BottomNavController extends GetxController {
  BottomNavController({ProfileService? profileService})
    : _profileService = profileService ?? ProfileService();

  static BottomNavController get to => Get.find();

  final ProfileService _profileService;

  int currentIndex = 0;
  String? profilePhotoUrl;
  bool isLoadingProfilePhoto = false;

  @override
  void onInit() {
    super.onInit();
    refreshProfilePhoto();
  }

  void switchTo(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    update();
  }

  Future<void> refreshProfilePhoto() async {
    isLoadingProfilePhoto = true;
    update();

    final result = await _profileService.getProfile();
    if (result.success && result.profile != null) {
      profilePhotoUrl = _withCacheBust(
        _bestPhotoUrl(result),
        result.profile?.updatedAt?.millisecondsSinceEpoch,
      );
    } else {
      profilePhotoUrl = null;
    }

    isLoadingProfilePhoto = false;
    update();
  }

  String? _bestPhotoUrl(ProfileResult result) {
    final candidates = <String?>[
      result.profilePhoto,
      result.profile?.profilePhoto,
      result.data?['data']?['profilePhoto']?.toString(),
      result.data?['profilePhoto']?.toString(),
    ];

    for (final candidate in candidates) {
      final value = candidate?.trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return value;
      }
    }
    return null;
  }

  String? _withCacheBust(String? url, int? updatedAtMs) {
    final value = (url ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    if (updatedAtMs == null) {
      return value;
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return value;
    }
    final query = Map<String, String>.from(uri.queryParameters);
    query['v'] = updatedAtMs.toString();
    return uri.replace(queryParameters: query).toString();
  }
}
