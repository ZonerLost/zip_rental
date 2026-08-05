import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/eco/eco_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

/// 6.3 / 6.4 — public User + City eco-impact leaderboards.
class EcoLeaderboardScreen extends StatefulWidget {
  const EcoLeaderboardScreen({super.key});

  @override
  State<EcoLeaderboardScreen> createState() => _EcoLeaderboardScreenState();
}

class _EcoLeaderboardScreenState extends State<EcoLeaderboardScreen> {
  late final EcoController _controller;
  int _selectedTab = 0; // 0 = users, 1 = cities

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<EcoController>()
        ? Get.find<EcoController>()
        : Get.put(EcoController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchUserLeaderboard();
      _controller.fetchCityLeaderboard();
    });
  }

  Future<void> _refresh() async {
    if (_selectedTab == 0) {
      await _controller.fetchUserLeaderboard();
    } else {
      await _controller.fetchCityLeaderboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EcoController>(
      init: _controller,
      builder: (controller) {
        return Scaffold(
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
                      const Gap(12),
                      const MyText(
                        text: 'Eco Leaderboard',
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Top Users', 0),
                        _buildTab('Top Cities', 1),
                      ],
                    ),
                  ),
                  const Gap(20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: _selectedTab == 0
                          ? _buildUserList(controller)
                          : _buildCityList(controller),
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

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: Bounce(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: MyText(
              text: title,
              size: 14,
              weight: FontWeight.w600,
              color: isSelected ? kPrimaryColor : kSubText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(EcoController controller) {
    if (controller.isUserLeaderboardLoading && controller.userLeaderboard.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((controller.userLeaderboardErrorMessage ?? '').isNotEmpty &&
        controller.userLeaderboard.isEmpty) {
      return _errorView(
        controller.userLeaderboardErrorMessage!,
        () => controller.fetchUserLeaderboard(),
      );
    }
    if (controller.userLeaderboard.isEmpty) {
      return const _EmptyView(message: 'No eco impact recorded yet.');
    }

    return ListView.separated(
      itemCount: controller.userLeaderboard.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final entry = controller.userLeaderboard[index];
        return _LeaderboardRow(
          rank: index + 1,
          title: entry.fullName,
          subtitle: entry.city ?? '${entry.totalRentals} rental${entry.totalRentals == 1 ? '' : 's'}',
          co2: entry.totalCO2,
        );
      },
    );
  }

  Widget _buildCityList(EcoController controller) {
    if (controller.isCityLeaderboardLoading && controller.cityLeaderboard.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((controller.cityLeaderboardErrorMessage ?? '').isNotEmpty &&
        controller.cityLeaderboard.isEmpty) {
      return _errorView(
        controller.cityLeaderboardErrorMessage!,
        () => controller.fetchCityLeaderboard(),
      );
    }
    if (controller.cityLeaderboard.isEmpty) {
      return const _EmptyView(message: 'No eco impact recorded yet.');
    }

    return ListView.separated(
      itemCount: controller.cityLeaderboard.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final entry = controller.cityLeaderboard[index];
        return _LeaderboardRow(
          rank: index + 1,
          title: entry.displayName,
          subtitle: '${entry.totalRentals} rental${entry.totalRentals == 1 ? '' : 's'}',
          co2: entry.totalCO2,
        );
      },
    );
  }

  Widget _errorView(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(text: message, size: 14, color: kredColor, textAlign: TextAlign.center),
            const Gap(12),
            Bounce(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const MyText(text: 'Retry', size: 13, color: kPrimaryColor, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.co2,
  });

  final int rank;
  final String title;
  final String subtitle;
  final double co2;

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFFB0BEC5);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return kSubText;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: MyText(
              text: '$rank',
              size: 14,
              weight: FontWeight.w700,
              color: _rankColor,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: title,
                  size: 15,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                MyText(text: subtitle, size: 12, color: kSubText),
              ],
            ),
          ),
          MyText(
            text: '${co2.toStringAsFixed(0)} kg',
            size: 15,
            weight: FontWeight.w700,
            color: kPrimaryColor,
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyText(
        text: message,
        size: 14,
        color: kSubText,
        textAlign: TextAlign.center,
      ),
    );
  }
}
