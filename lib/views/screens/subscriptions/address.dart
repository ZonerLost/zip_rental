import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/profile/address_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/views/screens/subscriptions/add_address.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class MyAddressesScreen extends StatelessWidget {
  const MyAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(
      init: AddressController(),
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSizes.DEFAULT,
            child: Column(
              children: [
                const Gap(20),
                Row(
                  children: [
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(imagePath: Assets.imagesBack, height: 50),
                    ),
                    const Gap(12),
                    const MyText(text: 'My Addresses', size: 16, weight: FontWeight.w600),
                  ],
                ),
                const Gap(24),
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.addresses.isEmpty
                          ? const Center(
                              child: MyText(
                                text: 'No addresses yet.\nTap below to add one.',
                                size: 14,
                                color: kSubText,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              itemCount: controller.addresses.length,
                              itemBuilder: (_, i) {
                                final address = controller.addresses[i];
                                return _AddressCard(
                                  address: address,
                                  onDelete: () => controller.deleteAddress(address.id),
                                  onSetDefault: address.isDefault
                                      ? null
                                      : () => controller.setDefault(address.id),
                                );
                              },
                            ),
                ),
                MyButton(
                  onTap: () async {
                    final added = await Get.to(() => const AddAddressScreen());
                    if (added == true) controller.loadAddresses();
                  },
                  buttonText: 'Add new address',
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
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onDelete,
    this.onSetDefault,
  });

  final AddressModel address;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: address.isDefault ? kPrimaryColor.withOpacity(0.07) : kWhite,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault ? Border.all(color: kPrimaryColor, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyText(
                      text: address.label ?? 'Address',
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                    if (address.isDefault) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const MyText(text: 'Default', size: 10, color: Colors.white, weight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
                const Gap(6),
                MyText(
                  text: address.displayAddress,
                  size: 13,
                  color: kSubText,
                  maxLines: 2,
                ),
                if (onSetDefault != null) ...[
                  const Gap(8),
                  Bounce(
                    onTap: onSetDefault!,
                    child: MyText(
                      text: 'Set as default',
                      size: 12,
                      color: kPrimaryColor,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Bounce(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.delete_outline, color: Colors.red, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
