import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zip_peer/models/payouts/payout_models.dart';
import 'package:zip_peer/services/payouts/payout_service.dart';

class PayoutController extends GetxController {
  PayoutController({PayoutService? payoutService})
      : _service = payoutService ?? PayoutService();

  final PayoutService _service;

  PayoutAccountStatus? status;
  bool isLoading = false;
  bool isStartingOnboarding = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  Future<void> loadStatus() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _service.getStatus();

    isLoading = false;
    if (result.success) {
      status = result.status;
    } else {
      errorMessage = result.message;
    }
    update();
  }

  /// Requests a fresh, single-use Stripe onboarding link and opens it in
  /// the system browser (never cache/reuse a link — it expires in minutes).
  /// The app doesn't need to do anything with the redirect itself beyond
  /// refreshing status when the owner returns — see the deep-link listener
  /// in main.dart.
  Future<void> startOnboarding() async {
    if (isStartingOnboarding) return;
    isStartingOnboarding = true;
    update();

    final result = await _service.createOnboardingLink();

    isStartingOnboarding = false;
    update();

    if (!result.success || result.link == null) {
      Get.snackbar("Couldn't start payout setup", result.message);
      return;
    }

    final uri = Uri.tryParse(result.link!.url);
    if (uri == null) {
      Get.snackbar(
        "Couldn't start payout setup",
        'The server returned an invalid link.',
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar('Couldn\'t open payout setup', 'Try again in a moment.');
    }
  }
}
