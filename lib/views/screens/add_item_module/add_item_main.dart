import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/items/add_item_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/delivery_item.dart';
import 'package:zip_peer/views/screens/add_item_module/pickup_avalibility.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class AddNewItemScreen extends StatelessWidget {
  const AddNewItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddItemController>(
      init: Get.isRegistered<AddItemController>()
          ? Get.find<AddItemController>()
          : Get.put(AddItemController()),
      builder: (controller) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(50),
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: 'Add new item',
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                    MyText(
                      text: controller.selectedRentalIndex == 1
                          ? 'Step 1/4'
                          : 'Step 1/5',
                      size: 14,
                      color: kSubText,
                    ),
                  ],
                ),
                const Gap(20),

                // Upload Product Images
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CommonImageView(
                                  imagePath: Assets.imagesGallery,
                                  height: 40,
                                ),
                                const Gap(12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Upload Product Images',
                                        size: 16,
                                        weight: FontWeight.w600,
                                      ),
                                      MyText(
                                        text: 'Multiple images allowed (max 5)',
                                        size: 12,
                                        color: kSubText,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          MyButton(
                            height: 50,
                            onTap: controller.pickPhotos,
                            buttonText: 'Upload',
                            backgroundColor: kPrimaryColor.withOpacity(0.2),
                            fontColor: kPrimaryColor,
                            width: 100,
                            hasgrad: false,
                          ),
                        ],
                      ),
                      if (controller.selectedPhotos.isNotEmpty) ...[
                        const Gap(12),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.selectedPhotos.length,
                            separatorBuilder: (_, __) => const Gap(8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  CommonImageView(
                                    file: controller.selectedPhotos[index],
                                    height: 80,
                                    width: 80,
                                    radius: 10,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Bounce(
                                      onTap: () {
                                        controller.selectedPhotos.removeAt(
                                          index,
                                        );
                                        controller.update();
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap(20),

                // Title Field
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
                      MyText(
                        text: 'Title',
                        size: 14,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      const Gap(8),
                      MyTextField(
                        controller: controller.titleController,
                        hint: 'e.g. Nike Jordan 6',
                        hintColor: kBlack.withOpacity(0.4),
                        radius: 12,
                        backgroundColor: kbackground,
                        marginBottom: 0,
                        onChanged: controller.onFieldChanged,
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Category
                Container(
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
                      MyText(
                        text: 'Category',
                        size: 14,
                        paddingTop: 20,
                        paddingLeft: 16,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      CustomDropDown(
                        hint: 'Footwear',
                        items: controller.uiCategories,
                        selectedValue: controller.selectedCategory,
                        onChanged: controller.onCategoryChanged,
                        bgColor: Colors.white,
                        labelText: '',
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Condition
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kBlack.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: 'Condition',
                        size: 14,
                        paddingTop: 20,
                        paddingLeft: 16,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      CustomDropDown(
                        hint: 'used, good condition',
                        items: controller.uiConditions,
                        selectedValue: controller.selectedCondition,
                        onChanged: controller.onConditionChanged,
                        bgColor: Colors.white,
                        labelText: '',
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Price Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kWhite,
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
                            MyText(
                              text: 'Price',
                              size: 14,
                              color: kSubText,
                              weight: FontWeight.w500,
                            ),
                            const Gap(8),
                            MyTextField(
                              controller: controller.priceController,
                              hint: '0.00',
                              hintColor: kBlack.withOpacity(0.4),
                              radius: 12,
                              backgroundColor: kbackground,
                              marginBottom: 0,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: controller.onFieldChanged,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kWhite,
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
                            MyText(
                              text: 'Per',
                              size: 14,
                              paddingTop: 16,
                              paddingLeft: 16,
                              color: kSubText,
                              weight: FontWeight.w500,
                            ),
                            CustomDropDown(
                              marginBottom: 0,
                              hint: 'Per Day',
                              items: controller.uiPriceTypes,
                              selectedValue: controller.selectedPriceType,
                              onChanged: controller.onPriceTypeChanged,
                              bgColor: Colors.white,
                              labelText: '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // Product Description
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
                      MyText(
                        text: 'Product Description',
                        size: 14,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      const Gap(8),
                      MyTextField(
                        controller: controller.descriptionController,
                        hint: 'Describe your item...',
                        hintColor: kBlack.withOpacity(0.4),
                        radius: 12,
                        backgroundColor: kbackground,
                        maxLines: 4,
                        marginBottom: 0,
                        onChanged: controller.onFieldChanged,
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                if (controller.showRentalSelectionError)
                  Center(
                    child: MyText(
                      textAlign: TextAlign.center,
                      text:
                          'Selection Required. Please select a delivery option',
                      size: 16,
                      paddingBottom: 10,
                      color: kredColor,
                      weight: FontWeight.w500,
                    ),
                  ),

                // Rental Type Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: List.generate(controller.rentalTabs.length, (
                      index,
                    ) {
                      final isSelected =
                          controller.selectedRentalIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.onRentalTabChanged(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kPrimaryColor.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: MyText(
                                text: controller.rentalTabs[index],
                                size: 13,
                                weight: FontWeight.w600,
                                color: isSelected
                                    ? kPrimaryColor
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Gap(20),

                MyButton(
                  onTap: () {
                    if (!controller.validateBeforeContinue()) return;
                    final draft = controller.buildDraft();
                    final rentalType = controller.selectedRentalType;
                    if (rentalType == 'pickup') {
                      Get.to(
                        () => const PickupAvailabilityScreen(),
                        arguments: {
                          'rentalType': rentalType,
                          'itemDraft': draft,
                        },
                      );
                    } else {
                      Get.to(
                        () => const DeliveryFeeScreen(),
                        arguments: {
                          'rentalType': rentalType,
                          'itemDraft': draft,
                        },
                      );
                    }
                  },
                  buttonText: 'Continue',
                  fontColor: Colors.white,
                  height: 56,
                  radius: 28,
                  hasgrad: false,
                  fontSize: 17,
                ),
                const Gap(100),
              ],
            ),
          ),
        );
      },
    );
  }
}
