import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/items/add_item_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/add_item_main.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/double_white_contianers.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class AddItemsSummaryScreen extends StatefulWidget {
  const AddItemsSummaryScreen({super.key});

  @override
  State<AddItemsSummaryScreen> createState() => _AddItemsSummaryScreenState();
}

class _AddItemsSummaryScreenState extends State<AddItemsSummaryScreen> {
  String? bookingType;
  String? rentalType;
  String? scheduleType;
  bool boosted = false;
  Map<String, dynamic>? itemDraft;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      bookingType = Get.arguments['bookingType'];
      rentalType = Get.arguments['rentalType'];
      scheduleType = Get.arguments['scheduleType'];
      boosted = Get.arguments['boosted'] ?? false;
      if (Get.arguments['itemDraft'] is Map<String, dynamic>) {
        itemDraft = Get.arguments['itemDraft'] as Map<String, dynamic>;
      }
    }
  }

  String get rentalTypeDisplay {
    if (rentalType == 'delivery') return 'Delivery Only';
    if (rentalType == 'pickup') return 'Pickup Only';
    if (rentalType == 'both') return 'Delivery & Pickup';
    return 'Pickup Only';
  }

  String get bookingTypeDisplay {
    if (bookingType == 'instant') {
      return 'Request to book (instant approval)';
    }
    return 'Request to book (manual approval)';
  }

  List<File> get _photos {
    final raw = itemDraft?['photos'];
    if (raw is! List) return const [];
    return raw
        .map((e) => e is File ? e : File(e.toString()))
        .where((f) => f.path.isNotEmpty)
        .toList();
  }

  String _locationDisplay(Map<String, dynamic>? draft) {
    final loc = draft?['location'];
    if (loc is! Map) return 'Not set';
    final city = (loc['city'] ?? '').toString().trim();
    final province = (loc['province'] ?? '').toString().trim();
    final country = (loc['country'] ?? 'Canada').toString().trim();
    final parts = [city, province, country].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }

  void _showEditAddressSheet(AddItemController controller) {
    // Pre-fill from draft
    final loc = itemDraft?['location'];
    if (loc is Map) {
      controller.cityController.text = (loc['city'] ?? '').toString();
      controller.provinceController.text = (loc['province'] ?? '').toString();
      controller.countryController.text = (loc['country'] ?? 'Canada').toString();
      final coords = loc['coordinates'];
      if (coords is Map) {
        controller.latController.text = (coords['lat'] ?? '').toString();
        controller.lngController.text = (coords['lng'] ?? '').toString();
      }
    }

    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      DoubleWhiteContainers(
        height: MediaQuery.of(Get.context!).size.height * 0.85,
        mainColor: kWhite3,
        topColor: kWhite,
        handleHeight: 14,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: StatefulBuilder(
          builder: (ctx, setState) => SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: Row(
                    children: [
                      CommonImageView(imagePath: Assets.imagesBackSimple, height: 32),
                      const Gap(8),
                      const MyText(text: 'Back', size: 16, weight: FontWeight.w600, color: Colors.black),
                    ],
                  ),
                ),
                const Gap(16),
                const MyText(text: 'Edit Address', size: 20, weight: FontWeight.w600, color: Colors.black),
                const Gap(4),
                MyText(text: 'Enter the pickup location for your item.', size: 14, color: Colors.grey[600]),
                const Gap(16),
                Divider(color: kDividerColor),
                const Gap(12),
                const MyText(text: 'City *', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.cityController,
                  hint: 'e.g. Montreal',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),
                const MyText(text: 'Province', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.provinceController,
                  hint: 'e.g. QC',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),
                const MyText(text: 'Country *', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.countryController,
                  hint: 'Canada',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),
                const MyText(text: 'Tags (comma separated)', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.tagsController,
                  hint: 'e.g. nike, shoes, sport',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),
                const MyText(text: 'Latitude (optional)', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.latController,
                  hint: 'e.g. 45.5017',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const MyText(text: 'Longitude (optional)', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.lngController,
                  hint: 'e.g. -73.5673',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const Gap(8),
                MyButton(
                  onTap: () {
                    // Merge updated location back into draft
                    final updatedLocation = <String, dynamic>{
                      'city': controller.cityController.text.trim(),
                      'province': controller.provinceController.text.trim(),
                      'country': controller.countryController.text.trim().isEmpty
                          ? 'Canada'
                          : controller.countryController.text.trim(),
                    };
                    final lat = double.tryParse(controller.latController.text.trim());
                    final lng = double.tryParse(controller.lngController.text.trim());
                    if (lat != null && lng != null) {
                      updatedLocation['coordinates'] = {'lat': lat, 'lng': lng};
                    }
                    setState(() {
                      itemDraft = {
                        ...?itemDraft,
                        'location': updatedLocation,
                      };
                    });
                    Get.back();
                    // Trigger rebuild of summary
                    if (mounted) this.setState(() {});
                  },
                  buttonText: 'Save Address',
                  fontColor: Colors.white,
                  height: 56,
                  radius: 28,
                  hasgrad: false,
                  fontSize: 17,
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GetBuilder<AddItemController>(
        builder: (addItemController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyButton(
                onTap: () async {
                  // Merge latest location into draft before submitting
                  final mergedDraft = {
                    ...?itemDraft,
                    'location': <String, dynamic>{
                      'city': addItemController.cityController.text.trim(),
                      'province': addItemController.provinceController.text.trim(),
                      'country': addItemController.countryController.text.trim().isEmpty
                          ? 'Canada'
                          : addItemController.countryController.text.trim(),
                      if (addItemController.latController.text.trim().isNotEmpty &&
                          addItemController.lngController.text.trim().isNotEmpty)
                        'coordinates': {
                          'lat': double.tryParse(addItemController.latController.text.trim()),
                          'lng': double.tryParse(addItemController.lngController.text.trim()),
                        },
                    },
                  };
                  final didCreate = await addItemController.createItemFromDraft(mergedDraft);
                  if (!didCreate) return;
                  if (!mounted) return;
                  Get.snackbar('Success', 'Item added successfully.');
                  Get.offAll(() => const BottomNavBar(initialIndex: 3));
                },
                buttonText: addItemController.isSubmitting ? 'Adding...' : 'Add Item',
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
      body: GetBuilder<AddItemController>(
        builder: (addItemController) => AnimatedListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Gap(50),
            Row(
              children: [
                Bounce(
                  onTap: Get.back,
                  child: Row(
                    children: [
                      CommonImageView(imagePath: Assets.imagesBack, height: 40),
                      const Gap(8),
                      const MyText(text: 'Summary', size: 18, weight: FontWeight.w600),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Product Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MyText(text: 'Product Information', size: 14, weight: FontWeight.w500, color: kBlack),
                      Bounce(
                        onTap: () => Get.to(() => const AddNewItemScreen()),
                        child: Row(
                          spacing: 5,
                          children: [
                            CommonImageView(imagePath: Assets.imagesEditProfile2, height: 16),
                            const MyText(text: 'Edit', size: 14, color: kPrimaryColor, weight: FontWeight.w500),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),

                  // Photos — only show if user selected any
                  if (_photos.isNotEmpty) ...[
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        separatorBuilder: (_, __) => const Gap(12),
                        itemBuilder: (_, i) => CommonImageView(
                          file: _photos[i],
                          height: 80,
                          width: 80,
                          radius: 12,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Gap(16),
                  ],

                  _SummaryRow(label: 'Product Name', value: (itemDraft?['title'] ?? '—').toString()),
                  const Gap(12),
                  _SummaryRow(label: 'Category', value: (itemDraft?['category'] ?? '—').toString()),
                  const Gap(12),
                  _SummaryRow(label: 'Condition', value: (itemDraft?['condition'] ?? '—').toString()),
                  const Gap(12),
                  _SummaryRow(label: 'Rental Type', value: rentalTypeDisplay),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MyText(text: 'Price', size: 14, color: kSubText),
                      Row(
                        children: [
                          MyText(
                            text: 'CAD \$${(itemDraft?['dailyRate'] ?? '0.00')} ',
                            size: 16,
                            weight: FontWeight.w600,
                          ),
                          const MyText(text: '/ Day', size: 14, color: kSubText, weight: FontWeight.w500),
                        ],
                      ),
                    ],
                  ),
                  if (rentalType == 'delivery' || rentalType == 'both') ...[
                    const Gap(12),
                    _SummaryRow(label: 'Delivery Fees', value: '\$10.00'),
                  ],
                  const Gap(12),
                  _SummaryRow(
                    label: 'Description',
                    value: (itemDraft?['description'] ?? '—').toString(),
                    valueMaxLines: 3,
                  ),
                  // Tags
                  if ((itemDraft?['tags'] as List?)?.isNotEmpty == true) ...[
                    const Gap(12),
                    _SummaryRow(
                      label: 'Tags',
                      value: (itemDraft!['tags'] as List).join(', '),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(16),

            // Address
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(text: 'Pickup Address', size: 16, weight: FontWeight.w600, color: kBlack),
                        const Gap(6),
                        MyText(
                          text: _locationDisplay(itemDraft),
                          size: 12,
                          color: kSubText,
                        ),
                      ],
                    ),
                  ),
                  Bounce(
                    onTap: () => _showEditAddressSheet(addItemController),
                    child: Row(
                      spacing: 6,
                      children: [
                        CommonImageView(imagePath: Assets.imagesEditProfile2, height: 16),
                        const MyText(text: 'Edit', size: 14, color: kPrimaryColor, weight: FontWeight.w500),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Booking Type
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(text: bookingTypeDisplay, size: 16, weight: FontWeight.w600, color: kBlack),
            ),
            const Gap(16),

            // Boost
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(text: 'Boost add', size: 16, weight: FontWeight.w600, color: kBlack),
                  MyText(text: boosted ? '\$9.99' : '0\$', size: 16, weight: FontWeight.w600, color: kBlack),
                ],
              ),
            ),
            const Gap(100),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.valueMaxLines = 1});
  final String label;
  final String value;
  final int valueMaxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(text: label, size: 14, color: kSubText),
        const Gap(12),
        Flexible(
          child: MyText(
            text: value,
            size: 14,
            weight: FontWeight.w600,
            textAlign: TextAlign.end,
            maxLines: valueMaxLines,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
