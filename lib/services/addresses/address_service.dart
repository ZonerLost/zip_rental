import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class AddressService extends ApiServiceBase {
  AddressService({AuthService? authService}) : super(authService: authService);

  Future<AddressResult> getAddresses() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/users/addresses',
      requiresAuth: true,
    );
    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return AddressResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? getByPath(map, 'addresses');
    final addresses = _parseAddresses(raw);
    return AddressResult(success: true, message: message, addresses: addresses);
  }

  Future<AddressResult> addAddress(AddAddressRequest request) async {
    final response = await this.request(
      method: ApiHttpMethod.post,
      path: '/users/addresses',
      requiresAuth: true,
      body: request.toJson(),
    );
    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) return AddressResult(success: false, message: message);

    final map = asMap(response.body);
    final raw = getByPath(map, 'data') ?? getByPath(map, 'address');
    final address = raw is Map ? AddressModel.fromJson(stringKeyMap(raw)) : null;
    return AddressResult(success: true, message: message, address: address);
  }

  Future<AddressResult> setDefaultAddress(String id) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/users/addresses/${Uri.encodeComponent(id)}/default',
      requiresAuth: true,
    );
    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    return AddressResult(success: success, message: message);
  }

  Future<AddressResult> deleteAddress(String id) async {
    final response = await request(
      method: ApiHttpMethod.delete,
      path: '/users/addresses/${Uri.encodeComponent(id)}',
      requiresAuth: true,
    );
    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    return AddressResult(success: success, message: message);
  }

  List<AddressModel> _parseAddresses(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => AddressModel.fromJson(stringKeyMap(e)))
        .where((a) => a.id.isNotEmpty)
        .toList(growable: false);
  }
}
