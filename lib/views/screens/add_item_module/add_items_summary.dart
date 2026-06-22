import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/items/add_item_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/addresses/address_service.dart';
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
  WeeklyScheduleModel? pickupSchedule;
  Map<String, dynamic>? itemDraft;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      bookingType = Get.arguments['bookingType'];
      rentalType = Get.arguments['rentalType'];
      scheduleType = Get.arguments['scheduleType'];
      boosted = Get.arguments['boosted'] ?? false;
      if (Get.arguments['pickupSchedule'] is WeeklyScheduleModel) {
        pickupSchedule =
            Get.arguments['pickupSchedule'] as WeeklyScheduleModel;
      }
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

  // ── Product info edit sheet ──────────────────────────────────────────────
  void _showEditProductSheet(AddItemController controller) {
    // Pre-fill text controllers from draft
    controller.titleController.text = (itemDraft?['title'] ?? '').toString();
    controller.descriptionController.text = (itemDraft?['description'] ?? '').toString();
    controller.quantityController.text = (itemDraft?['quantity'] ?? '1').toString();
    controller.minRentalDaysController.text = (itemDraft?['minRentalDays'] ?? '1').toString();
    controller.maxRentalDaysController.text = (itemDraft?['maxRentalDays'] ?? '30').toString();
    final tagsRaw = itemDraft?['tags'];
    controller.tagsController.text = tagsRaw is List
        ? tagsRaw.join(', ')
        : (tagsRaw ?? '').toString();
    final avail = itemDraft?['availability'];
    if (avail is Map) {
      controller.availableFromController.text = (avail['availableFrom'] ?? '').toString();
      controller.availableToController.text = (avail['availableTo'] ?? '').toString();
    }

    // Price — read whichever rate matches the stored priceType
    String localPriceType = (itemDraft?['priceType'] ?? 'Per Day').toString();
    final priceKey = localPriceType == 'Per Week'
        ? 'weeklyRate'
        : localPriceType == 'Per Month'
            ? 'monthlyRate'
            : 'dailyRate';
    controller.priceController.text = (itemDraft?[priceKey] ?? '').toString();

    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      DoubleWhiteContainers(
        height: MediaQuery.of(Get.context!).size.height * 0.88,
        mainColor: kWhite3,
        topColor: kWhite,
        handleHeight: 14,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
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
                const MyText(text: 'Edit Product Info', size: 20, weight: FontWeight.w600, color: Colors.black),
                const Gap(4),
                MyText(text: 'Update title, description, pricing, and more.', size: 14, color: Colors.grey[600]),
                const Gap(16),
                Divider(color: kDividerColor),
                const Gap(12),

                // Title
                const MyText(text: 'Title *', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.titleController,
                  hint: 'e.g. Nike Jordan 6',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),

                // Description
                const MyText(text: 'Description *', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.descriptionController,
                  hint: 'Describe your item...',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                  maxLines: 4,
                ),

                // Price + Per row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(text: 'Price *', size: 14, weight: FontWeight.w500, color: Colors.black87),
                          const Gap(8),
                          MyTextField(
                            controller: controller.priceController,
                            hint: '0.00',
                            hintColor: kBlack.withOpacity(0.4),
                            radius: 12,
                            backgroundColor: Colors.white,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(text: 'Per', size: 14, weight: FontWeight.w500, color: Colors.black87),
                          const Gap(8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: localPriceType,
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                borderRadius: BorderRadius.circular(12),
                                items: controller.uiPriceTypes
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setSheet(() => localPriceType = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Quantity
                const MyText(text: 'Quantity', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.quantityController,
                  hint: '1',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                  keyboardType: TextInputType.number,
                ),

                // Min / Max Rental Days
                const MyText(text: 'Min Rental Days', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.minRentalDaysController,
                  hint: '1',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                  keyboardType: TextInputType.number,
                ),
                const MyText(text: 'Max Rental Days', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.maxRentalDaysController,
                  hint: '30',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                  keyboardType: TextInputType.number,
                ),

                // Tags
                const MyText(text: 'Tags (comma separated)', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.tagsController,
                  hint: 'e.g. nike, shoes, sport',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),

                // Availability
                const MyText(text: 'Available From (YYYY-MM-DD)', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.availableFromController,
                  hint: 'e.g. 2026-06-01',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),
                const MyText(text: 'Available To (YYYY-MM-DD)', size: 14, weight: FontWeight.w500, color: Colors.black87),
                const Gap(8),
                MyTextField(
                  controller: controller.availableToController,
                  hint: 'e.g. 2026-09-30',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: Colors.white,
                ),
                const Gap(8),

                MyButton(
                  onTap: () {
                    final rawPrice = controller.priceController.text.trim();
                    final parsedPrice = double.tryParse(rawPrice);
                    final Map<String, dynamic> priceUpdates;
                    if (localPriceType == 'Per Week') {
                      priceUpdates = {
                        'priceType': 'Per Week',
                        'weeklyRate': rawPrice,
                        'dailyRate': parsedPrice != null
                            ? (parsedPrice / 7).toStringAsFixed(2)
                            : '',
                      };
                    } else if (localPriceType == 'Per Month') {
                      priceUpdates = {
                        'priceType': 'Per Month',
                        'monthlyRate': rawPrice,
                        'dailyRate': parsedPrice != null
                            ? (parsedPrice / 30).toStringAsFixed(2)
                            : '',
                      };
                    } else {
                      priceUpdates = {
                        'priceType': 'Per Day',
                        'dailyRate': rawPrice,
                      };
                    }

                    final tagsText = controller.tagsController.text.trim();
                    final tagsList = tagsText.isEmpty
                        ? <String>[]
                        : tagsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    final fromText = controller.availableFromController.text.trim();
                    final toText = controller.availableToController.text.trim();

                    setState(() {
                      itemDraft = {
                        ...?itemDraft,
                        ...priceUpdates,
                        'title': controller.titleController.text.trim(),
                        'description': controller.descriptionController.text.trim(),
                        'quantity': controller.quantityController.text.trim(),
                        'minRentalDays': controller.minRentalDaysController.text.trim(),
                        'maxRentalDays': controller.maxRentalDaysController.text.trim(),
                        'tags': tagsList,
                        if (fromText.isNotEmpty && toText.isNotEmpty)
                          'availability': {'availableFrom': fromText, 'availableTo': toText},
                      };
                    });
                    Get.back();
                  },
                  buttonText: 'Save',
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

  // ── Address-only edit sheet ───────────────────────────────────────────────
  void _showEditAddressSheet(AddItemController controller) {
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
        child: _AddressPickerSheet(
          initialLocation: itemDraft?['location'],
          cityController: controller.cityController,
          provinceController: controller.provinceController,
          countryController: controller.countryController,
          latController: controller.latController,
          lngController: controller.lngController,
          onSave: (updatedLocation) {
            setState(() {
              itemDraft = {...?itemDraft, 'location': updatedLocation};
            });
            Get.back();
          },
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
                  final mergedDraft = {
                    ...?itemDraft,
                    'bookingType': bookingType ?? 'manual',
                  };
                  // Delivery schedule uses same weekly windows when rentalType includes delivery
                  final deliverySchedule = (rentalType == 'delivery' || rentalType == 'both')
                      ? pickupSchedule
                      : null;

                  final didCreate = await addItemController.createItemWithScheduleAndBoost(
                    mergedDraft,
                    pickupSchedule: pickupSchedule,
                    deliverySchedule: deliverySchedule,
                    boosted: boosted,
                  );
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
                        onTap: () => _showEditProductSheet(addItemController),
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
                  Builder(builder: (_) {
                    final priceType = (itemDraft?['priceType'] ?? 'Per Day').toString();
                    final priceKey = priceType == 'Per Week'
                        ? 'weeklyRate'
                        : priceType == 'Per Month'
                            ? 'monthlyRate'
                            : 'dailyRate';
                    final displayPrice = (itemDraft?[priceKey] ?? '0.00').toString();
                    final periodLabel = priceType == 'Per Week'
                        ? '/ Week'
                        : priceType == 'Per Month'
                            ? '/ Month'
                            : '/ Day';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const MyText(text: 'Price', size: 14, color: kSubText),
                        Row(
                          children: [
                            MyText(
                              text: 'CAD \$$displayPrice ',
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                            MyText(text: periodLabel, size: 14, color: kSubText, weight: FontWeight.w500),
                          ],
                        ),
                      ],
                    );
                  }),
                  if (rentalType == 'delivery' || rentalType == 'both') ...[
                    const Gap(12),
                    Builder(builder: (_) {
                      final fee = itemDraft?['deliveryFee'];
                      final feeStr = fee != null
                          ? 'CAD \$${(fee is num ? fee.toDouble() : double.tryParse(fee.toString()) ?? 0.0).toStringAsFixed(2)}'
                          : 'Not set';
                      return _SummaryRow(label: 'Delivery Fees', value: feeStr);
                    }),
                  ],
                  const Gap(12),
                  _SummaryRow(
                    label: 'Description',
                    value: (itemDraft?['description'] ?? '—').toString(),
                    valueMaxLines: 3,
                  ),
                  // Tags — safe for both String and List
                  Builder(builder: (_) {
                    final tagsRaw = itemDraft?['tags'];
                    final List<String> tagsList;
                    if (tagsRaw is List) {
                      tagsList = tagsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
                    } else if (tagsRaw is String && tagsRaw.trim().isNotEmpty) {
                      tagsList = tagsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                    } else {
                      tagsList = const [];
                    }
                    if (tagsList.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const Gap(12),
                        _SummaryRow(label: 'Tags', value: tagsList.join(', ')),
                      ],
                    );
                  }),
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

class _AddressPickerSheet extends StatefulWidget {
  const _AddressPickerSheet({
    required this.onSave,
    required this.cityController,
    required this.provinceController,
    required this.countryController,
    required this.latController,
    required this.lngController,
    this.initialLocation,
  });

  final Map<String, dynamic>? initialLocation;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController countryController;
  final TextEditingController latController;
  final TextEditingController lngController;
  final void Function(Map<String, dynamic>) onSave;

  @override
  State<_AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<_AddressPickerSheet> {
  final _addressService = AddressService();
  List<AddressModel> _addresses = [];
  bool _loading = true;
  int? _selectedIndex;
  bool _showManualForm = false;

  @override
  void initState() {
    super.initState();
    final loc = widget.initialLocation;
    if (loc != null) {
      widget.cityController.text = (loc['city'] ?? '').toString();
      widget.provinceController.text = (loc['province'] ?? '').toString();
      widget.countryController.text = (loc['country'] ?? 'Canada').toString();
      final coords = loc['coordinates'];
      if (coords is Map<String, dynamic>) {
        widget.latController.text = (coords['lat'] ?? '').toString();
        widget.lngController.text = (coords['lng'] ?? '').toString();
      }
    }
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final result = await _addressService.getAddresses();
    if (!mounted) return;
    setState(() {
      _addresses = result.addresses;
      _loading = false;
      if (_addresses.isEmpty) _showManualForm = true;
    });
  }

  void _save() {
    if (_selectedIndex != null) {
      final addr = _addresses[_selectedIndex!];
      final location = <String, dynamic>{
        'city': addr.city ?? '',
        'province': addr.province ?? '',
        'country': (addr.country?.isNotEmpty == true) ? addr.country! : 'Canada',
      };
      if (addr.coordinates?.lat != null && addr.coordinates?.lng != null) {
        location['coordinates'] = {
          'lat': addr.coordinates!.lat,
          'lng': addr.coordinates!.lng,
        };
      }
      widget.onSave(location);
      return;
    }
    final countryText = widget.countryController.text.trim();
    final location = <String, dynamic>{
      'city': widget.cityController.text.trim(),
      'province': widget.provinceController.text.trim(),
      'country': countryText.isEmpty ? 'Canada' : countryText,
    };
    final lat = double.tryParse(widget.latController.text.trim());
    final lng = double.tryParse(widget.lngController.text.trim());
    if (lat != null && lng != null) {
      location['coordinates'] = {'lat': lat, 'lng': lng};
    }
    widget.onSave(location);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                const MyText(
                  text: 'Back',
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          const Gap(16),
          const MyText(
            text: 'Edit Address',
            size: 20,
            weight: FontWeight.w600,
            color: Colors.black,
          ),
          const Gap(4),
          MyText(
            text: 'Select a saved address or enter a new one.',
            size: 14,
            color: Colors.grey[600],
          ),
          const Gap(16),
          Divider(color: kDividerColor),
          const Gap(12),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (_addresses.isNotEmpty) ...[
              const MyText(
                text: 'Saved Addresses',
                size: 14,
                weight: FontWeight.w600,
                color: Colors.black87,
              ),
              const Gap(10),
              ..._addresses.asMap().entries.map((entry) {
                final i = entry.key;
                final addr = entry.value;
                final isSelected = _selectedIndex == i;
                final parts = [
                  if (addr.label?.isNotEmpty == true) addr.label!,
                  if (addr.addressLine?.isNotEmpty == true) addr.addressLine!,
                  if (addr.city?.isNotEmpty == true) addr.city!,
                  if (addr.province?.isNotEmpty == true) addr.province!,
                  if (addr.country?.isNotEmpty == true) addr.country!,
                ];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedIndex = i;
                    _showManualForm = false;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor.withOpacity(0.08)
                          : kWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? kPrimaryColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (addr.label?.isNotEmpty == true)
                                MyText(
                                  text: addr.label!,
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: kBlack,
                                ),
                              MyText(
                                text: parts.join(', '),
                                size: 12,
                                color: kSubText,
                                maxLines: 2,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                              if (addr.isDefault) ...[
                                const Gap(2),
                                MyText(
                                  text: 'Default',
                                  size: 11,
                                  color: kPrimaryColor,
                                  weight: FontWeight.w500,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const Gap(4),
              Divider(color: kDividerColor),
              const Gap(8),
            ],

            // Toggle manual form
            GestureDetector(
              onTap: () => setState(() {
                _showManualForm = !_showManualForm;
                if (_showManualForm) _selectedIndex = null;
              }),
              child: Row(
                children: [
                  Icon(
                    _showManualForm
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                  const Gap(6),
                  MyText(
                    text: _showManualForm
                        ? 'Hide manual address'
                        : 'Enter a different address',
                    size: 14,
                    color: kPrimaryColor,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),

            if (_showManualForm) ...[
              const Gap(14),
              const MyText(
                text: 'City *',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.black87,
              ),
              const Gap(8),
              MyTextField(
                controller: widget.cityController,
                hint: 'e.g. Montreal',
                hintColor: kBlack.withOpacity(0.4),
                radius: 12,
                backgroundColor: Colors.white,
              ),
              const MyText(
                text: 'Province *',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.black87,
              ),
              const Gap(8),
              MyTextField(
                controller: widget.provinceController,
                hint: 'e.g. QC',
                hintColor: kBlack.withOpacity(0.4),
                radius: 12,
                backgroundColor: Colors.white,
              ),
              const MyText(
                text: 'Country',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.black87,
              ),
              const Gap(8),
              MyTextField(
                controller: widget.countryController,
                hint: 'Canada',
                hintColor: kBlack.withOpacity(0.4),
                radius: 12,
                backgroundColor: Colors.white,
              ),
              const MyText(
                text: 'Latitude (optional)',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.black87,
              ),
              const Gap(8),
              MyTextField(
                controller: widget.latController,
                hint: 'e.g. 45.5017',
                hintColor: kBlack.withOpacity(0.4),
                radius: 12,
                backgroundColor: Colors.white,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const MyText(
                text: 'Longitude (optional)',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.black87,
              ),
              const Gap(8),
              MyTextField(
                controller: widget.lngController,
                hint: 'e.g. -73.5673',
                hintColor: kBlack.withOpacity(0.4),
                radius: 12,
                backgroundColor: Colors.white,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
            ],
          ],

          const Gap(16),
          MyButton(
            onTap: _save,
            buttonText: 'Save',
            fontColor: Colors.white,
            height: 56,
            radius: 28,
            hasgrad: false,
            fontSize: 17,
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
