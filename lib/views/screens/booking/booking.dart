import 'dart:io';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/bookings/booking_controller.dart';
import 'package:zip_peer/controllers/reviews/review_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late final BookingController _controller;
  late final ReviewController _reviewController;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedMainTab = 0;
  int _selectedSubTab = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
    _reviewController = Get.isRegistered<ReviewController>()
        ? Get.find<ReviewController>()
        : Get.put(ReviewController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCurrentTab(refresh: true);
      await _reviewController.fetchPendingReviews();
    });
  }

  Future<void> _loadCurrentTab({bool refresh = false}) async {
    final status = _statusForTab(_selectedSubTab);
    if (_selectedMainTab == 0) {
      _controller.receivedStatusFilter = status;
      await _controller.fetchReceivedBookings(refresh: refresh);
      return;
    }

    _controller.sentStatusFilter = status;
    await _controller.fetchSentBookings(refresh: refresh);
  }

  List<String> _pendingReviewTypesFor(String bookingId) {
    for (final pending in _reviewController.pendingReviews) {
      if (pending.bookingId == bookingId) {
        return pending.pendingTypes;
      }
    }
    return const <String>[];
  }

  String _statusForTab(int index) {
    switch (index) {
      case 0:
        return BookingStatuses.accepted;
      case 1:
        return BookingStatuses.pending;
      case 2:
        return BookingStatuses.active;
      case 3:
      default:
        return BookingStatuses.completed;
    }
  }

  List<BookingModel> _activeBookings(BookingController controller) {
    return _selectedMainTab == 0
        ? controller.receivedBookings
        : controller.sentBookings;
  }

  bool _isLoading(BookingController controller) {
    return _selectedMainTab == 0
        ? controller.isReceivedBookingsLoading
        : controller.isSentBookingsLoading;
  }

  String? _errorMessage(BookingController controller) {
    return _selectedMainTab == 0
        ? controller.receivedErrorMessage
        : controller.sentErrorMessage;
  }

  bool _hasNext(BookingController controller) {
    return _selectedMainTab == 0
        ? controller.receivedHasNext
        : controller.sentHasNext;
  }

  List<Widget> _buildEventMarkers(List<BookingModel> bookings, DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    final matches = bookings.where((booking) {
      final start = booking.startDate;
      if (start == null) {
        return false;
      }
      return DateTime(start.year, start.month, start.day) == dayKey;
    }).toList(growable: false);

    if (matches.isEmpty) {
      return const <Widget>[];
    }

    return matches.take(2).map((booking) {
      final isPending = booking.status == BookingStatuses.pending;
      return Container(
        width: 30,
        height: 3,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isPending ? const Color(0xFFFFD37E) : const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }).toList(growable: false);
  }

  Widget _buildMainTab(String title, int index, Color indicatorColor) {
    final isSelected = _selectedMainTab == index;
    return Expanded(
      child: Bounce(
        onTap: () async {
          if (_selectedMainTab == index) {
            return;
          }
          setState(() {
            _selectedMainTab = index;
          });
          await _loadCurrentTab(refresh: true);
        },
        child: Column(
          children: [
            MyText(
              text: title,
              size: 16,
              color: isSelected ? kBlack : kSubText,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            const Gap(8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? indicatorColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab(String title, int index) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: Bounce(
        onTap: () async {
          if (_selectedSubTab == index) {
            return;
          }
          setState(() {
            _selectedSubTab = index;
          });
          await _loadCurrentTab(refresh: true);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? kPrimaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: MyText(
              textAlign: TextAlign.center,
              text: title,
              size: 11,
              color: isSelected ? kPrimaryColor : kSubText,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BookingModel booking) {
    final isOwnerView = _selectedMainTab == 0;
    final status = (booking.status ?? '').toLowerCase();

    if (isOwnerView && status == BookingStatuses.pending) {
      return Row(
        children: [
          Expanded(
            child: MyButton(
              onTap: () => _showReasonDialog(
                title: 'Decline Booking',
                confirmText: 'Decline',
                onConfirm: (reason) => _controller.declineBooking(
                  booking.id,
                  reason,
                ),
              ),
              buttonText: 'Decline',
              backgroundColor: kredColor.withOpacity(0.2),
              fontColor: kredColor,
              radius: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: MyButton(
              onTap: () => _controller.acceptBooking(booking.id),
              buttonText: 'Accept',
              backgroundColor: kgreenColor.withOpacity(0.2),
              fontColor: kgreenColor,
              radius: 20,
            ),
          ),
        ],
      );
    }

    if (!isOwnerView &&
        (status == BookingStatuses.pending ||
            status == BookingStatuses.accepted)) {
      return MyButton(
        onTap: () => _showReasonDialog(
          title: 'Cancel Booking',
          confirmText: 'Cancel Booking',
          onConfirm: (reason) => _controller.cancelBooking(booking.id, reason),
        ),
        buttonText: 'Cancel Booking',
        backgroundColor: kredColor.withOpacity(0.2),
        fontColor: kredColor,
        radius: 20,
      );
    }

    if (isOwnerView && status == BookingStatuses.accepted) {
      return Row(
        children: [
          Expanded(
            child: MyButton(
              onTap: () => _pickAndUploadPhotos(
                booking.id,
                isPreRental: true,
              ),
              buttonText: 'Upload Pre Photos',
              backgroundColor: kPrimaryColor.withOpacity(0.18),
              fontColor: kPrimaryColor,
              radius: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: MyButton(
              onTap: () => _openBookingDetails(booking),
              buttonText: 'View Details',
              backgroundColor: kSubText.withOpacity(0.15),
              fontColor: kSubText,
              radius: 20,
            ),
          ),
        ],
      );
    }

    if (isOwnerView && status == BookingStatuses.active) {
      return Row(
        children: [
          Expanded(
            child: MyButton(
              onTap: () => _showCompleteConfirm(booking.id),
              buttonText: 'Mark Complete',
              backgroundColor: kgreenColor.withOpacity(0.18),
              fontColor: kgreenColor,
              radius: 20,
            ),
          ),
          const Gap(12),
          Expanded(
            child: MyButton(
              onTap: () => _openBookingDetails(booking),
              buttonText: 'View Details',
              backgroundColor: kSubText.withOpacity(0.15),
              fontColor: kSubText,
              radius: 20,
            ),
          ),
        ],
      );
    }

    if (isOwnerView && status == BookingStatuses.completed) {
      final pendingTypes = _pendingReviewTypesFor(booking.id);
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MyButton(
                  onTap: () => _pickAndUploadPhotos(
                    booking.id,
                    isPreRental: false,
                  ),
                  buttonText: 'Upload Post Photos',
                  backgroundColor: kPrimaryColor.withOpacity(0.18),
                  fontColor: kPrimaryColor,
                  radius: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: MyButton(
                  onTap: () => _openBookingDetails(booking),
                  buttonText: 'View Details',
                  backgroundColor: kSubText.withOpacity(0.15),
                  fontColor: kSubText,
                  radius: 20,
                ),
              ),
            ],
          ),
          if (pendingTypes.isNotEmpty) ...[
            const Gap(12),
            MyButton(
              onTap: () => _showLeaveReviewSheet(booking, pendingTypes),
              buttonText: 'Leave a Review',
              backgroundColor: kYellowColor.withOpacity(0.2),
              fontColor: const Color(0xFFB8860B),
              radius: 20,
            ),
          ],
        ],
      );
    }

    if (!isOwnerView && status == BookingStatuses.completed) {
      final pendingTypes = _pendingReviewTypesFor(booking.id);
      return Column(
        children: [
          MyButton(
            onTap: () => _openBookingDetails(booking),
            buttonText: 'View Details',
            backgroundColor: kSubText.withOpacity(0.15),
            fontColor: kSubText,
            radius: 20,
          ),
          if (pendingTypes.isNotEmpty) ...[
            const Gap(12),
            MyButton(
              onTap: () => _showLeaveReviewSheet(booking, pendingTypes),
              buttonText: 'Leave a Review',
              backgroundColor: kYellowColor.withOpacity(0.2),
              fontColor: const Color(0xFFB8860B),
              radius: 20,
            ),
          ],
        ],
      );
    }

    return MyButton(
      onTap: () => _openBookingDetails(booking),
      buttonText: 'View Details',
      backgroundColor: kSubText.withOpacity(0.15),
      fontColor: kSubText,
      radius: 20,
    );
  }

  Future<void> _showReasonDialog({
    required String title,
    required String confirmText,
    required Future<bool> Function(String? reason) onConfirm,
  }) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add an optional reason',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onConfirm(reasonController.text.trim());
    }
  }

  Future<void> _showCompleteConfirm(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Booking'),
          content: const Text(
            'Mark this booking as completed? This will record eco impact and unlock the review flow.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _controller.completeBooking(bookingId);
      if (success) {
        await _reviewController.fetchPendingReviews();
      }
    }
  }

  static const Map<String, String> _reviewTypeLabels = {
    'renter_to_owner': 'Rate the owner',
    'renter_to_item': 'Rate the item',
    'owner_to_renter': 'Rate the renter',
  };

  Future<void> _showLeaveReviewSheet(
    BookingModel booking,
    List<String> pendingTypes,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                    text: 'Leave a Review',
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
              MyText(
                text: booking.itemTitle,
                size: 14,
                color: kSubText,
              ),
              const Gap(16),
              for (final type in pendingTypes)
                _ReviewTypeForm(
                  key: ValueKey('${booking.id}_$type'),
                  label: _reviewTypeLabels[type] ?? 'Rate',
                  onSubmit: (rating, comment) async {
                    final success = await _reviewController.submitReview(
                      bookingId: booking.id,
                      type: type,
                      rating: rating,
                      comment: comment,
                    );
                    if (success &&
                        _pendingReviewTypesFor(booking.id).isEmpty &&
                        context.mounted) {
                      Navigator.of(context).pop();
                    }
                    return success;
                  },
                ),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadPhotos(
    String bookingId, {
    required bool isPreRental,
  }) async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isEmpty) {
      return;
    }

    final photos = pickedFiles
        .map((file) => File(file.path))
        .toList(growable: false);

    if (isPreRental) {
      await _controller.uploadPrePhotos(bookingId, photos);
    } else {
      await _controller.uploadPostPhotos(bookingId, photos);
    }
  }

  Future<void> _openBookingDetails(BookingModel booking) async {
    _controller.fetchBookingDetail(booking.id);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GetBuilder<BookingController>(
          init: _controller,
          builder: (controller) {
            final loadedDetail = controller.bookingDetail;
            final detail = loadedDetail != null && loadedDetail.id == booking.id
                ? loadedDetail
                : booking;
            return Container(
              margin: const EdgeInsets.only(top: 100),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: controller.isBookingDetailLoading &&
                      controller.bookingDetail?.id != booking.id
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: detail.itemTitle,
                              size: 22,
                              weight: FontWeight.w700,
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const Gap(12),
                        _detailTile('Status', _prettyStatus(detail.status)),
                        _detailTile(
                          _selectedMainTab == 0 ? 'Renter' : 'Owner',
                          detail.partnerName,
                        ),
                        _detailTile(
                          'Date Range',
                          _dateRange(detail.startDate, detail.endDate),
                        ),
                        _detailTile(
                          'Delivery Type',
                          _capitalize(detail.deliveryType ?? '-'),
                        ),
                        if ((detail.deliveryAddress?.fullAddress ?? '').isNotEmpty)
                          _detailTile(
                            'Delivery Address',
                            detail.deliveryAddress!.fullAddress,
                          ),
                        if ((detail.pickupTimeFrom ?? '').isNotEmpty ||
                            (detail.pickupTimeTo ?? '').isNotEmpty)
                          _detailTile(
                            'Pickup Window',
                            '${detail.pickupTimeFrom ?? '-'} - ${detail.pickupTimeTo ?? '-'}',
                          ),
                        _detailTile(
                          'Total Amount',
                          _currency(detail),
                        ),
                        if ((detail.declineReason ?? '').isNotEmpty)
                          _detailTile('Decline Reason', detail.declineReason!),
                        if ((detail.cancelReason ?? '').isNotEmpty)
                          _detailTile('Cancel Reason', detail.cancelReason!),
                        if (detail.preRentalPhotos.isNotEmpty) ...[
                          const Gap(12),
                          MyText(
                            text: 'Pre-Rental Photos',
                            size: 16,
                            weight: FontWeight.w600,
                          ),
                          const Gap(10),
                          _photoStrip(detail.preRentalPhotos),
                        ],
                        if (detail.postRentalPhotos.isNotEmpty) ...[
                          const Gap(12),
                          MyText(
                            text: 'Post-Rental Photos',
                            size: 16,
                            weight: FontWeight.w600,
                          ),
                          const Gap(10),
                          _photoStrip(detail.postRentalPhotos),
                        ],
                        const Gap(16),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            text: label,
            size: 12,
            color: kSubText,
            weight: FontWeight.w600,
          ),
          const Gap(4),
          MyText(text: value, size: 15, color: kBlack, weight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _photoStrip(List<String> urls) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const Gap(10),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CommonImageView(
              url: urls[index],
              placeHolder: Assets.imagesShoes1,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  String _prettyStatus(String? status) {
    if ((status ?? '').isEmpty) {
      return 'Unknown';
    }
    return status!
        .split('_')
        .map(_capitalize)
        .join(' ');
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  String _currency(BookingModel booking) {
    final amount = booking.pricing?.totalAmount;
    final currency = booking.item?.currency ?? 'CAD';
    if (amount == null) {
      return '$currency -';
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String _dateRange(DateTime? startDate, DateTime? endDate) {
    final formatter = DateFormat('MMM d, yyyy');
    if (startDate == null && endDate == null) {
      return '-';
    }
    if (startDate != null && endDate != null) {
      return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
    }
    return formatter.format(startDate ?? endDate!);
  }

  String _dateOnly(DateTime? date) {
    if (date == null) {
      return '-';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(
      init: _reviewController,
      builder: (_) => GetBuilder<BookingController>(
      init: _controller,
      builder: (controller) {
        final bookings = _activeBookings(controller);
        final isLoading = _isLoading(controller);
        final errorMessage = _errorMessage(controller);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => _loadCurrentTab(refresh: true),
            child: AnimatedListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(50),
                MyText(text: 'Bookings', size: 28, weight: FontWeight.w700),
                const Gap(24),
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextFormatter: (date, locale) =>
                              DateFormat('EEE, MMM dd, yyyy').format(date),
                          titleTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kBlack,
                          ),
                          leftChevronIcon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kWhite3,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: kBlack,
                              size: 20,
                            ),
                          ),
                          rightChevronIcon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kWhite3,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: kBlack,
                              size: 20,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: kWhite3,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          headerPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          headerMargin: const EdgeInsets.only(bottom: 16),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: kSubText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            color: kSubText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: const BoxDecoration(
                            color: Color(0xFF4A5C6A),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF4A5C6A),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          defaultTextStyle: const TextStyle(
                            color: kBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: kBlack,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          outsideTextStyle: TextStyle(
                            color: kSubText.withOpacity(0.5),
                            fontSize: 15,
                          ),
                          cellMargin: const EdgeInsets.all(6),
                          markersMaxCount: 2,
                          markersAlignment: Alignment.bottomCenter,
                          markerDecoration:
                              const BoxDecoration(color: Colors.transparent),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final markers = _buildEventMarkers(bookings, date);
                            if (markers.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Positioned(
                              bottom: 2,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: markers,
                              ),
                            );
                          },
                        ),
                        eventLoader: (day) {
                          return _buildEventMarkers(bookings, day);
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                Row(
                  children: [
                    _buildMainTab('Items I rent out', 0, kYellowColor),
                    const Gap(20),
                    _buildMainTab('Items I\'m renting', 1, kgreenColor),
                  ],
                ),
                const Gap(24),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      _buildSubTab('Upcoming', 0),
                      const Gap(8),
                      _buildSubTab('Pending', 1),
                      const Gap(8),
                      _buildSubTab('Active', 2),
                      const Gap(8),
                      _buildSubTab('Past', 3),
                    ],
                  ),
                ),
                const Gap(24),
                MyText(
                  text: '${bookings.length} Bookings found',
                  size: 16,
                  color: kSubText,
                  weight: FontWeight.w500,
                ),
                const Gap(24),
                if (isLoading && bookings.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if ((errorMessage ?? '').isNotEmpty && bookings.isEmpty)
                  _ErrorView(
                    message: errorMessage!,
                    onRetry: () => _loadCurrentTab(refresh: true),
                  )
                else if (bookings.isEmpty)
                  const _EmptyView()
                else
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final imageUrl = booking.item?.thumbnailUrl ?? '';
                      final hasImage =
                          imageUrl.startsWith('http://') ||
                          imageUrl.startsWith('https://');

                      return Bounce(
                        onTap: () => _openBookingDetails(booking),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                color: _selectedMainTab == 0
                                    ? kYellowColor
                                    : kgreenColor,
                                width: 4,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CommonImageView(
                                      imagePath: hasImage
                                          ? null
                                          : Assets.imagesShoes1,
                                      url: hasImage ? imageUrl : null,
                                      placeHolder: Assets.imagesShoes1,
                                      height: 50,
                                      width: 50,
                                      radius: 8,
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: booking.itemTitle,
                                            size: 18,
                                            weight: FontWeight.w600,
                                          ),
                                          const Gap(4),
                                          MyText(
                                            text:
                                                '${booking.item?.category ?? 'Booking'} | ${_prettyStatus(booking.status)}',
                                            size: 14,
                                            color: kSubText,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusChipColor(
                                          booking.status,
                                        ).withOpacity(0.16),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: MyText(
                                        text: _prettyStatus(booking.status),
                                        size: 12,
                                        weight: FontWeight.w600,
                                        color: _statusChipColor(booking.status),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Divider(color: kDividerColor),
                                const Gap(10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _infoColumn(
                                        _selectedMainTab == 0
                                            ? 'Renter Name'
                                            : 'Owner Name',
                                        booking.partnerName,
                                      ),
                                    ),
                                    Expanded(
                                      child: _infoColumn(
                                        'Amount',
                                        _currency(booking),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _infoColumn(
                                        'Start Date',
                                        _dateOnly(booking.startDate),
                                      ),
                                    ),
                                    Expanded(
                                      child: _infoColumn(
                                        'End Date',
                                        _dateOnly(booking.endDate),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(20),
                                _buildActionButtons(booking),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                if (isLoading && bookings.isNotEmpty) ...[
                  const Gap(16),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (_hasNext(controller) && bookings.isNotEmpty) ...[
                  const Gap(8),
                  MyButton(
                    onTap: () => _loadCurrentTab(),
                    buttonText: 'Load More',
                    backgroundColor: kWhite,
                    fontColor: kBlack,
                    radius: 20,
                  ),
                ],
                const Gap(100),
              ],
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: title,
          size: 13,
          color: kSubText,
          weight: FontWeight.w600,
        ),
        const Gap(4),
        MyText(text: value, size: 16, color: kBlack, weight: FontWeight.w600),
      ],
    );
  }

  Color _statusChipColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case BookingStatuses.pending:
        return const Color(0xFFE53935);
      case BookingStatuses.accepted:
        return kPrimaryColor;
      case BookingStatuses.active:
        return kgreenColor;
      case BookingStatuses.completed:
        return const Color(0xFF4CAF50);
      case BookingStatuses.declined:
      case BookingStatuses.cancelled:
        return kredColor;
      default:
        return kSubText;
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: MyText(
          text: 'No bookings found for this status.',
          size: 16,
          color: kSubText,
          weight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          MyText(
            text: message,
            size: 14,
            color: Colors.red,
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Bounce(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      ),
    );
  }
}

class _ReviewTypeForm extends StatefulWidget {
  const _ReviewTypeForm({
    super.key,
    required this.label,
    required this.onSubmit,
  });

  final String label;
  final Future<bool> Function(int rating, String comment) onSubmit;

  @override
  State<_ReviewTypeForm> createState() => _ReviewTypeFormState();
}

class _ReviewTypeFormState extends State<_ReviewTypeForm> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_commentController.text.trim().length < 10) {
      Get.snackbar('Review Comment', 'Please write at least 10 characters.');
      return;
    }

    setState(() => _isSubmitting = true);
    await widget.onSubmit(_rating, _commentController.text.trim());
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite3,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(text: widget.label, size: 15, weight: FontWeight.w600),
          const Gap(10),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return Bounce(
                onTap: () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          const Gap(10),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share a few words about your experience',
            ),
          ),
          const Gap(10),
          Align(
            alignment: Alignment.centerRight,
            child: MyButton(
              onTap: _isSubmitting ? () {} : _submit,
              buttonText: _isSubmitting ? 'Submitting...' : 'Submit',
              backgroundColor: kPrimaryColor,
              fontColor: kWhite,
              radius: 20,
            ),
          ),
        ],
      ),
    );
  }
}
