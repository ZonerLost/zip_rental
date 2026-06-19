import 'package:get/get.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/items/item_api_service.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class LanguageController extends GetxController {
  LanguageController({
    ItemApiService? itemApiService,
    ProfileService? profileService,
    AuthService? authService,
  })  : _itemApiService = itemApiService ?? ItemApiService(),
        _profileService = profileService ?? ProfileService(),
        _authService = authService ?? AuthService();

  final ItemApiService _itemApiService;
  final ProfileService _profileService;
  final AuthService _authService;

  String selected = 'en';
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  List<LanguageModel> languages = const [
    LanguageModel(code: 'en', label: 'English', nativeLabel: 'English'),
    LanguageModel(code: 'fr', label: 'French', nativeLabel: 'Français'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadLanguages();
    _loadStoredLanguage();
  }

  Future<void> _loadLanguages() async {
    isLoading = true;
    errorMessage = null;
    update();
    try {
      final fetched = await _itemApiService.getLanguages();
      if (fetched.isNotEmpty) languages = fetched;
    } catch (e) {
      errorMessage = 'Could not load languages.';
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _loadStoredLanguage() async {
    final stored = await _authService.getLanguagePreference();
    if (stored != null && stored.isNotEmpty) {
      selected = stored;
      update();
    }
  }

  void select(String code) {
    selected = code;
    update();
  }

  Future<bool> saveLanguage() async {
    isSaving = true;
    update();
    try {
      final result = await _profileService.updateProfile(
        UpdateProfileRequest(language: selected),
      );
      if (!result.success) {
        Get.snackbar('Error', result.message);
        return false;
      }
      await _authService.saveLanguagePreference(selected);
      return true;
    } catch (_) {
      Get.snackbar('Error', 'Failed to save language preference.');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }
}
