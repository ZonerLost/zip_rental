// ignore_for_file: prefer_final_fields

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/favourites/favourites_controller.dart';
import 'package:zip_peer/controllers/items/item_details_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/controllers/chat/chat_controller.dart';
import 'package:zip_peer/views/screens/chat_module/chat_messages.dart';
import 'package:zip_peer/views/screens/home/item_detail/check_out_2.dart';
import 'package:zip_peer/views/screens/home/item_detail/comments.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _monthCount = 1;
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemDetailsController>(
      init: ItemDetailsController(itemId: widget.itemId),
      builder: (controller) {
        final item = controller.item;

        return Scaffold(
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text:
                                '${item?.currency ?? 'CAD'} ${(item?.dailyRate ?? 0).toStringAsFixed(2)}',
                            size: 24,
                            weight: FontWeight.w700,
                          ),
                          MyText(
                            text: 'Total amount',
                            size: 14,
                            color: kSubText,
                          ),
                        ],
                      ),
                      const Gap(12),
                      // Message owner button — hidden when item is null or
                      // owner id is missing
                      if ((item?.ownerId ?? item?.owner?.id ?? '').isNotEmpty)
                        Bounce(
                          onTap: () => _showStartChatSheet(item!),
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: kPrimaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      const Gap(12),
                      Expanded(
                        child: MyButton(
                          onTap: () {
                            if (item == null) {
                              return;
                            }
                            Get.to(() => CheckoutScreen2(item: item));
                          },
                          buttonText: 'Book Now',
                          height: 56,
                          radius: 30,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
              ? _ErrorView(
                  message: controller.errorMessage!,
                  onRetry: controller.fetchItem,
                )
              : item == null
              ? const _ErrorView(message: 'Item not found')
              : _buildContent(item),
        );
      },
    );
  }

  Widget _buildContent(ItemModel item) {
    final photos = item.photos;
    final hasPhotos = photos.isNotEmpty;

    final ownerPhoto = item.owner?.profilePhoto ?? '';
    final hasOwnerPhoto =
        ownerPhoto.startsWith('http://') || ownerPhoto.startsWith('https://');

    final locationText = item.location?.fullLocation.isNotEmpty == true
        ? item.location!.fullLocation
        : 'Location unavailable';

    return AnimatedListView(
      padding: const EdgeInsets.all(10),
      children: [
        const Gap(50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Bounce(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: kWhite,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 24),
              ),
            ),
            GetBuilder<FavouritesController>(
              builder: (favCtrl) {
                final isFav = favCtrl.isFavourite(item.id);
                return Bounce(
                  onTap: () => favCtrl.toggle(FavItem(
                    id: item.id,
                    title: item.title ?? '',
                    price:
                        '${item.currency ?? 'CAD'} ${item.dailyRate?.toStringAsFixed(2) ?? '0.00'}',
                    imageUrl: item.thumbnailUrl,
                    ownerName: item.ownerName,
                    ownerPhoto: item.owner?.profilePhoto ?? '',
                  )),
                  child: CommonImageView(
                    imagePath: isFav
                        ? Assets.imagesHeartFilled
                        : Assets.imagesHeartEmpty,
                    height: 50,
                  ),
                );
              },
            ),
          ],
        ),
        const Gap(20),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SizedBox(
                  height: 350,
                  child: hasPhotos
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: photos.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return CommonImageView(
                              height: 350,
                              width: double.infinity,
                              url: photos[index],
                              fit: BoxFit.cover,
                              placeHolder: Assets.imagesShoes1,
                            );
                          },
                        )
                      : CommonImageView(
                          height: 350,
                          width: double.infinity,
                          imagePath: Assets.imagesShoes1,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      hasPhotos ? photos.length.clamp(0, 5) : 1,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentImageIndex ? 25 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: MyText(
                      text:
                          '${hasPhotos ? _currentImageIndex + 1 : 1}/${hasPhotos ? photos.length : 1}',
                      size: 14,
                      color: kBlack,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 20,
              right: 20,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Bounce(
                      onTap: () {
                        if (_monthCount > 1) {
                          setState(() {
                            _monthCount--;
                          });
                        }
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesMinusItemDetail,
                        height: 50,
                      ),
                    ),
                    MyText(
                      text: '${_monthCount.toString().padLeft(2, '0')} Month',
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                    Bounce(
                      onTap: () {
                        setState(() {
                          _monthCount++;
                        });
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesAddItemDetail,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(10),
        Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: item.title ?? 'Untitled item',
                          size: 24,
                          weight: FontWeight.w700,
                        ),
                        const Gap(8),
                        MyText(
                          text:
                              '${item.totalRentals ?? 0} Times rented | ${item.condition ?? 'n/a'}',
                          size: 14,
                          color: kSubText,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyText(
                        text:
                            '${item.currency ?? 'CAD'} ${(item.dailyRate ?? 0).toStringAsFixed(2)}',
                        size: 20,
                        weight: FontWeight.w700,
                      ),
                      MyText(text: '/ day', size: 14, color: kSubText),
                    ],
                  ),
                ],
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CommonImageView(
                          imagePath: hasOwnerPhoto
                              ? null
                              : Assets.imagesChatAvatar,
                          url: hasOwnerPhoto ? ownerPhoto : null,
                          placeHolder: Assets.imagesChatAvatar,
                          height: 40,
                          width: 40,
                          radius: 20,
                        ),
                        const Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: item.ownerName,
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                            const Gap(4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const Gap(4),
                                MyText(
                                  text:
                                      '${(item.owner?.averageRating ?? item.averageRating ?? 0).toStringAsFixed(1)} ratings',
                                  size: 14,
                                  color: kBlack,
                                ),
                                const Gap(12),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Bounce(
                      onTap: () {
                        Get.to(() => const CommentsScreen());
                      },
                      child: CommonImageView(
                        imagePath: Assets.imagesCommentsNewIcon,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              MyText(
                text: (item.description ?? '').isNotEmpty
                    ? item.description!
                    : 'No description available.',
                size: 14,
                color: kSubText,
              ),
              const Gap(20),

              // ── Listing Details ───────────────────────────────────────────
              _DetailSection(
                title: 'Listing Details',
                children: [
                  if ((item.category ?? '').isNotEmpty)
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: item.category!,
                    ),
                  if ((item.subCategory ?? '').isNotEmpty)
                    _DetailRow(
                      icon: Icons.label_outline,
                      label: 'Sub-category',
                      value: item.subCategory!,
                    ),
                  _DetailRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Condition',
                    value: item.condition ?? 'n/a',
                  ),
                  _DetailRow(
                    icon: item.bookingType == 'instant'
                        ? Icons.bolt
                        : Icons.pending_actions_outlined,
                    label: 'Booking',
                    value: item.bookingType == 'instant'
                        ? 'Instant (auto-confirmed)'
                        : 'Manual approval',
                    valueColor: item.bookingType == 'instant'
                        ? Colors.green.shade700
                        : null,
                  ),
                  if (item.quantity != null && item.quantity! > 1)
                    _DetailRow(
                      icon: Icons.layers_outlined,
                      label: 'Quantity',
                      value: '${item.quantity}',
                    ),
                  if (item.tags.isNotEmpty) ...[
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: item.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: MyText(
                          text: '#$tag',
                          size: 12,
                          color: kPrimaryColor,
                          weight: FontWeight.w500,
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
              const Gap(16),

              // ── Rental Terms ──────────────────────────────────────────────
              _DetailSection(
                title: 'Rental Terms',
                children: [
                  _DetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Status',
                    value: (item.availability?.isAvailable ?? true)
                        ? 'Available for booking'
                        : 'Currently unavailable',
                    valueColor: (item.availability?.isAvailable ?? true)
                        ? Colors.green.shade700
                        : Colors.red.shade600,
                  ),
                  if (item.minRentalDays != null || item.maxRentalDays != null)
                    _DetailRow(
                      icon: Icons.date_range_outlined,
                      label: 'Rental Duration',
                      value: _rentalDurationLabel(
                        item.minRentalDays,
                        item.maxRentalDays,
                      ),
                    ),
                  if (item.weeklyRate != null)
                    _DetailRow(
                      icon: Icons.attach_money,
                      label: 'Weekly Rate',
                      value:
                          '${item.currency ?? 'CAD'} ${item.weeklyRate!.toStringAsFixed(2)}',
                    ),
                  if (item.monthlyRate != null)
                    _DetailRow(
                      icon: Icons.attach_money,
                      label: 'Monthly Rate',
                      value:
                          '${item.currency ?? 'CAD'} ${item.monthlyRate!.toStringAsFixed(2)}',
                    ),
                  if ((item.availability?.blockedDates ?? const <String>[])
                      .isNotEmpty) ...[
                    const Gap(8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.block,
                          size: 18,
                          color: kSubText,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MyText(
                                text: 'Blocked Dates',
                                size: 13,
                                color: kSubText,
                              ),
                              const Gap(4),
                              MyText(
                                text: item.availability!.blockedDates
                                    .join(', '),
                                size: 13,
                                weight: FontWeight.w500,
                                color: kBlack,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const Gap(16),

              // ── Delivery & Pickup ─────────────────────────────────────────
              _DetailSection(
                title: 'Delivery & Pickup',
                children: [
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: locationText,
                  ),
                  if (item.rentalType != null) ...[
                    _DetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Rental Type',
                      value: _rentalTypeLabel(item.rentalType!),
                    ),
                  ] else if (item.deliveryFee != null ||
                      item.deliveryPricing.isNotEmpty) ...[
                    _DetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: 'Rental Type',
                      value: 'Delivery & Pickup',
                    ),
                  ],
                  if (item.deliveryFee != null)
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Flat Delivery Fee',
                      value:
                          '${item.currency ?? 'CAD'} ${item.deliveryFee!.toStringAsFixed(2)}',
                    ),
                  if (item.deliveryPricing.isNotEmpty) ...[
                    const Gap(12),
                    const MyText(
                      text: 'Distance-based pricing',
                      size: 13,
                      color: kSubText,
                      weight: FontWeight.w600,
                    ),
                    const Gap(8),
                    ...item.deliveryPricing.map(
                      (tier) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: 'Up to ${tier.maxKm} km',
                              size: 13,
                              color: kSubText,
                            ),
                            MyText(
                              text:
                                  '${item.currency ?? 'CAD'} ${tier.price.toStringAsFixed(2)}',
                              size: 13,
                              weight: FontWeight.w600,
                              color: kBlack,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(50),
            ],
          ),
        ),
      ],
    );
  }

  void _showStartChatSheet(ItemModel item) {
    final msgCtrl = TextEditingController();
    final ownerId = item.ownerId ?? item.owner?.id ?? '';
    final ownerName =
        '${item.owner?.firstName ?? ''} ${item.owner?.lastName ?? ''}'.trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: 'Message ${ownerName.isEmpty ? 'Owner' : ownerName}',
              size: 18,
              weight: FontWeight.w600,
              color: kBlack,
            ),
            const Gap(16),
            TextField(
              controller: msgCtrl,
              autofocus: true,
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: MyButton(
                buttonText: 'Send',
                height: 52,
                radius: 30,
                fontSize: 16,
                onTap: () async {
                  final text = msgCtrl.text.trim();
                  if (text.isEmpty) return;
                  Get.back();
                  final chatCtrl = Get.isRegistered<ChatController>()
                      ? Get.find<ChatController>()
                      : Get.put(ChatController());
                  final convId = await chatCtrl.startConversation(
                    otherUserId: ownerId,
                    message: text,
                    itemId: item.id,
                  );
                  if (convId == null) return;
                  Get.to(
                    () => ChatMessagesScreen(
                      conversationId: convId,
                      participantName: ownerName.isEmpty ? 'Owner' : ownerName,
                      participantPhoto: item.owner?.profilePhoto,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _rentalDurationLabel(int? min, int? max) {
  if (min != null && max != null) return '$min – $max days';
  if (min != null) return 'Min $min day${min == 1 ? '' : 's'}';
  if (max != null) return 'Max $max day${max == 1 ? '' : 's'}';
  return 'n/a';
}

String _rentalTypeLabel(String type) {
  switch (type) {
    case 'delivery':
      return 'Delivery Only';
    case 'pickup':
      return 'Pickup Only';
    case 'both':
      return 'Delivery & Pickup';
    default:
      return type;
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(text: title, size: 16, weight: FontWeight.w700, color: kBlack),
          const Gap(14),
          const Divider(height: 1),
          const Gap(14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: kSubText),
          const Gap(10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(text: label, size: 13, color: kSubText),
                const Gap(8),
                Flexible(
                  child: MyText(
                    text: value,
                    size: 13,
                    weight: FontWeight.w600,
                    color: valueColor ?? kBlack,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText(
              text: message,
              size: 14,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(12),
              Bounce(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: MyText(
                    text: 'Retry',
                    size: 13,
                    color: kPrimaryColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
