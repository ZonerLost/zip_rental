import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/models/chat/chat_models.dart' show extractUserIdFromJwt;
import 'package:zip_peer/models/disputes/dispute_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/disputes/dispute_service.dart';

class DisputeController extends GetxController {
  DisputeController({DisputeService? disputeService, AuthService? authService})
    : _disputeService = disputeService ?? DisputeService(),
      _authService = authService ?? AuthService() {
    _resolveCurrentUserId();
  }

  final DisputeService _disputeService;
  final AuthService _authService;
  static const int _pageSize = 10;

  /// Needed to tell "you reported X" from "X reported you" in the list,
  /// and to only show the Cancel action to the reporter (the server
  /// enforces this too — confirmed live: "Only the reporter can cancel a
  /// dispute" — but hiding it client-side avoids a confusing failed tap).
  String? currentUserId;

  bool isOpeningDispute = false;
  bool isMyDisputesLoading = false;
  bool isDisputeDetailLoading = false;
  bool isUploadingEvidence = false;
  bool isCancellingDispute = false;

  String? myDisputesErrorMessage;
  String? disputeDetailErrorMessage;

  final List<DisputeModel> myDisputes = <DisputeModel>[];
  int myDisputesPage = 1;
  bool myDisputesHasNext = false;
  String? myDisputesStatusFilter;

  DisputeModel? disputeDetail;

  Future<void> _resolveCurrentUserId() async {
    final token = await _authService.ensureAccessToken();
    if (token != null) {
      currentUserId = extractUserIdFromJwt(token);
      update();
    }
  }

  bool isReporter(DisputeModel dispute) =>
      currentUserId != null && dispute.reportedBy?.id == currentUserId;

  Future<void> setStatusFilter(String? status) async {
    myDisputesStatusFilter = status;
    await fetchMyDisputes(refresh: true);
  }

  Future<void> fetchMyDisputes({bool refresh = false}) async {
    if (refresh) {
      myDisputesPage = 1;
      myDisputesHasNext = false;
      myDisputes.clear();
    } else if (isMyDisputesLoading ||
        (myDisputes.isNotEmpty && !myDisputesHasNext)) {
      return;
    }

    isMyDisputesLoading = true;
    myDisputesErrorMessage = null;
    update();

    final result = await _disputeService.getMyDisputes(
      status: myDisputesStatusFilter,
      page: myDisputesPage,
      limit: _pageSize,
    );

    isMyDisputesLoading = false;
    if (!result.success) {
      myDisputesErrorMessage = result.message;
      update();
      return;
    }

    if (refresh) {
      myDisputes
        ..clear()
        ..addAll(result.disputes);
    } else {
      myDisputes.addAll(result.disputes);
    }

    final pagination = result.pagination;
    myDisputesHasNext =
        pagination?.hasNext ?? (result.disputes.length >= _pageSize);
    myDisputesPage = (pagination?.page ?? myDisputesPage) + 1;
    update();
  }

  Future<bool> openDispute({
    required String bookingId,
    required String reason,
    required String description,
    List<File> evidence = const <File>[],
  }) async {
    isOpeningDispute = true;
    update();

    try {
      var dispute = await _disputeService.openDispute(
        CreateDisputeRequestModel(
          bookingId: bookingId,
          reason: reason,
          description: description,
        ),
      );

      if (evidence.isNotEmpty) {
        try {
          dispute = await _disputeService.uploadEvidence(dispute.id, evidence);
        } catch (_) {
          // The dispute itself was filed successfully even if the evidence
          // upload failed — don't fail the whole action for that; the user
          // can add evidence later from My Disputes.
        }
      }

      myDisputes.insert(0, dispute);
      Get.snackbar('Dispute Submitted', 'Your dispute has been filed.');
      return true;
    } catch (e) {
      Get.snackbar('Dispute Failed', _readMessage(e));
      return false;
    } finally {
      isOpeningDispute = false;
      update();
    }
  }

  Future<void> fetchDisputeDetail(String disputeId) async {
    isDisputeDetailLoading = true;
    disputeDetailErrorMessage = null;
    update();

    try {
      disputeDetail = await _disputeService.getDisputeDetail(disputeId);
    } catch (e) {
      disputeDetailErrorMessage = _readMessage(e);
    }

    isDisputeDetailLoading = false;
    update();
  }

  Future<bool> uploadEvidence(String disputeId, List<File> files) async {
    if (files.isEmpty) {
      return false;
    }
    isUploadingEvidence = true;
    update();

    try {
      final updated = await _disputeService.uploadEvidence(disputeId, files);
      _replaceDispute(updated);
      Get.snackbar('Evidence Uploaded', 'Your evidence was added to the dispute.');
      return true;
    } catch (e) {
      Get.snackbar('Upload Failed', _readMessage(e));
      return false;
    } finally {
      isUploadingEvidence = false;
      update();
    }
  }

  Future<bool> cancelDispute(String disputeId) async {
    isCancellingDispute = true;
    update();

    try {
      final updated = await _disputeService.cancelDispute(disputeId);
      _replaceDispute(updated);
      Get.snackbar('Dispute Cancelled', 'Your dispute has been cancelled.');
      return true;
    } catch (e) {
      Get.snackbar('Cancel Failed', _readMessage(e));
      return false;
    } finally {
      isCancellingDispute = false;
      update();
    }
  }

  void _replaceDispute(DisputeModel updated) {
    if (disputeDetail?.id == updated.id) {
      disputeDetail = updated;
    }
    final index = myDisputes.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      myDisputes[index] = updated;
    }
  }

  String _readMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
