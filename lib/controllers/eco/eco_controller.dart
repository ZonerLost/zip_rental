import 'package:get/get.dart';
import 'package:zip_peer/models/eco/eco_models.dart';
import 'package:zip_peer/services/eco/eco_service.dart';

class EcoController extends GetxController {
  EcoController({EcoService? ecoService})
    : _ecoService = ecoService ?? EcoService();

  final EcoService _ecoService;

  bool isMyImpactLoading = false;
  String? myImpactErrorMessage;
  MyEcoImpactModel? myImpact;
  String? myImpactPeriod; // null (lifetime), 'month', or 'year'

  bool isBookingImpactLoading = false;
  String? bookingImpactErrorMessage;
  final Map<String, BookingEcoImpactModel> bookingImpactByBookingId =
      <String, BookingEcoImpactModel>{};

  bool isUserLeaderboardLoading = false;
  String? userLeaderboardErrorMessage;
  List<EcoLeaderboardUserModel> userLeaderboard = const <EcoLeaderboardUserModel>[];

  bool isCityLeaderboardLoading = false;
  String? cityLeaderboardErrorMessage;
  List<EcoLeaderboardCityModel> cityLeaderboard = const <EcoLeaderboardCityModel>[];

  bool isCategoriesLoading = false;
  String? categoriesErrorMessage;
  List<EcoCategoryModel> categories = const <EcoCategoryModel>[];

  Future<void> fetchMyImpact({String? period}) async {
    myImpactPeriod = period;
    isMyImpactLoading = true;
    myImpactErrorMessage = null;
    update();

    final result = await _ecoService.getMyImpact(period: period);

    isMyImpactLoading = false;
    if (!result.success || result.data == null) {
      myImpactErrorMessage = result.message;
      update();
      return;
    }

    myImpact = result.data;
    myImpactErrorMessage = null;
    update();
  }

  Future<BookingEcoImpactModel?> fetchBookingImpact(String bookingId) async {
    isBookingImpactLoading = true;
    bookingImpactErrorMessage = null;
    update();

    final result = await _ecoService.getBookingImpact(bookingId);

    isBookingImpactLoading = false;
    if (!result.success || result.data == null) {
      bookingImpactErrorMessage = result.message;
      update();
      return null;
    }

    bookingImpactByBookingId[bookingId] = result.data!;
    bookingImpactErrorMessage = null;
    update();
    return result.data;
  }

  Future<void> fetchUserLeaderboard({int limit = 10}) async {
    isUserLeaderboardLoading = true;
    userLeaderboardErrorMessage = null;
    update();

    final result = await _ecoService.getUserLeaderboard(limit: limit);

    isUserLeaderboardLoading = false;
    if (!result.success) {
      userLeaderboardErrorMessage = result.message;
      update();
      return;
    }

    userLeaderboard = result.data ?? const <EcoLeaderboardUserModel>[];
    userLeaderboardErrorMessage = null;
    update();
  }

  Future<void> fetchCityLeaderboard({int limit = 10}) async {
    isCityLeaderboardLoading = true;
    cityLeaderboardErrorMessage = null;
    update();

    final result = await _ecoService.getCityLeaderboard(limit: limit);

    isCityLeaderboardLoading = false;
    if (!result.success) {
      cityLeaderboardErrorMessage = result.message;
      update();
      return;
    }

    cityLeaderboard = result.data ?? const <EcoLeaderboardCityModel>[];
    cityLeaderboardErrorMessage = null;
    update();
  }

  Future<void> fetchCategories() async {
    if (categories.isNotEmpty) {
      // Static reference data (20 fixed categories) — no need to refetch
      // every time a screen mounts.
      return;
    }

    isCategoriesLoading = true;
    categoriesErrorMessage = null;
    update();

    final result = await _ecoService.getCategories();

    isCategoriesLoading = false;
    if (!result.success) {
      categoriesErrorMessage = result.message;
      update();
      return;
    }

    categories = result.data ?? const <EcoCategoryModel>[];
    categoriesErrorMessage = null;
    update();
  }

  /// Progress (0.0–1.0) of the current lifetime CO2 total towards [badge],
  /// computed against the fixed threshold table — used to render all four
  /// badge tiers with a progress ring, since the API only ever returns the
  /// user's current and next badge, not all four at once.
  double progressTowardsBadge(EcoBadgeModel badge) {
    final totalCO2 = myImpact?.lifetime.totalCO2 ?? 0;
    final index = EcoBadgeThresholds.all.indexWhere((b) => b.id == badge.id);
    if (index < 0) return 0;

    final floor = EcoBadgeThresholds.all[index].minCO2;
    final ceiling = index + 1 < EcoBadgeThresholds.all.length
        ? EcoBadgeThresholds.all[index + 1].minCO2
        : floor;

    if (totalCO2 >= ceiling && ceiling > floor) return 1;
    if (ceiling <= floor) {
      // Top tier — any CO2 at/above its floor counts as fully earned.
      return totalCO2 >= floor ? 1 : 0;
    }
    final progress = (totalCO2 - floor) / (ceiling - floor);
    return progress.clamp(0, 1).toDouble();
  }

  bool isBadgeEarned(EcoBadgeModel badge) {
    final totalCO2 = myImpact?.lifetime.totalCO2 ?? 0;
    return totalCO2 >= badge.minCO2;
  }
}
