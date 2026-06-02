import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/items/item_api_service.dart';

class MyListingsController extends GetxController {
  MyListingsController({ItemApiService? itemApiService})
    : _itemApiService = itemApiService ?? ItemApiService();

  final ItemApiService _itemApiService;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  final List<ItemModel> listings = <ItemModel>[];

  @override
  void onInit() {
    super.onInit();
    fetchMyListings();
  }

  Future<void> fetchMyListings() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final result = await _itemApiService.getMyListings();
      listings
        ..clear()
        ..addAll(result);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading = false;
    update();
  }

  Future<bool> deleteListing(String itemId) async {
    isSubmitting = true;
    update();

    try {
      await _itemApiService.deleteItem(itemId);
      listings.removeWhere((item) => item.id == itemId);
      isSubmitting = false;
      update();
      return true;
    } catch (e) {
      isSubmitting = false;
      update();
      Get.snackbar('Delete Failed', _readMessage(e));
      return false;
    }
  }

  Future<void> togglePause(String itemId) async {
    final index = listings.indexWhere((item) => item.id == itemId);
    if (index < 0) return;

    final original = listings[index];
    final currentlyPaused = original.isPaused ?? false;
    // Optimistic update
    listings[index] = original.copyWith(isPaused: !currentlyPaused);
    update();

    try {
      final result = currentlyPaused
          ? await _itemApiService.resumeListing(itemId)
          : await _itemApiService.pauseListing(itemId);
      listings[index] = original.copyWith(isPaused: result.isPaused);
      update();
    } catch (e) {
      listings[index] = original;
      update();
      Get.snackbar(
        currentlyPaused ? 'Resume Failed' : 'Pause Failed',
        _readMessage(e),
      );
    }
  }

  Future<void> updateBlockedDates(
    String itemId,
    List<String> blockedDates,
  ) async {
    final index = listings.indexWhere((item) => item.id == itemId);
    if (index < 0) {
      return;
    }

    final original = listings[index];
    listings[index] = original.copyWith(
      availability: ItemAvailabilityModel(
        isAvailable: original.availability?.isAvailable,
        blockedDates: blockedDates,
      ),
    );
    update();

    try {
      final updated = await _itemApiService.updateAvailability(
        itemId,
        blockedDates: blockedDates,
      );
      listings[index] = updated;
      update();
    } catch (e) {
      listings[index] = original;
      update();
      Get.snackbar('Availability Update Failed', _readMessage(e));
    }
  }

  Future<ItemModel?> updateListing(
    String itemId,
    UpdateItemRequest request,
  ) async {
    isSubmitting = true;
    update();

    try {
      final updated = await _itemApiService.updateItem(itemId, request);
      final index = listings.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        listings[index] = updated;
      }
      isSubmitting = false;
      update();
      return updated;
    } catch (e) {
      isSubmitting = false;
      update();
      Get.snackbar('Update Failed', _readMessage(e));
      return null;
    }
  }

  Future<ItemModel?> getListingDetails(String itemId) async {
    try {
      return await _itemApiService.getItemById(itemId);
    } catch (e) {
      Get.snackbar('Unable to Load Details', _readMessage(e));
      return null;
    }
  }

  Future<List<String>> uploadPhotos(
    String itemId,
    List<String> filePaths,
  ) async {
    if (filePaths.length > 5) {
      Get.snackbar('Invalid Selection', 'You can upload maximum 5 images.');
      return const <String>[];
    }

    for (final path in filePaths) {
      final file = File(path);
      final lower = path.toLowerCase();
      final isValidType =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
      if (!isValidType) {
        Get.snackbar('Invalid Image', 'Only JPEG, PNG, or WebP are allowed.');
        return const <String>[];
      }

      final length = await file.length();
      const maxBytes = 5 * 1024 * 1024;
      if (length > maxBytes) {
        Get.snackbar('Invalid Image', 'Each image must be 5MB or smaller.');
        return const <String>[];
      }
    }

    isSubmitting = true;
    update();

    try {
      final files = filePaths.map((path) => File(path)).toList(growable: false);
      final urls = await _itemApiService.uploadItemPhotos(itemId, files);
      await fetchMyListings();
      isSubmitting = false;
      update();
      return urls;
    } catch (e) {
      isSubmitting = false;
      update();
      Get.snackbar('Upload Failed', _readMessage(e));
      return const <String>[];
    }
  }

  Future<bool> deletePhoto(String itemId, String photoUrl) async {
    isSubmitting = true;
    update();

    try {
      await _itemApiService.deleteItemPhoto(itemId, photoUrl);
      await fetchMyListings();
      isSubmitting = false;
      update();
      return true;
    } catch (e) {
      isSubmitting = false;
      update();
      Get.snackbar('Delete Photo Failed', _readMessage(e));
      return false;
    }
  }

  String _readMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
