import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/disputes/dispute_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/disputes/dispute_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

/// `GET /disputes/my` — every dispute the signed-in user is part of, either
/// as the reporter or the one reported against. The other three
/// renter/owner-facing endpoints (open, evidence upload, cancel) are
/// exercised from here too; the four admin-only routes are out of scope —
/// this app has no admin UI, same call made for the reviews admin endpoint.
class MyDisputesScreen extends StatefulWidget {
  const MyDisputesScreen({super.key});

  @override
  State<MyDisputesScreen> createState() => _MyDisputesScreenState();
}

class _MyDisputesScreenState extends State<MyDisputesScreen> {
  late final DisputeController _disputeController;

  static const List<_StatusTab> _tabs = [
    _StatusTab(label: 'All', value: null),
    _StatusTab(label: 'Open', value: DisputeStatuses.open),
    _StatusTab(label: 'Closed', value: DisputeStatuses.closed),
  ];

  @override
  void initState() {
    super.initState();
    _disputeController = Get.isRegistered<DisputeController>()
        ? Get.find<DisputeController>()
        : Get.put(DisputeController());
    _disputeController.fetchMyDisputes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisputeController>(
      init: _disputeController,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  Row(
                    children: [
                      Bounce(
                        onTap: () => Get.back(),
                        child: CommonImageView(
                          imagePath: Assets.imagesBack,
                          height: 50,
                        ),
                      ),
                      const Gap(10),
                      const MyText(
                        text: 'My Disputes',
                        size: 16,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(20),
                  Row(
                    children: _tabs
                        .map((tab) => _buildStatusTab(controller, tab))
                        .toList(growable: false),
                  ),
                  const Gap(16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _disputeController.fetchMyDisputes(refresh: true),
                      child: _buildBody(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTab(DisputeController controller, _StatusTab tab) {
    final isSelected = controller.myDisputesStatusFilter == tab.value;
    return Expanded(
      child: Bounce(
        onTap: () {
          if (isSelected) return;
          controller.setStatusFilter(tab.value);
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor.withOpacity(0.1) : kWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: MyText(
              text: tab.label,
              size: 13,
              color: isSelected ? kPrimaryColor : kSubText,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(DisputeController controller) {
    if (controller.isMyDisputesLoading && controller.myDisputes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((controller.myDisputesErrorMessage ?? '').isNotEmpty &&
        controller.myDisputes.isEmpty) {
      return ListView(
        children: [
          const Gap(60),
          MyText(
            text: controller.myDisputesErrorMessage!,
            size: 14,
            color: kredColor,
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Center(
            child: Bounce(
              onTap: () => controller.fetchMyDisputes(refresh: true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const MyText(
                  text: 'Retry',
                  size: 13,
                  color: kPrimaryColor,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (controller.myDisputes.isEmpty) {
      return ListView(
        children: const [
          Gap(80),
          Center(
            child: MyText(
              text: "You don't have any disputes.",
              size: 14,
              color: kSubText,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: controller.myDisputes.length + 1,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        if (index == controller.myDisputes.length) {
          if (!controller.myDisputesHasNext) return const SizedBox.shrink();
          if (!controller.isMyDisputesLoading) controller.fetchMyDisputes();
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final dispute = controller.myDisputes[index];
        return _DisputeCard(
          dispute: dispute,
          isReporter: controller.isReporter(dispute),
          onTap: () => _showDisputeDetailSheet(dispute),
        );
      },
    );
  }

  Future<void> _showDisputeDetailSheet(DisputeModel initial) async {
    _disputeController.fetchDisputeDetail(initial.id);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GetBuilder<DisputeController>(
          init: _disputeController,
          builder: (controller) {
            final loaded = controller.disputeDetail;
            final dispute = loaded != null && loaded.id == initial.id ? loaded : initial;
            return _DisputeDetailSheet(
              dispute: dispute,
              isReporter: controller.isReporter(dispute),
              isCancelling: controller.isCancellingDispute,
              isUploadingEvidence: controller.isUploadingEvidence,
              onCancel: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cancel Dispute'),
                    content: const Text('Are you sure you want to cancel this dispute?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes, Cancel'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await controller.cancelDispute(dispute.id);
                }
              },
              onAddEvidence: () async {
                final picker = ImagePicker();
                final picked = await picker.pickMultiImage();
                if (picked.isEmpty) return;
                final files = picked
                    .take(5)
                    .map((f) => File(f.path))
                    .toList(growable: false);
                await controller.uploadEvidence(dispute.id, files);
              },
            );
          },
        );
      },
    );
  }
}

class _StatusTab {
  const _StatusTab({required this.label, required this.value});

  final String label;
  final String? value;
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({
    required this.dispute,
    required this.isReporter,
    required this.onTap,
  });

  final DisputeModel dispute;
  final bool isReporter;
  final VoidCallback onTap;

  String get _partyLabel {
    final otherName = isReporter
        ? (dispute.reportedAgainst?.fullName ?? 'the other party')
        : (dispute.reportedBy?.fullName ?? 'the other party');
    return isReporter ? 'You reported $otherName' : '$otherName reported you';
  }

  String get _timeAgo {
    final createdAt = dispute.createdAt;
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: MyText(
                    text: DisputeReasons.labelFor(dispute.reason),
                    size: 15,
                    weight: FontWeight.w600,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(8),
                _StatusBadge(status: dispute.status),
              ],
            ),
            const Gap(4),
            MyText(text: _partyLabel, size: 12, color: kSubText2),
            const Gap(6),
            MyText(text: _timeAgo, size: 12, color: kSubText),
            if ((dispute.description ?? '').isNotEmpty) ...[
              const Gap(8),
              Divider(color: kDividerColor),
              const Gap(8),
              MyText(
                text: dispute.description!,
                size: 14,
                color: kSubText,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
              ),
            ],
            if (dispute.evidence.isNotEmpty) ...[
              const Gap(10),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dispute.evidence.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CommonImageView(
                      url: dispute.evidence[index],
                      height: 56,
                      width: 56,
                      fit: BoxFit.cover,
                    ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final normalized = (status ?? '').toLowerCase();
    Color bg;
    Color fg;
    String label;
    switch (normalized) {
      case DisputeStatuses.open:
        bg = kYellowColor.withOpacity(0.2);
        fg = const Color(0xFFB8860B);
        label = 'Open';
        break;
      case DisputeStatuses.closed:
        bg = kSubText.withOpacity(0.15);
        fg = kSubText;
        label = 'Closed';
        break;
      default:
        bg = kPrimaryColor.withOpacity(0.15);
        fg = kPrimaryColor;
        label = normalized.isEmpty
            ? 'Unknown'
            : normalized
                  .split('_')
                  .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
                  .join(' ');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: MyText(text: label, size: 11, color: fg, weight: FontWeight.w600),
    );
  }
}

class _DisputeDetailSheet extends StatelessWidget {
  const _DisputeDetailSheet({
    required this.dispute,
    required this.isReporter,
    required this.isCancelling,
    required this.isUploadingEvidence,
    required this.onCancel,
    required this.onAddEvidence,
  });

  final DisputeModel dispute;
  final bool isReporter;
  final bool isCancelling;
  final bool isUploadingEvidence;
  final VoidCallback onCancel;
  final VoidCallback onAddEvidence;

  String _dateRange() {
    final start = dispute.booking?.startDate;
    final end = dispute.booking?.endDate;
    if (start == null || end == null) return '-';
    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: DisputeReasons.labelFor(dispute.reason),
                size: 20,
                weight: FontWeight.w700,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Gap(8),
          _StatusBadge(status: dispute.status),
          const Gap(16),
          _detailTile('Booking Dates', _dateRange()),
          _detailTile(
            'Reported By',
            isReporter ? 'You' : (dispute.reportedBy?.fullName ?? '-'),
          ),
          _detailTile(
            'Reported Against',
            isReporter
                ? (dispute.reportedAgainst?.fullName ?? '-')
                : 'You',
          ),
          _detailTile('Description', dispute.description ?? '-'),
          if (dispute.evidence.isNotEmpty) ...[
            const Gap(4),
            MyText(text: 'Evidence', size: 12, color: kSubText),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dispute.evidence
                  .map(
                    (evidenceUrl) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CommonImageView(
                        url: evidenceUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (isReporter && dispute.isOpen) ...[
            const Gap(20),
            MyButton(
              onTap: isUploadingEvidence ? () {} : onAddEvidence,
              buttonText: isUploadingEvidence ? 'Uploading...' : 'Add Evidence',
              backgroundColor: kPrimaryColor.withOpacity(0.15),
              fontColor: kPrimaryColor,
              radius: 20,
            ),
            const Gap(12),
            MyButton(
              onTap: isCancelling ? () {} : onCancel,
              buttonText: isCancelling ? 'Cancelling...' : 'Cancel Dispute',
              backgroundColor: kredColor.withOpacity(0.15),
              fontColor: kredColor,
              radius: 20,
            ),
          ],
          const Gap(16),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(text: label, size: 12, color: kSubText),
          const Gap(2),
          MyText(text: value, size: 14, weight: FontWeight.w600, color: kBlack),
        ],
      ),
    );
  }
}
