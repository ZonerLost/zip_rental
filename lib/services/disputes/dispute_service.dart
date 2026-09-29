import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/models/disputes/dispute_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

/// Renter/owner-facing dispute endpoints only. The collection's four
/// admin-only routes (list all, admin detail, resolve, set status) are
/// deliberately not wired up here — this app has no admin UI, matching the
/// same scope decision made for the reviews admin endpoint.
class DisputeService extends ApiServiceBase {
  DisputeService({AuthService? authService}) : super(authService: authService);

  Future<DisputeModel> openDispute(CreateDisputeRequestModel requestModel) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/disputes',
      requiresAuth: true,
      body: requestModel.toJson(),
    );

    return _parseSingleOrThrow(response);
  }

  Future<PaginatedDisputesResponse> getMyDisputes({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/disputes/my',
      requiresAuth: true,
      query: <String, dynamic>{
        if ((status ?? '').isNotEmpty) 'status': status,
        'page': page.toString(),
        'limit': limit.clamp(1, 50).toString(),
      },
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    final root = asMap(response.body);

    if (!success) {
      return PaginatedDisputesResponse(success: false, message: message);
    }

    final data = getByPath(root, 'data');
    final disputes = data is List
        ? data
              .whereType<Map>()
              .map((entry) => DisputeModel.fromJson(stringKeyMap(entry)))
              .where((dispute) => dispute.id.trim().isNotEmpty)
              .toList(growable: false)
        : const <DisputeModel>[];

    final paginationRaw = getByPath(root, 'pagination');
    final pagination = paginationRaw is Map
        ? DisputePaginationModel.fromJson(stringKeyMap(paginationRaw))
        : null;

    return PaginatedDisputesResponse(
      success: true,
      message: message,
      disputes: disputes,
      pagination: pagination,
    );
  }

  Future<DisputeModel> getDisputeDetail(String disputeId) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/disputes/${Uri.encodeComponent(disputeId)}',
      requiresAuth: true,
    );

    return _parseSingleOrThrow(response, notFoundMessage: 'Dispute not found');
  }

  /// `evidence`, up to 5 files (JPEG/PNG/WebP, 5 MB each) — the picker in
  /// the UI enforces the cap; the server enforces it independently too.
  Future<DisputeModel> uploadEvidence(String disputeId, List<File> files) async {
    final multipartFiles = files.map(multipartFileFromPath).toList(growable: false);

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/disputes/${Uri.encodeComponent(disputeId)}/evidence',
      requiresAuth: true,
      body: FormData(<String, dynamic>{'evidence': multipartFiles}),
    );

    return _parseSingleOrThrow(response, notFoundMessage: 'Dispute not found');
  }

  /// Only `open` disputes can be cancelled, and only by the reporter —
  /// both confirmed live via a 4xx from this route.
  Future<DisputeModel> cancelDispute(String disputeId) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/disputes/${Uri.encodeComponent(disputeId)}/cancel',
      requiresAuth: true,
    );

    return _parseSingleOrThrow(response, notFoundMessage: 'Dispute not found');
  }

  DisputeModel _parseSingleOrThrow(
    Response<dynamic> response, {
    String? notFoundMessage,
  }) {
    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: notFoundMessage,
    );
    if (!success) {
      throw Exception(message);
    }

    final dispute = DisputeModel.fromJson(_dataMap(response));
    if (dispute.id.trim().isEmpty) {
      throw Exception(message);
    }
    return dispute;
  }

  Map<String, dynamic> _dataMap(Response<dynamic> response) {
    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    if (data is Map) {
      return stringKeyMap(data);
    }
    return <String, dynamic>{};
  }
}
