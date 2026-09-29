import 'package:get/get.dart';
import 'package:zip_peer/models/payments/payment_models.dart';
import 'package:zip_peer/services/payments/payment_service.dart';

class PaymentMethodController extends GetxController {
  PaymentMethodController({PaymentService? paymentService})
      : _service = paymentService ?? PaymentService();

  final PaymentService _service;

  List<PaymentMethodModel> methods = const [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadMethods();
  }

  /// The method checkout should preselect — the one marked `isDefault`, or
  /// simply the first saved one if none is (the API always returns at least
  /// the order it was saved in, and only ever has one method to begin with
  /// for most users).
  PaymentMethodModel? get defaultMethod {
    for (final m in methods) {
      if (m.isDefault) return m;
    }
    return methods.isNotEmpty ? methods.first : null;
  }

  Future<void> loadMethods() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _service.getPaymentMethods();

    isLoading = false;
    if (result.success) {
      methods = result.methods;
    } else {
      errorMessage = result.message;
    }
    update();
  }

  Future<PaymentMethodModel?> addMethod(SavePaymentMethodRequest request) async {
    isSaving = true;
    update();

    final result = await _service.savePaymentMethod(request);

    isSaving = false;
    if (!result.success) {
      Get.snackbar('Couldn\'t save card', result.message);
      update();
      return null;
    }

    await loadMethods();
    return result.method;
  }

  Future<void> deleteMethod(String id) async {
    final result = await _service.deletePaymentMethod(id);
    if (result.success) {
      // Server response is authoritative — it already reflects any default
      // re-promotion that happened as a side effect of this delete.
      methods = result.methods;
      update();
    } else {
      Get.snackbar('Error', result.message);
    }
  }

  Future<void> setDefault(String id) async {
    final result = await _service.setDefaultPaymentMethod(id);
    if (result.success) {
      await loadMethods();
    } else {
      Get.snackbar('Error', result.message);
    }
  }
}
