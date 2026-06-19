import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/items/item_api_service.dart';
import 'package:zip_peer/views/screens/add_item_module/add_items_summary.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class BoostScreen extends StatefulWidget {
  const BoostScreen({super.key});

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  String? bookingType;
  String? rentalType;
  String? scheduleType;
  WeeklyScheduleModel? pickupSchedule;
  Map<String, dynamic>? itemDraft;

  double boostPrice = 9.99;
  int boostDays = 7;
  bool _loadingConfig = true;

  final ItemApiService _itemApiService = ItemApiService();

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      bookingType = Get.arguments['bookingType'];
      rentalType = Get.arguments['rentalType'];
      scheduleType = Get.arguments['scheduleType'];
      if (Get.arguments['pickupSchedule'] is WeeklyScheduleModel) {
        pickupSchedule = Get.arguments['pickupSchedule'] as WeeklyScheduleModel;
      }
      if (Get.arguments['itemDraft'] is Map<String, dynamic>) {
        itemDraft = Get.arguments['itemDraft'] as Map<String, dynamic>;
      }
    }
    _loadBoostConfig();
  }

  Future<void> _loadBoostConfig() async {
    try {
      final config = await _itemApiService.getBoostConfig();
      if (mounted) {
        setState(() {
          boostPrice = config.price;
          boostDays = config.durationDays;
          _loadingConfig = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingConfig = false);
    }
  }

  void _goToSummary({required bool boosted}) {
    Get.to(
      () => const AddItemsSummaryScreen(),
      arguments: {
        'bookingType': bookingType,
        'rentalType': rentalType,
        'scheduleType': scheduleType,
        'pickupSchedule': pickupSchedule,
        'boosted': boosted,
        'itemDraft': itemDraft,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              onTap: () => _goToSummary(boosted: true),
              buttonText: _loadingConfig
                  ? 'Boost Ad'
                  : 'Boost Ad — \$$boostPrice CAD / $boostDays days',
              fontColor: Colors.white,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 16,
            ),
            const Gap(20),
            MyButton(
              onTap: () => _goToSummary(boosted: false),
              buttonText: 'Skip this step',
              fontColor: kPrimaryColor,
              backgroundColor: kWhite,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 17,
            ),
            const Gap(20),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bounce(
                  onTap: () => Get.back(),
                  child: Row(
                    children: [
                      CommonImageView(imagePath: Assets.imagesBack, height: 40),
                      const Gap(8),
                      const MyText(
                        text: 'Boost Ad',
                        size: 18,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                const MyText(text: 'Step 4/5', size: 14, color: kSubText),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesSpaceShip,
                      height: 150,
                    ),
                  ],
                ),
                const Gap(10),
                _loadingConfig
                    ? const CircularProgressIndicator()
                    : MyText(
                        text: 'Boost your ad for \$$boostPrice CAD',
                        size: 18,
                        weight: FontWeight.w600,
                      ),
                const Gap(10),
                MyText(
                  text:
                      'Get more views and better results by promoting your listing for $boostDays days.',
                  size: 14,
                  color: kSubText,
                  textAlign: TextAlign.center,
                  weight: FontWeight.w500,
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
