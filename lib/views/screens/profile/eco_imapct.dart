import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/eco/eco_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/eco/eco_models.dart';
import 'package:zip_peer/views/screens/profile/eco_leaderboard.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class EcoImpactScreen extends StatefulWidget {
  const EcoImpactScreen({super.key});

  @override
  State<EcoImpactScreen> createState() => _EcoImpactScreenState();
}

class _EcoImpactScreenState extends State<EcoImpactScreen> {
  late final EcoController _controller;

  // null = lifetime (the default view).
  String? _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<EcoController>()
        ? Get.find<EcoController>()
        : Get.put(EcoController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchMyImpact(period: _selectedPeriod);
    });
  }

  void _selectPeriod(String? period) {
    if (_selectedPeriod == period) return;
    setState(() => _selectedPeriod = period);
    _controller.fetchMyImpact(period: period);
  }

  String _periodLabel(String? period) {
    switch (period) {
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return 'Lifetime';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EcoController>(
      init: _controller,
      builder: (controller) {
        // The period toggle drives which stats block is on screen; lifetime
        // stats always back the stat cards + badges (those track all-time
        // progress regardless of which period is being viewed in the chart
        // card below).
        final lifetime = controller.myImpact?.lifetime;
        final periodStats = controller.myImpact?.period;
        final displayedStats = _selectedPeriod == null
            ? lifetime
            : (periodStats ?? lifetime);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: AppSizes.DEFAULT,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Bounce(
                              onTap: () => Get.back(),
                              child: CommonImageView(
                                imagePath: Assets.imagesBack,
                                height: 50,
                              ),
                            ),
                            const Gap(12),
                            const MyText(
                              text: "Eco Impact",
                              size: 20,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                        Bounce(
                          onTap: () => Get.to(() => const EcoLeaderboardScreen()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.leaderboard_outlined,
                                  size: 18,
                                  color: kPrimaryColor,
                                ),
                                const Gap(6),
                                MyText(
                                  text: 'Leaderboard',
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    if ((controller.myImpactErrorMessage ?? '').isNotEmpty &&
                        controller.myImpact == null) ...[
                      _ErrorCard(
                        message: controller.myImpactErrorMessage!,
                        onRetry: () =>
                            controller.fetchMyImpact(period: _selectedPeriod),
                      ),
                      const Gap(24),
                    ],

                    // Stats Cards — all four are backed by real /eco/my-impact
                    // fields (lifetime totals never fabricated).
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.eco_outlined,
                            value: controller.isMyImpactLoading &&
                                    lifetime == null
                                ? '—'
                                : '${(lifetime?.totalCO2 ?? 0).toStringAsFixed(0)} Kg',
                            label: 'Total CO₂ saved',
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.directions_car_outlined,
                            value: controller.isMyImpactLoading &&
                                    lifetime == null
                                ? '—'
                                : '${(lifetime?.totalKm ?? 0).toStringAsFixed(1)} Km',
                            label: 'Equivalent in car kilometers avoided',
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.shopping_bag_outlined,
                            value: controller.isMyImpactLoading &&
                                    lifetime == null
                                ? '—'
                                : '${lifetime?.totalRentals ?? 0}',
                            label: 'Number of rentals contributing',
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.military_tech_outlined,
                            value: controller.myImpact?.badge?.label ??
                                (controller.isMyImpactLoading ? '—' : 'Eco Starter'),
                            label: 'Current badge tier',
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    // Period Section — replaces the old (fabricated) weekly
                    // chart with the real lifetime/month/year totals the API
                    // actually returns.
                    Container(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                text: controller.isMyImpactLoading &&
                                        displayedStats == null
                                    ? '—'
                                    : '${(displayedStats?.totalCO2 ?? 0).toStringAsFixed(0)} Kg',
                                size: 24,
                                weight: FontWeight.w600,
                              ),
                              _PeriodDropdown(
                                selected: _selectedPeriod,
                                label: _periodLabel(_selectedPeriod),
                                onSelected: _selectPeriod,
                              ),
                            ],
                          ),
                          const Gap(4),
                          MyText(
                            text: 'Total CO₂ saved',
                            size: 14,
                            color: kSubText,
                          ),
                          const Gap(12),
                          MyText(
                            text: displayedStats?.equivalence ??
                                'Complete a rental to start tracking your eco impact.',
                            size: 13,
                            color: kSubText,
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),

                    // Badges Section — progress computed locally against the
                    // fixed threshold table since the API only ever returns
                    // the current + next badge, not all four at once.
                    MyText(
                      text: 'BADGES',
                      size: 12,
                      weight: FontWeight.w600,
                      color: kSubText,
                      paddingLeft: 4,
                    ),
                    const Gap(16),

                    ...EcoBadgeThresholds.all.map(
                      (badge) => _buildBadgeItem(controller, badge),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, size: 32, color: kPrimaryColor),
          const Gap(12),
          MyText(
            text: value,
            size: 18,
            weight: FontWeight.w600,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
          const Gap(4),
          MyText(text: label, size: 12, color: kSubText, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(EcoController controller, EcoBadgeModel badge) {
    final progress = controller.progressTowardsBadge(badge);
    final isEarned = controller.isBadgeEarned(badge);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  backgroundColor: kPrimaryColor.withOpacity(0.15),
                ),
              ),
              MyText(
                text: '${(progress * 100).round()}%',
                size: 14,
                weight: FontWeight.w600,
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: badge.label, size: 16, weight: FontWeight.w600),
                const Gap(4),
                MyText(
                  text: 'Reach ${badge.minCO2.toStringAsFixed(0)} kg CO₂ saved',
                  size: 13,
                  color: kSubText,
                ),
              ],
            ),
          ),
          if (isEarned)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFF4A5C6A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: kWhite, size: 20),
            ),
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final String? selected;
  final String label;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: null, child: Text('Lifetime')),
        PopupMenuItem(value: 'month', child: Text('This Month')),
        PopupMenuItem(value: 'year', child: Text('This Year')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kWhite3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(text: label, size: 14, weight: FontWeight.w500),
            const Gap(4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kredColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(text: message, size: 13, color: kredColor),
          const Gap(10),
          Bounce(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kredColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const MyText(
                text: 'Retry',
                size: 12,
                weight: FontWeight.w600,
                color: kredColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
