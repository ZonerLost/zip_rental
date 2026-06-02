import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/items/my_listings_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ListingItemDetailsScreen extends StatefulWidget {
  const ListingItemDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<ListingItemDetailsScreen> createState() =>
      _ListingItemDetailsScreenState();
}

class _ListingItemDetailsScreenState extends State<ListingItemDetailsScreen> {
  late final MyListingsController _controller;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = true;
  String? _error;
  ItemModel? _item;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<MyListingsController>()
        ? Get.find<MyListingsController>()
        : Get.put(MyListingsController());
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final item = await _controller.getListingDetails(widget.itemId);

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _item = item;
      if (item == null) {
        _error = 'Unable to load item details.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    radius: 25,
                    onTap: () {
                      if (item == null) {
                        return;
                      }
                      _confirmDelete();
                    },
                    buttonText: 'Delete',
                    fontColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.15),
                    hasgrad: false,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: MyButton(
                    radius: 25,
                    onTap: () {
                      if (item == null) {
                        return;
                      }
                      _openEditSheet();
                    },
                    buttonText: 'Edit',
                    backgroundColor: kPrimaryColor,
                    hasgrad: false,
                  ),
                ),
              ],
            ),
            const Gap(12),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: () => _loadDetails())
          : item == null
          ? _ErrorView(message: 'Item not found', onRetry: () => _loadDetails())
          : AnimatedListView(
              padding: AppSizes.DEFAULT,
              children: [
                const Gap(50),
                Row(
                  children: [
                    Bounce(
                      onTap: () => Get.back(),
                      child: CommonImageView(
                        imagePath: Assets.imagesBack,
                        height: 45,
                      ),
                    ),
                    const Gap(12),
                    MyText(
                      text: 'Item Details',
                      size: 20,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: kPrimaryColor),
                      const Gap(12),
                      Expanded(
                        child: MyText(
                          text:
                              'Together, we saved ${item.totalRentals ?? 0} rental trips with this item and made sustainable choices!',
                          size: 14,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CommonImageView(
                              imagePath: item.thumbnailUrl.isNotEmpty
                                  ? null
                                  : Assets.imagesShoes1,
                              url: item.thumbnailUrl.isNotEmpty
                                  ? item.thumbnailUrl
                                  : null,
                              placeHolder: Assets.imagesShoes1,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: item.title ?? 'Untitled',
                                  size: 20,
                                  weight: FontWeight.w600,
                                ),
                                const Gap(4),
                                MyText(
                                  text:
                                      '${item.category ?? '-'} | ${(item.currency ?? 'CAD')} ${(item.dailyRate ?? 0).toStringAsFixed(2)}',
                                  size: 14,
                                  color: kSubText,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: (item.isActive ?? true)
                                  ? kPrimaryColor.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: MyText(
                              text: (item.isActive ?? true)
                                  ? 'Active'
                                  : 'Inactive',
                              size: 13,
                              color: (item.isActive ?? true)
                                  ? kPrimaryColor
                                  : Colors.grey.shade700,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      Divider(color: kBorderColor),
                      const Gap(16),
                      _detailRow('Condition', item.condition ?? '-'),
                      _detailRow('Category', item.category ?? '-'),
                      _detailRow(
                        'Rating',
                        (item.averageRating ?? 0).toStringAsFixed(1),
                      ),
                      _detailRow('Total Rentals', '${item.totalRentals ?? 0}'),
                      _detailRow(
                        'Price',
                        '${item.currency ?? 'CAD'} ${(item.dailyRate ?? 0).toStringAsFixed(2)}/day',
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
                const Gap(12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bounce(
                        onTap: () => _uploadPhotos(item),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: kPrimaryColor,
                            ),
                            const Gap(8),
                            MyText(
                              text: 'Upload Photos',
                              size: 14,
                              color: kPrimaryColor,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      Bounce(
                        onTap: () => _deleteFirstPhoto(item),
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline, color: Colors.red),
                            const Gap(8),
                            MyText(
                              text: 'Delete Photo',
                              size: 14,
                              color: Colors.red,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesMapPin2,
                        height: 40,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: 'Home Address',
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                            const Gap(4),
                            MyText(
                              text: item.location?.fullLocation ?? '-',
                              size: 14,
                              color: kSubText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CommonImageView(
                        imagePath: Assets.imagesNewCalender2,
                        height: 40,
                      ),
                      const Gap(16),
                      Expanded(
                        child: MyText(
                          text: 'Availability',
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Bounce(
                        onTap: () => _editBlockedDates(item),
                        child: const Icon(
                          Icons.edit_calendar_outlined,
                          color: kPrimaryColor,
                        ),
                      ),
                      const Gap(8),
                      Switch(
                        value: !(item.isPaused ?? false),
                        onChanged: (_) async {
                          await _controller.togglePause(item.id);
                          await _loadDetails();
                        },
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                const Gap(100),
              ],
            ),
    );
  }

  Future<void> _editBlockedDates(ItemModel item) async {
    final blockedDatesController = TextEditingController(
      text: (item.availability?.blockedDates ?? const <String>[]).join(', '),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Blocked Dates (YYYY-MM-DD, comma separated)'),
              const Gap(8),
              TextField(controller: blockedDatesController),
              const Gap(12),
              MyButton(
                onTap: () async {
                  final blockedDates = blockedDatesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(growable: false);

                  final isValid = blockedDates.every((date) {
                    final regex = RegExp(r'^\\d{4}-\\d{2}-\\d{2}$');
                    return regex.hasMatch(date);
                  });

                  if (!isValid) {
                    Get.snackbar(
                      'Invalid Dates',
                      'Use format YYYY-MM-DD for each date.',
                    );
                    return;
                  }

                  await _controller.updateBlockedDates(item.id, blockedDates);
                  if (!bottomSheetContext.mounted) {
                    return;
                  }
                  Navigator.of(bottomSheetContext).pop();
                  await _loadDetails();
                },
                buttonText: 'Save Dates',
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadPhotos(ItemModel item) async {
    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) {
      return;
    }

    if (picked.length > 5) {
      Get.snackbar('Invalid Selection', 'Maximum 5 images are allowed.');
      return;
    }

    final filePaths = picked.map((e) => e.path).toList(growable: false);
    await _controller.uploadPhotos(item.id, filePaths);
    await _loadDetails();
  }

  Future<void> _deleteFirstPhoto(ItemModel item) async {
    if (item.photos.isEmpty) {
      Get.snackbar('No Photos', 'There is no photo to delete.');
      return;
    }
    await _controller.deletePhoto(item.id, item.photos.first);
    await _loadDetails();
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(text: title, size: 14, color: kSubText),
          MyText(text: value, size: 14, weight: FontWeight.w600),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final item = _item;
    if (item == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Listing'),
          content: const Text('Are you sure you want to delete this listing?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final deleted = await _controller.deleteListing(item.id);
    if (!deleted) {
      return;
    }

    if (!mounted) {
      return;
    }

    Get.back();
    Get.snackbar('Success', 'Listing deleted successfully.');
  }

  Future<void> _openEditSheet() async {
    final item = _item;
    if (item == null) {
      return;
    }

    final titleController = TextEditingController(text: item.title ?? '');
    final descriptionController = TextEditingController(
      text: item.description ?? '',
    );
    final rateController = TextEditingController(
      text: (item.dailyRate ?? 0).toStringAsFixed(2),
    );
    final conditionController = TextEditingController(
      text: item.condition ?? '',
    );
    final tagsController = TextEditingController(text: item.tags.join(', '));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Daily Rate'),
              ),
              TextField(
                controller: conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condition (new/like_new/good/fair)',
                ),
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
              const Gap(12),
              MyButton(
                onTap: () async {
                  final parsedRate = double.tryParse(
                    rateController.text.trim(),
                  );
                  final request = UpdateItemRequest(
                    title: _updatedValue(item.title, titleController.text),
                    description: _updatedValue(
                      item.description,
                      descriptionController.text,
                    ),
                    dailyRate:
                        parsedRate != null &&
                            parsedRate > 0 &&
                            parsedRate != item.dailyRate
                        ? parsedRate
                        : null,
                    condition: _updatedValue(
                      item.condition,
                      conditionController.text,
                    ),
                    tags: _updatedTags(item.tags, tagsController.text),
                  );

                  final updated = await _controller.updateListing(
                    item.id,
                    request,
                  );
                  if (updated == null) {
                    return;
                  }

                  if (!mounted) {
                    return;
                  }

                  if (!bottomSheetContext.mounted) {
                    return;
                  }
                  Navigator.of(bottomSheetContext).pop();
                  setState(() {
                    _item = updated;
                  });
                  Get.snackbar('Success', 'Item updated successfully.');
                },
                buttonText: 'Save Changes',
              ),
            ],
          ),
        );
      },
    );
  }

  String? _updatedValue(String? oldValue, String newValue) {
    final trimmed = newValue.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if ((oldValue ?? '').trim() == trimmed) {
      return null;
    }
    return trimmed;
  }

  List<String>? _updatedTags(List<String> oldTags, String rawTags) {
    final parsed = rawTags
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    if (parsed.isEmpty) {
      return null;
    }

    if (parsed.length == oldTags.length) {
      var allSame = true;
      for (var i = 0; i < parsed.length; i++) {
        if (parsed[i] != oldTags[i]) {
          allSame = false;
          break;
        }
      }
      if (allSame) {
        return null;
      }
    }

    return parsed;
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
        padding: const EdgeInsets.all(20),
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
                onTap: () {
                  onRetry!.call();
                },
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
