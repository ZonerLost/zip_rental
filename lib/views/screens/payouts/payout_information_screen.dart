import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/payouts/payout_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/payouts/payout_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

/// Replaces the old fake bank-account screens (`payment.dart`/
/// `address_methord.dart`) — there is no bank-account form anymore. Payouts
/// go through Stripe Connect Express: the owner taps a button, Stripe
/// collects their bank details and identity documents directly (this app
/// never sees them), and this screen just reflects `state` from
/// `GET /users/payout-account`.
class PayoutInformationScreen extends StatefulWidget {
  const PayoutInformationScreen({super.key});

  @override
  State<PayoutInformationScreen> createState() => _PayoutInformationScreenState();
}

class _PayoutInformationScreenState extends State<PayoutInformationScreen>
    with WidgetsBindingObserver {
  late final PayoutController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = Get.isRegistered<PayoutController>()
        ? Get.find<PayoutController>()
        : Get.put(PayoutController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// `returnsTo: "web"` onboarding links don't come back via deep link —
  /// see `PayoutController.onAppResumed`.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PayoutController>(
      init: _controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  Row(
                    children: [
                      Bounce(
                        onTap: () => Get.back(),
                        child: CommonImageView(
                          imagePath: Assets.imagesBack,
                          height: 50,
                        ),
                      ),
                      const Gap(10),
                      const MyText(
                        text: 'Payout Information',
                        size: 16,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.loadStatus,
                      child: _buildBody(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(PayoutController controller) {
    if (controller.isLoading && controller.status == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.status == null) {
      return ListView(
        children: [
          const Gap(60),
          MyText(
            text: controller.errorMessage ?? 'Something went wrong.',
            size: 14,
            color: kredColor,
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Center(
            child: Bounce(
              onTap: controller.loadStatus,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const MyText(
                  text: 'Retry',
                  size: 13,
                  color: kPrimaryColor,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final status = controller.status!;
    return ListView(
      children: [
        _statusCard(status),
        const Gap(20),
        if (!status.isActive) _actionButton(controller, status),
      ],
    );
  }

  Widget _statusCard(PayoutAccountStatus status) {
    if (status.isActive) return _activeCard(status);
    if (status.isRestricted) return _restrictedCard(status);
    if (status.isPending) {
      return _infoCard(
        icon: Icons.hourglass_bottom,
        iconColor: kPrimaryColor,
        title: 'Finish setting up payouts',
        subtitle:
            'You started onboarding with Stripe but didn\'t finish. '
            'Complete it to start receiving rental income.',
      );
    }
    return _infoCard(
      icon: Icons.account_balance_outlined,
      iconColor: kSubText,
      title: 'Set up payouts',
      subtitle:
          'Connect a bank account through Stripe to get paid for your '
          'rentals. Your bank details go directly to Stripe — this app '
          'never sees them.',
    );
  }

  Widget _activeCard(PayoutAccountStatus status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kgreenColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kgreenColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: kgreenColor,
              size: 24,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: status.bank?.name ?? 'Bank account connected',
                  size: 15,
                  weight: FontWeight.w600,
                ),
                const Gap(4),
                MyText(
                  text: (status.bank?.last4 ?? '').isNotEmpty
                      ? '•••• ${status.bank!.last4}'
                      : 'Payouts enabled',
                  size: 13,
                  color: kSubText,
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: kgreenColor, size: 22),
        ],
      ),
    );
  }

  Widget _restrictedCard(PayoutAccountStatus status) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kredColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: kredColor, size: 22),
              const Gap(10),
              const Expanded(
                child: MyText(
                  text: 'Action needed',
                  size: 15,
                  weight: FontWeight.w600,
                  color: kredColor,
                ),
              ),
            ],
          ),
          const Gap(10),
          MyText(
            text: 'Stripe needs a bit more information before payouts can '
                'be enabled.',
            size: 13,
            color: kSubText,
          ),
          if (status.requirementsDue.isNotEmpty) ...[
            const Gap(12),
            ...status.requirementsDue.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText(text: '•  ', size: 13, color: kSubText),
                    Expanded(
                      child: MyText(
                        text: _humanizeRequirement(r),
                        size: 13,
                        color: kSubText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Stripe's requirement codes are dotted machine strings
  /// (`individual.verification.document`) — shown readably rather than
  /// verbatim, while staying close enough to what Stripe's own onboarding
  /// flow will ask for.
  String _humanizeRequirement(String code) {
    final last = code.split('.').last;
    final spaced = last
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .replaceAll('_', ' ');
    if (spaced.isEmpty) return code;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Gap(14),
          MyText(text: title, size: 16, weight: FontWeight.w600),
          const Gap(8),
          MyText(text: subtitle, size: 13, color: kSubText),
        ],
      ),
    );
  }

  Widget _actionButton(PayoutController controller, PayoutAccountStatus status) {
    final label = status.isNotConnected
        ? 'Set up payouts'
        : status.isPending
            ? 'Finish setup'
            : 'Continue setup';
    return MyButton(
      onTap: () {
        if (!controller.isStartingOnboarding) controller.startOnboarding();
      },
      buttonText: controller.isStartingOnboarding ? 'Opening...' : label,
      fontColor: Colors.white,
      height: 56,
      radius: 28,
      hasgrad: false,
      fontSize: 16,
    );
  }
}
