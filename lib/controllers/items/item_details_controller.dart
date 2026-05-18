import 'package:get/get.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/services/items/item_api_service.dart';

class ItemDetailsController extends GetxController {
  ItemDetailsController({required this.itemId, ItemApiService? itemApiService})
    : _itemApiService = itemApiService ?? ItemApiService();

  final String itemId;
  final ItemApiService _itemApiService;

  bool isLoading = false;
  String? errorMessage;
  ItemModel? item;

  @override
  void onInit() {
    super.onInit();
    fetchItem();
  }

  Future<void> fetchItem() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final result = await _itemApiService.getItemById(itemId);
      item = result;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading = false;
    update();
  }
}
