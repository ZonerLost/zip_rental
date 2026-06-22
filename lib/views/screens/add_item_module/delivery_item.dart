import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/add_item_module/delivery_availability.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class DeliveryFeeScreen extends StatefulWidget {
  const DeliveryFeeScreen({super.key});

  @override
  State<DeliveryFeeScreen> createState() => _DeliveryFeeScreenState();
}

class _DeliveryFeeScreenState extends State<DeliveryFeeScreen> {
  final TextEditingController _flatFeeController = TextEditingController();

  // Each tier: maxKm (int) and price (double)
  final List<_TierEntry> _tiers = [_TierEntry()];

  bool _showError = false;
  String rentalType = 'delivery';
  Map<String, dynamic>? itemDraft;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['rentalType'] != null) {
        rentalType = Get.arguments['rentalType'];
      }
      if (Get.arguments['itemDraft'] is Map<String, dynamic>) {
        itemDraft = Get.arguments['itemDraft'] as Map<String, dynamic>;
      }
    }
  }

  @override
  void dispose() {
    _flatFeeController.dispose();
    for (final t in _tiers) {
      t.dispose();
    }
    super.dispose();
  }

  List<DeliveryPricingTier> _buildTiers() {
    final result = <DeliveryPricingTier>[];
    for (final t in _tiers) {
      final km = int.tryParse(t.kmController.text.trim());
      final price = double.tryParse(t.priceController.text.trim());
      if (km != null && price != null && km > 0 && price >= 0) {
        result.add(DeliveryPricingTier(maxKm: km, price: price));
      }
    }
    return result;
  }

  bool _validate() {
    final flat = _flatFeeController.text.trim();
    final parsedFlat = double.tryParse(flat);
    if (flat.isEmpty || parsedFlat == null || parsedFlat < 0) {
      setState(() => _showError = true);
      return false;
    }
    if (_tiers.isEmpty || _buildTiers().isEmpty) {
      setState(() => _showError = true);
      return false;
    }
    return true;
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
              onTap: () {
                if (!_validate()) return;

                final flatFee = double.parse(_flatFeeController.text.trim());
                final tiers = _buildTiers();

                Get.to(
                  () => const DeliveryAvailabilityScreen(),
                  arguments: {
                    'rentalType': rentalType,
                    'itemDraft': {
                      ...?itemDraft,
                      'deliveryFee': flatFee,
                      'deliveryPricingTiers': tiers,
                    },
                  },
                );
              },
              buttonText: 'Continue',
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
      body: AnimatedListView(
        padding: const EdgeInsets.all(20),
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
                      text: 'Delivery Fee',
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              const MyText(text: 'Step 2/5', size: 14, color: kSubText),
            ],
          ),
          const Gap(24),

          // Flat fallback fee
          Container(
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
                const MyText(
                  text: 'Flat Fallback Fee (CAD)',
                  size: 16,
                  weight: FontWeight.w600,
                ),
                const Gap(4),
                MyText(
                  text: 'Charged when no distance tier matches.',
                  size: 12,
                  color: kSubText,
                ),
                const Gap(12),
                MyTextField(
                  controller: _flatFeeController,
                  hint: 'e.g. 15.00',
                  hintColor: kBlack.withOpacity(0.4),
                  radius: 12,
                  backgroundColor: kbackground,
                  marginBottom: 0,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() => _showError = false),
                ),
              ],
            ),
          ),
          const Gap(20),

          // Distance-based tiers
          const MyText(
            text: 'Distance Pricing Tiers',
            size: 16,
            weight: FontWeight.w600,
          ),
          const Gap(4),
          MyText(
            text: 'Set a price per distance range (e.g. up to 10 km → \$10).',
            size: 12,
            color: kSubText,
          ),
          const Gap(12),

          ...List.generate(_tiers.length, (i) {
            final tier = _tiers[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: 'Tier ${i + 1}',
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                        if (_tiers.length > 1)
                          Bounce(
                            onTap: () {
                              setState(() {
                                _tiers[i].dispose();
                                _tiers.removeAt(i);
                              });
                            },
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: 'Max km',
                                size: 12,
                                color: kSubText,
                              ),
                              const Gap(6),
                              MyTextField(
                                controller: tier.kmController,
                                hint: 'e.g. 10',
                                hintColor: kBlack.withOpacity(0.4),
                                radius: 10,
                                backgroundColor: kbackground,
                                marginBottom: 0,
                                keyboardType: TextInputType.number,
                                onChanged: (_) =>
                                    setState(() => _showError = false),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: 'Price (CAD)',
                                size: 12,
                                color: kSubText,
                              ),
                              const Gap(6),
                              MyTextField(
                                controller: tier.priceController,
                                hint: 'e.g. 10.00',
                                hintColor: kBlack.withOpacity(0.4),
                                radius: 10,
                                backgroundColor: kbackground,
                                marginBottom: 0,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) =>
                                    setState(() => _showError = false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          Bounce(
            onTap: () {
              setState(() => _tiers.add(_TierEntry()));
            },
            child: Row(
              children: [
                const Icon(Icons.add, color: kPrimaryColor, size: 20),
                const Gap(8),
                MyText(
                  text: 'Add tier',
                  size: 16,
                  color: kPrimaryColor,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ),

          if (_showError) ...[
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: kredColor, size: 24),
                const Gap(8),
                const MyText(
                  text: 'Please fill in a flat fee and at least one tier.',
                  size: 14,
                  color: kredColor,
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ],

          const Gap(100),
        ],
      ),
    );
  }
}

class _TierEntry {
  final TextEditingController kmController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    kmController.dispose();
    priceController.dispose();
  }
}
