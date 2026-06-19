import 'package:get/get.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/addresses/address_service.dart';

class AddressController extends GetxController {
  AddressController({AddressService? addressService})
      : _service = addressService ?? AddressService();

  final AddressService _service;

  List<AddressModel> addresses = const [];
  bool isLoading = false;
  bool isSaving = false;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    isLoading = true;
    update();
    try {
      final result = await _service.getAddresses();
      if (result.success) {
        addresses = result.addresses;
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to load addresses.');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> addAddress(AddAddressRequest request) async {
    isSaving = true;
    update();
    try {
      final result = await _service.addAddress(request);
      if (result.success) {
        await loadAddresses();
        return true;
      }
      Get.snackbar('Error', result.message);
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Failed to add address.');
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<void> setDefault(String id) async {
    try {
      final result = await _service.setDefaultAddress(id);
      if (result.success) {
        await loadAddresses();
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to set default address.');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final result = await _service.deleteAddress(id);
      if (result.success) {
        addresses = addresses.where((a) => a.id != id).toList();
        update();
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to delete address.');
    }
  }
}
