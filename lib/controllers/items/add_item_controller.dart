import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/items/item_api_service.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class AddItemController extends GetxController {
  AddItemController({
    ItemApiService? itemApiService,
    ProfileService? profileService,
  }) : _itemApiService = itemApiService ?? ItemApiService(),
       _profileService = profileService ?? ProfileService();

  final ItemApiService _itemApiService;
  final ProfileService _profileService;
  final ImagePicker _imagePicker = ImagePicker();

  final List<File> selectedPhotos = <File>[];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();

  final List<String> rentalTabs = const <String>[
    'Delivery only',
    'Pickup only',
    'Enable Both',
  ];
  final List<String> uiCategories = const <String>[
    'Footwear',
    'Mens Outfit',
    'Womens Outfit',
    'Children Outfit',
    'Jacket',
    'Tools',
    'Electronics',
    'Cameras',
    'Sports',
    'Outdoor',
  ];
  final List<String> uiConditions = const <String>[
    'used, good condition',
    'new',
    'like new',
    'used, fair condition',
  ];
  final List<String> uiPriceTypes = const <String>[
    'Per Day',
    'Per Week',
    'Per Month',
  ];

  int? selectedRentalIndex;
  bool showRentalSelectionError = false;
  String selectedCategory = 'Footwear';
  String selectedCondition = 'used, good condition';
  String selectedPriceType = 'Per Day';
  bool isSubmitting = false;

  static const List<String> allowedCategories = <String>[
    'tools',
    'cycling',
    'electronics',
    'cameras',
    'audio',
    'kitchen',
    'furniture',
    'garden',
    'cleaning',
    'baby',
    'party',
    'vehicles',
    'camping',
    'winter_sports',
    'water_sports',
    'music',
    'sports',
    'outdoor',
    'power_tools',
    'other',
  ];

  static const List<String> allowedConditions = <String>[
    'new',
    'like_new',
    'good',
    'fair',
  ];

  @override
  void onInit() {
    super.onInit();
    titleController.text = '';
    priceController.text = '';
    descriptionController.text = '';
  }

  void onFieldChanged(String _) => update();

  void onCategoryChanged(dynamic value) {
    selectedCategory = value.toString();
    update();
  }

  void onConditionChanged(dynamic value) {
    selectedCondition = value.toString();
    update();
  }

  void onPriceTypeChanged(dynamic value) {
    selectedPriceType = value.toString();
    update();
  }

  void onRentalTabChanged(int index) {
    selectedRentalIndex = index;
    showRentalSelectionError = false;
    update();
  }

  bool validateBeforeContinue() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Title is required.');
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Price is required.');
      return false;
    }
    if (_asPositiveDouble(priceController.text.trim()) == null) {
      Get.snackbar('Validation', 'Price must be a valid number.');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Description is required.');
      return false;
    }
    if (selectedRentalIndex == null) {
      showRentalSelectionError = true;
      update();
      return false;
    }
    return true;
  }

  String get selectedRentalType {
    if (selectedRentalIndex == 0) {
      return 'delivery';
    }
    if (selectedRentalIndex == 1) {
      return 'pickup';
    }
    return 'both';
  }

  Map<String, dynamic> buildDraft() {
    return <String, dynamic>{
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory,
      'condition': selectedCondition,
      'dailyRate': priceController.text.trim(),
      'subCategory': null,
      'tags': _parseTags(tagsController.text),
      'photos': List<File>.of(selectedPhotos),
      'location': <String, dynamic>{
        'city': cityController.text.trim(),
        'province': provinceController.text.trim(),
        'country': countryController.text.trim().isEmpty
            ? 'Canada'
            : countryController.text.trim(),
        if (latController.text.trim().isNotEmpty &&
            lngController.text.trim().isNotEmpty)
          'coordinates': <String, dynamic>{
            'lat': double.tryParse(latController.text.trim()),
            'lng': double.tryParse(lngController.text.trim()),
          },
      },
    };
  }

  Future<void> pickPhotos() async {
    try {
      final picked = await _imagePicker.pickMultiImage();
      if (picked.isEmpty) {
        return;
      }

      final files = picked.map((e) => File(e.path)).toList(growable: false);

      if (files.length > 5) {
        Get.snackbar('Invalid Selection', 'You can upload maximum 5 images.');
        return;
      }

      for (final file in files) {
        final validationError = await _validateImageFile(file);
        if (validationError != null) {
          Get.snackbar('Invalid Image', validationError);
          return;
        }
      }

      selectedPhotos
        ..clear()
        ..addAll(files);
      update();
    } catch (_) {
      Get.snackbar('Image Picker Error', 'Unable to select images right now.');
    }
  }

  Future<bool> createItemFromDraft(Map<String, dynamic> draft) async {
    final title = (draft['title'] ?? '').toString().trim();
    final description = (draft['description'] ?? '').toString().trim();
    final rawCategory = (draft['category'] ?? '').toString();
    final rawCondition = (draft['condition'] ?? '').toString();
    final dailyRate = _asPositiveDouble(draft['dailyRate']);
    final tags = _parseTags(draft['tags']);

    final category = _mapCategory(rawCategory);
    final condition = _mapCondition(rawCondition);
    final photosToUpload = _extractDraftPhotos(draft) ?? selectedPhotos;

    if (title.isEmpty) {
      Get.snackbar('Validation', 'Title is required.');
      return false;
    }
    if (description.isEmpty) {
      Get.snackbar('Validation', 'Description is required.');
      return false;
    }
    if (category == null) {
      Get.snackbar('Validation', 'Category is required.');
      return false;
    }
    if (dailyRate == null || dailyRate <= 0) {
      Get.snackbar('Validation', 'Daily rate must be greater than 0.');
      return false;
    }
    if (condition == null) {
      Get.snackbar('Validation', 'Condition is required.');
      return false;
    }
    if (photosToUpload.isEmpty) {
      Get.snackbar('Validation', 'Please upload at least one photo.');
      return false;
    }

    final location = await _resolveLocationFromDraftOrProfile(draft);
    if ((location.city ?? '').trim().isEmpty) {
      Get.snackbar('Validation', 'Location city is required.');
      return false;
    }

    isSubmitting = true;
    update();

    try {
      final createdItem = await _itemApiService.createItem(
        CreateItemRequest(
          title: title,
          description: description,
          category: category,
          subCategory: _normalized(draft['subCategory']?.toString()),
          dailyRate: dailyRate,
          condition: condition,
          location: location,
          tags: tags,
        ),
      );

      if (photosToUpload.isNotEmpty) {
        await _itemApiService.uploadItemPhotos(createdItem.id, photosToUpload);
      }

      isSubmitting = false;
      update();
      Get.snackbar('Success', 'Item created successfully.');
      return true;
    } catch (e) {
      isSubmitting = false;
      update();
      print(e);
      Get.snackbar('Create Item Failed', _readMessage(e));
      return false;
    }
  }

  Future<ItemLocationModel> _resolveLocationFromDraftOrProfile(
    Map<String, dynamic> draft,
  ) async {
    String? draftCity;
    String? draftProvince;
    String? draftCountry;
    CoordinatesModel? draftCoordinates;

    final draftLocation = draft['location'];
    if (draftLocation is Map) {
      draftCity = _normalized(draftLocation['city']?.toString());
      draftProvince = _normalized(draftLocation['province']?.toString());
      draftCountry =
          _normalized(draftLocation['country']?.toString()) ?? 'Canada';

      final coordinatesRaw = draftLocation['coordinates'];
      if (coordinatesRaw is Map) {
        draftCoordinates = CoordinatesModel(
          lat: _asPositiveDoubleOrZero(coordinatesRaw['lat']),
          lng: _asPositiveDoubleOrZero(coordinatesRaw['lng']),
        );
      }
    }

    final profileResult = await _profileService.getProfile();
    final profileLocation = profileResult.profile?.location;

    final city = draftCity ?? _normalized(profileLocation?.city);
    final province = draftProvince ?? _normalized(profileLocation?.province);
    final country =
        draftCountry ?? _normalized(profileLocation?.country) ?? 'Canada';

    return ItemLocationModel(
      city: city,
      province: province,
      country: country,
      coordinates:
          draftCoordinates ??
          (profileLocation?.coordinates == null
              ? null
              : CoordinatesModel(
                  lat: profileLocation!.coordinates!.lat,
                  lng: profileLocation.coordinates!.lng,
                )),
    );
  }

  Future<String?> _validateImageFile(File file) async {
    final fileSize = await file.length();
    const maxBytes = 5 * 1024 * 1024;
    if (fileSize > maxBytes) {
      return 'Each image must be 5MB or smaller.';
    }

    final lower = file.path.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return null;
    }

    return 'Only JPEG, PNG, and WebP images are allowed.';
  }

  String? _mapCategory(String value) {
    final normalized = value.trim().toLowerCase();
    final map = <String, String>{
      'tools': 'tools',
      'electronics': 'electronics',
      'cameras': 'cameras',
      'audio': 'audio',
      'sports': 'sports',
      'outdoor': 'outdoor',
      'power tools': 'power_tools',
      'power_tools': 'power_tools',
      'cycling': 'cycling',
      'kitchen': 'kitchen',
      'furniture': 'furniture',
      'garden': 'garden',
      'cleaning': 'cleaning',
      'baby': 'baby',
      'party': 'party',
      'vehicles': 'vehicles',
      'camping': 'camping',
      'winter sports': 'winter_sports',
      'winter_sports': 'winter_sports',
      'water sports': 'water_sports',
      'water_sports': 'water_sports',
      'music': 'music',
      'other': 'other',
    };

    final mapped = map[normalized] ?? normalized;
    if (allowedCategories.contains(mapped)) {
      return mapped;
    }
    return null;
  }

  String? _mapCondition(String value) {
    final normalized = value.trim().toLowerCase();
    const map = <String, String>{
      'new': 'new',
      'like new': 'like_new',
      'like_new': 'like_new',
      'used, good condition': 'good',
      'good': 'good',
      'used, fair condition': 'fair',
      'fair': 'fair',
    };

    final mapped = map[normalized] ?? normalized;
    if (allowedConditions.contains(mapped)) {
      return mapped;
    }
    return null;
  }

  List<String> _parseTags(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }

    final asString = raw?.toString() ?? '';
    if (asString.trim().isEmpty) {
      return const <String>[];
    }

    return asString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  double? _asPositiveDouble(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toDouble();
    }

    final normalized = raw.toString().replaceAll(RegExp(r'[^0-9.]'), '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  double? _asPositiveDoubleOrZero(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toDouble();
    }
    return double.tryParse(raw.toString());
  }

  String? _normalized(String? value) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _readMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  List<File>? _extractDraftPhotos(Map<String, dynamic> draft) {
    final raw = draft['photos'];
    if (raw is! List) {
      return null;
    }
    final files = raw
        .map((entry) {
          if (entry is File) {
            return entry;
          }
          final path = entry.toString().trim();
          if (path.isEmpty) {
            return null;
          }
          return File(path);
        })
        .whereType<File>()
        .toList(growable: false);
    return files;
  }

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    tagsController.dispose();
    cityController.dispose();
    provinceController.dispose();
    countryController.dispose();
    latController.dispose();
    lngController.dispose();
    super.onClose();
  }
}
