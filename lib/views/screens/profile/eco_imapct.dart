import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class EcoImpactScreen extends StatefulWidget {
  const EcoImpactScreen({super.key});

  @override
  State<EcoImpactScreen> createState() => _EcoImpactScreenState();
}

class _EcoImpactScreenState extends State<EcoImpactScreen> {
  final List<ChartData> chartData = [
    ChartData('Mon', 20),
    ChartData('Tue', 40),
    ChartData('Wed', 60),
    ChartData('Thu', 67),
    ChartData('Fri', 60),
    ChartData('Sat', 40),
    ChartData('Sun', 20),
  ];

  final List<BadgeData> badges = [
    BadgeData('Eco Starter', 'Earning from rented items', 23, false),
    BadgeData('Green Achiever', 'Earning from rented items', 100, true),
    BadgeData('Planet Hero', 'Earning from rented items', 23, false),
    BadgeData('Impact Legend', 'Earning from rented items', 23, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSizes.DEFAULT,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(20),
                // Header
                Row(
                  children: [
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 50,
                      ),
                    ),
                    Gap(12),
                    MyText(
                      text: "Eco Impact",
                      size: 20,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                Gap(24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.eco_outlined,
                        value: '67 Kg',
                        label: 'Total CO₂ saved',
                      ),
                    ),
                    Gap(12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.park_outlined,
                        value: '66',
                        label: 'Equivalent in trees planted',
                      ),
                    ),
                  ],
                ),
                Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.directions_car_outlined,
                        value: '56.6 Km',
                        label: 'Equivalent in car kilometers avoided',
                      ),
                    ),
                    Gap(12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.shopping_bag_outlined,
                        value: '22',
                        label: 'Number of rentals contributing',
                      ),
                    ),
                  ],
                ),
                Gap(24),

                // Chart Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
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
                            text: '67 Kg',
                            size: 24,
                            weight: FontWeight.w600,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kWhite3,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                MyText(
                                  text: 'This Week',
                                  size: 14,
                                  weight: FontWeight.w500,
                                ),
                                Gap(4),
                                Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap(4),
                      MyText(
                        text: 'Total CO₂ saved',
                        size: 14,
                        color: kSubText,
                      ),
                      Gap(20),
                      SizedBox(
                        height: 200,
                        child: SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          primaryXAxis: CategoryAxis(
                            majorGridLines: MajorGridLines(width: 0),
                            axisLine: AxisLine(width: 0),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: kSubText,
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            majorGridLines: MajorGridLines(width: 0),
                          ),
                          series: <CartesianSeries>[
                            ColumnSeries<ChartData, String>(
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.day,
                              yValueMapper: (ChartData data, _) => data.value,
                              pointColorMapper: (ChartData data, _) =>
                                  data.day == 'Thu'
                                  ? const Color(
                                      0xFF43544E,
                                    ) // dark green-grey (active)
                                  : const Color.fromARGB(
                                      58,
                                      189,
                                      189,
                                      189,
                                    ), // light gray (inactive)
                              // 🔥 EXACT ROUNDNESS LIKE YOUR DESIGN
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                              spacing: 0.3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(24),

                // Badges Section
                MyText(
                  text: 'BADGES',
                  size: 12,
                  weight: FontWeight.w600,
                  color: kSubText,
                  paddingLeft: 4,
                ),
                Gap(16),

                ...badges.map((badge) => _buildBadgeItem(badge)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonImageView(imagePath: Assets.imagesEcoImpact, height: 50),
          Gap(12),
          MyText(text: value, size: 20, weight: FontWeight.w600),
          Gap(4),
          MyText(text: label, size: 12, color: kSubText, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BadgeData badge) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                  value: badge.progress / 100,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    badge.isCompleted ? kPrimaryColor : kPrimaryColor,
                  ),
                ),
              ),
              MyText(
                text: '${badge.progress}%',
                size: 14,
                weight: FontWeight.w600,
              ),
            ],
          ),
          Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: badge.title, size: 16, weight: FontWeight.w600),
                Gap(4),
                MyText(text: badge.subtitle, size: 13, color: kSubText),
              ],
            ),
          ),
          if (badge.isCompleted)
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Color(0xFF4A5C6A),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: kWhite, size: 20),
            ),
        ],
      ),
    );
  }
}

class ChartData {
  final String day;
  final double value;

  ChartData(this.day, this.value);
}

class BadgeData {
  final String title;
  final String subtitle;
  final int progress;
  final bool isCompleted;

  BadgeData(this.title, this.subtitle, this.progress, this.isCompleted);
}
