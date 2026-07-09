import 'dart:math' as math;

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/bookings/booking_controller.dart';
import 'package:zip_peer/controllers/profile/address_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/views/screens/home/item_detail/booking_request_sent.dart';
import 'package:zip_peer/views/screens/subscriptions/add_address.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

const Map<String, String> kPaymentMethodLabels = {
  'card': 'Debit/Credit Card',
  'apple_pay': 'Apple Pay',
  'google_pay': 'Google Pay',
  'amex': 'American Express',
};

class CheckoutScreen2 extends StatefulWidget {
  const CheckoutScreen2({super.key, required this.item});

  final ItemModel item;

  @override
  State<CheckoutScreen2> createState() => _CheckoutScreen2State();
}

class _CheckoutScreen2State extends State<CheckoutScreen2> {
  late final BookingController _bookingController;
  final TextEditingController _discountController = TextEditingController();

  bool _agreedToTerms = false;
  String? _selectedOption;
  DateTimeRange? _dateRange;

  // Used only as a fallback when the item's owner hasn't configured a
  // pickupSchedule at all (older listings) — otherwise pickup time comes
  // from the schedule automatically.
  TimeOfDay? _pickupFromTime;
  TimeOfDay? _pickupToTime;
  DateTime? _pickupDay;
  DateTime _pickupFocusedMonth = DateTime.now();

  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _bookingController = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  Set<DateTime> get _blockedDates {
    return (widget.item.availability?.blockedDates ?? const <String>[])
        .map((raw) => DateTime.tryParse(raw))
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet();
  }

  bool _rangeOverlapsBlockedDates(DateTimeRange range) {
    final blocked = _blockedDates;
    if (blocked.isEmpty) {
      return false;
    }
    for (
      var day = _dateOnly(range.start);
      !day.isAfter(_dateOnly(range.end));
      day = day.add(const Duration(days: 1))
    ) {
      if (blocked.contains(day)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    // Start date must be strictly after today — bookings can't start "now".
    final earliestBookableDay = _dateOnly(now).add(const Duration(days: 1));
    final availability = widget.item.availability;
    final earliestAllowed = availability?.availableFrom != null &&
            availability!.availableFrom!.isAfter(earliestBookableDay)
        ? availability.availableFrom!
        : earliestBookableDay;
    final latestAllowed =
        availability?.availableTo ?? DateTime(now.year + 2);

    if (latestAllowed.isBefore(earliestAllowed)) {
      Get.snackbar('Unavailable', 'This item has no available dates to book.');
      return;
    }

    final selected = await showDateRangePicker(
      context: context,
      firstDate: earliestAllowed,
      lastDate: latestAllowed,
      initialDateRange: _dateRange,
    );

    if (selected == null) {
      return;
    }

    if (_rangeOverlapsBlockedDates(selected)) {
      Get.snackbar(
        'Dates Unavailable',
        'This item is already booked on one or more of the selected dates. Please choose a different range.',
      );
      return;
    }

    final totalDays = selected.duration.inDays + 1;
    final minDays = widget.item.minRentalDays;
    final maxDays = widget.item.maxRentalDays;
    if (minDays != null && totalDays < minDays) {
      Get.snackbar(
        'Minimum Rental Period',
        'This item requires a minimum of $minDays day${minDays == 1 ? '' : 's'}.',
      );
      return;
    }
    if (maxDays != null && totalDays > maxDays) {
      Get.snackbar(
        'Maximum Rental Period',
        'This item can be booked for a maximum of $maxDays day${maxDays == 1 ? '' : 's'}.',
      );
      return;
    }

    setState(() {
      _dateRange = selected;
      _ensurePickupDayDefault();
    });

    await _autoRequestQuote();
  }

  /// Silently (re)fetches a quote once both a date range and a delivery
  /// type are picked. Unlike [_requestQuote], this never shows a
  /// "select delivery or pickup" / "select dates" snackbar, since it can
  /// fire before the user has had a chance to complete either step.
  Future<void> _autoRequestQuote() async {
    if (_selectedOption == null || _dateRange == null) {
      return;
    }
    await _requestQuote();
  }

  void _ensurePickupDayDefault() {
    if (_selectedOption != 'pickup' || _dateRange == null) {
      return;
    }
    final range = _dateRange!;
    if (_pickupDay == null ||
        _pickupDay!.isBefore(_dateOnly(range.start)) ||
        _pickupDay!.isAfter(_dateOnly(range.end))) {
      _pickupDay = _dateOnly(range.start);
    }
    _pickupFocusedMonth = _pickupDay!;
  }

  bool _isPickupDaySelectable(DateTime day) {
    final dateOnly = _dateOnly(day);
    if (_blockedDates.contains(dateOnly)) {
      return false;
    }
    final availability = widget.item.availability;
    if (availability?.availableFrom != null &&
        dateOnly.isBefore(_dateOnly(availability!.availableFrom!))) {
      return false;
    }
    if (availability?.availableTo != null &&
        dateOnly.isAfter(_dateOnly(availability!.availableTo!))) {
      return false;
    }
    final schedule = widget.item.pickupSchedule;
    if (schedule == null) {
      // No schedule configured by the owner — fall back to unconstrained.
      return true;
    }
    return schedule.windowFor(dateOnly) != null;
  }

  bool _hasAnySelectableDay(DateTime start, DateTime end) {
    for (
      var day = _dateOnly(start);
      !day.isAfter(_dateOnly(end));
      day = day.add(const Duration(days: 1))
    ) {
      if (_isPickupDaySelectable(day)) {
        return true;
      }
    }
    return false;
  }

  DayScheduleModel? get _resolvedPickupWindow {
    final schedule = widget.item.pickupSchedule;
    if (schedule == null || _pickupDay == null) {
      return null;
    }
    return schedule.windowFor(_pickupDay!);
  }

  DateTime get _pickupCalendarFirstDay {
    final now = DateTime.now();
    final range = _dateRange;
    return range != null ? _dateOnly(range.start) : _dateOnly(now);
  }

  DateTime get _pickupCalendarLastDay {
    final now = DateTime.now();
    final range = _dateRange;
    return range != null ? _dateOnly(range.end) : DateTime(now.year + 2);
  }

  void _selectPickupDay(DateTime day, DateTime focusedMonth) {
    if (!_isPickupDaySelectable(day)) {
      Get.snackbar(
        'Pickup Unavailable',
        'This item is not available for pickup on the selected day.',
      );
      return;
    }
    setState(() {
      _pickupDay = _dateOnly(day);
      _pickupFocusedMonth = focusedMonth;
    });
  }

  Future<void> _pickPickupTime({required bool isFrom}) async {
    final initial = isFrom
        ? (_pickupFromTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_pickupToTime ?? const TimeOfDay(hour: 18, minute: 0));

    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (isFrom) {
        _pickupFromTime = selected;
      } else {
        _pickupToTime = selected;
      }
    });
  }

  String _to12HourLabel(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) {
      return time24;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return time24;
    }
    return DateFormat('hh:mm a').format(DateTime(2026, 1, 1, hour, minute));
  }

  String? _resolvedPickupTimeFrom() {
    final window = _resolvedPickupWindow;
    if (window != null) {
      return window.allDay ? '12:00 AM' : (window.startTime != null ? _to12HourLabel(window.startTime!) : null);
    }
    return _pickupFromTime != null ? _formatTime(_pickupFromTime!) : null;
  }

  String? _resolvedPickupTimeTo() {
    final window = _resolvedPickupWindow;
    if (window != null) {
      return window.allDay ? '11:59 PM' : (window.endTime != null ? _to12HourLabel(window.endTime!) : null);
    }
    return _pickupToTime != null ? _formatTime(_pickupToTime!) : null;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  double? _distanceKm(CoordinatesModel? origin, ProfileCoordinates? destination) {
    if (origin?.lat == null ||
        origin?.lng == null ||
        destination?.lat == null ||
        destination?.lng == null) {
      return null;
    }
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(destination!.lat! - origin!.lat!);
    final dLng = _degToRad(destination.lng! - origin.lng!);
    final lat1 = _degToRad(origin.lat!);
    final lat2 = _degToRad(destination.lat!);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return earthRadiusKm * c;
  }

  /// Rough delivery-fee estimate for display in the address picker only.
  /// The amount actually charged always comes from the booking quote
  /// endpoint, which doesn't take an address into account.
  double? _estimateDeliveryFee(double? distanceKm) {
    final tiers = (widget.item.deliveryOptions?.deliveryPricing.isNotEmpty ?? false)
        ? widget.item.deliveryOptions!.deliveryPricing
        : widget.item.deliveryPricing;
    if (distanceKm != null && tiers.isNotEmpty) {
      final sorted = [...tiers]..sort((a, b) => a.maxKm.compareTo(b.maxKm));
      for (final tier in sorted) {
        if (distanceKm <= tier.maxKm) {
          return tier.price;
        }
      }
      return sorted.last.price;
    }
    return widget.item.deliveryOptions?.deliveryFee ?? widget.item.deliveryFee;
  }

  Future<void> _showSelectAddressSheet() async {
    final addressController = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

    AddressModel? tempSelected = _selectedAddress;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return GetBuilder<AddressController>(
              init: addressController,
              builder: (controller) {
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
                      Bounce(
                        onTap: () => Navigator.of(sheetContext).pop(),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back, size: 20),
                            const Gap(6),
                            MyText(text: 'Back', size: 14, weight: FontWeight.w600),
                          ],
                        ),
                      ),
                      const Gap(16),
                      MyText(text: 'Select Address', size: 22, weight: FontWeight.w700),
                      const Gap(6),
                      MyText(
                        text: 'Please select the address from your added ones.',
                        size: 13,
                        color: kSubText,
                      ),
                      const Gap(20),
                      if (controller.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (controller.addresses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: MyText(
                            text: 'No saved addresses yet. Add one below.',
                            size: 13,
                            color: kSubText,
                          ),
                        )
                      else
                        for (final address in controller.addresses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _AddressOptionCard(
                              address: address,
                              selected: tempSelected?.id == address.id,
                              distanceKm: _distanceKm(
                                widget.item.location?.coordinates,
                                address.coordinates,
                              ),
                              estimatedFee: _estimateDeliveryFee(
                                _distanceKm(
                                  widget.item.location?.coordinates,
                                  address.coordinates,
                                ),
                              ),
                              currency: widget.item.currency ?? 'CAD',
                              onTap: () {
                                setSheetState(() => tempSelected = address);
                              },
                            ),
                          ),
                      const Gap(8),
                      Bounce(
                        onTap: () async {
                          final added = await Get.to(() => const AddAddressScreen());
                          if (added == true) {
                            await addressController.loadAddresses();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: kWhite3,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: MyText(
                              text: '+Add new address',
                              size: 14,
                              weight: FontWeight.w600,
                              color: kSubText,
                            ),
                          ),
                        ),
                      ),
                      const Gap(20),
                      MyButton(
                        onTap: tempSelected == null
                            ? () {}
                            : () {
                                setState(() => _selectedAddress = tempSelected);
                                Navigator.of(sheetContext).pop();
                                _autoRequestQuote();
                              },
                        buttonText: 'Continue',
                        height: 56,
                        radius: 30,
                        fontSize: 16,
                        isactive: tempSelected != null,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String?> _showSelectPaymentSheet() async {
    String selected = 'card';

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
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
                  Bounce(
                    onTap: () => Navigator.of(sheetContext).pop(),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 20),
                        const Gap(6),
                        MyText(text: 'Back', size: 14, weight: FontWeight.w600),
                      ],
                    ),
                  ),
                  const Gap(16),
                  MyText(text: 'Select Payment', size: 22, weight: FontWeight.w700),
                  const Gap(6),
                  MyText(
                    text: 'Please select the preferred payment method.',
                    size: 13,
                    color: kSubText,
                  ),
                  const Gap(20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: kPaymentMethodLabels.entries.map((entry) {
                      final isSelected = selected == entry.key;
                      return Bounce(
                        onTap: () => setSheetState(() => selected = entry.key),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 40 - 12) / 2,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? kPrimaryColor : kBorderColor2,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    _paymentMethodIcon(entry.key),
                                    size: 22,
                                    color: isSelected ? kPrimaryColor : kBlack,
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, size: 18, color: kPrimaryColor),
                                ],
                              ),
                              const Gap(8),
                              MyText(text: entry.value, size: 13, weight: FontWeight.w600),
                            ],
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                  const Gap(24),
                  MyButton(
                    onTap: () => Navigator.of(sheetContext).pop(selected),
                    buttonText: 'Continue',
                    height: 56,
                    radius: 30,
                    fontSize: 16,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _paymentMethodIcon(String methodId) {
    switch (methodId) {
      case 'apple_pay':
        return Icons.apple;
      case 'google_pay':
        return Icons.g_mobiledata;
      case 'amex':
        return Icons.credit_card_outlined;
      case 'card':
      default:
        return Icons.credit_card;
    }
  }

  Future<QuoteResponseModel?> _requestQuote() async {
    if (_selectedOption == null) {
      Get.snackbar('Select Delivery Type', 'Please choose delivery or pickup.');
      return null;
    }
    if (_dateRange == null) {
      Get.snackbar('Select Dates', 'Please select your booking dates first.');
      return null;
    }

    return _bookingController.getQuote(
      dailyRate: widget.item.dailyRate ?? 0,
      startDate: _apiDate(_dateRange!.start),
      endDate: _apiDate(_dateRange!.end),
      deliveryType: _selectedOption!,
      discountCode: _discountController.text.trim(),
    );
  }

  Future<void> _handleContinueToPayment() async {
    if (!_agreedToTerms) {
      Get.snackbar(
        'Terms Required',
        'Please agree to the Terms & Cancellation Policy.',
      );
      return;
    }
    if (_selectedOption == null) {
      Get.snackbar('Select Delivery Type', 'Please choose delivery or pickup.');
      return;
    }
    if (_dateRange == null) {
      Get.snackbar('Select Dates', 'Please select your booking dates.');
      return;
    }
    if (_selectedOption == 'pickup') {
      final schedule = widget.item.pickupSchedule;
      if (schedule != null) {
        if (_pickupDay == null) {
          Get.snackbar('Select Pickup Day', 'Please choose a pickup day.');
          return;
        }
        if (_resolvedPickupWindow == null) {
          Get.snackbar(
            'Pickup Unavailable',
            'This item is not available for pickup on the selected day. Please choose a different day.',
          );
          return;
        }
      } else if (_pickupFromTime == null || _pickupToTime == null) {
        Get.snackbar(
          'Pickup Time Required',
          'Please select pickup start and end times.',
        );
        return;
      }
    }
    if (_selectedOption == 'delivery' && _selectedAddress == null) {
      Get.snackbar(
        'Delivery Address Required',
        'Please select a delivery address.',
      );
      return;
    }

    final quote = _bookingController.latestQuote ?? await _requestQuote();
    if (quote == null || !mounted) {
      return;
    }

    final paymentMethod = await _showSelectPaymentSheet();
    if (paymentMethod == null || !mounted) {
      return;
    }

    final booking = await _bookingController.createBooking(
      CreateBookingRequestModel(
        itemId: widget.item.id,
        startDate: _apiDate(_dateRange!.start),
        endDate: _apiDate(_dateRange!.end),
        deliveryType: _selectedOption!,
        deliveryAddress: _selectedOption == 'delivery' && _selectedAddress != null
            ? BookingAddressModel(
                label: _selectedAddress!.label,
                street: _selectedAddress!.addressLine,
                city: _selectedAddress!.city,
                province: _selectedAddress!.province,
              )
            : null,
        pickupTimeFrom:
            _selectedOption == 'pickup' ? _resolvedPickupTimeFrom() : null,
        pickupTimeTo: _selectedOption == 'pickup' ? _resolvedPickupTimeTo() : null,
        discountCode: _discountController.text.trim(),
      ),
    );

    if (booking == null || !mounted) {
      return;
    }

    Get.off(
      () => BookingRequestSentScreen(
        booking: booking,
        paymentMethodLabel: kPaymentMethodLabels[paymentMethod] ?? 'Card',
      ),
    );
  }

  String _apiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _friendlyDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final date = DateTime(2026, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mm a').format(date);
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(text: label, size: 14, color: kSubText),
        MyText(text: price, size: 14, weight: FontWeight.w600),
      ],
    );
  }

  String _money(double? value) {
    final currency = widget.item.currency ?? 'CAD';
    if (value == null) {
      return '$currency 0.00';
    }
    return '$currency ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingController>(
      init: _bookingController,
      builder: (controller) {
        final quote = controller.latestQuote;
        final pricing = quote?.pricing;
        final pickupWindow = _resolvedPickupWindow;

        return Scaffold(
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: kWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: _money(pricing?.totalAmount),
                        size: 24,
                        weight: FontWeight.w700,
                      ),
                      MyText(
                        text: 'Total amount',
                        size: 14,
                        color: kSubText,
                      ),
                    ],
                  ),
                  const Gap(12),
                  Expanded(
                    child: MyButton(
                      onTap: _handleContinueToPayment,
                      buttonText: controller.isCreateBookingLoading
                          ? 'Submitting...'
                          : 'Continue to payment',
                      height: 56,
                      radius: 30,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: AnimatedListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Gap(50),
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                  MyText(
                    text: 'Checkout',
                    size: 20,
                    paddingLeft: 12,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
              const Gap(20),
              MyText(
                text: 'ADDED ITEMS',
                size: 12,
                paddingLeft: 10,
                weight: FontWeight.w600,
                color: kSubText,
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CommonImageView(
                      imagePath: widget.item.thumbnailUrl.isNotEmpty
                          ? null
                          : Assets.imagesShoes2,
                      url: widget.item.thumbnailUrl.isNotEmpty
                          ? widget.item.thumbnailUrl
                          : null,
                      placeHolder: Assets.imagesShoes2,
                      height: 120,
                      width: 90,
                      radius: 12,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: widget.item.title ?? 'Untitled Item',
                            size: 16,
                            weight: FontWeight.w600,
                          ),
                          const Gap(4),
                          MyText(
                            text:
                                '${widget.item.totalRentals ?? 0} Times rented | ${widget.item.condition ?? 'N/A'} condition',
                            size: 12,
                            color: kSubText,
                            weight: FontWeight.w600,
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              MyText(
                                text: _money(widget.item.dailyRate),
                                size: 18,
                                weight: FontWeight.w700,
                                color: kPrimaryColor,
                              ),
                              MyText(
                                text: ' / day',
                                size: 14,
                                color: kSubText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              MyButton(
                onTap: _pickDateRange,
                buttonText: _dateRange == null
                    ? 'Select Booking Dates'
                    : '${_friendlyDate(_dateRange!.start)} - ${_friendlyDate(_dateRange!.end)}',
                height: 50,
                radius: 30,
                fontSize: 14,
                backgroundColor: kWhite,
                fontColor: kBlack,
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kbackground,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _deliveryPickupSegment(
                        label: 'Delivery',
                        isSelected: _selectedOption == 'delivery',
                        onTap: () async {
                          setState(() {
                            _selectedOption = 'delivery';
                          });
                          await _autoRequestQuote();
                        },
                      ),
                    ),
                    Expanded(
                      child: _deliveryPickupSegment(
                        label: 'Pickup',
                        isSelected: _selectedOption == 'pickup',
                        onTap: () async {
                          setState(() {
                            _selectedOption = 'pickup';
                            _ensurePickupDayDefault();
                          });
                          await _autoRequestQuote();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              if (_selectedOption == 'pickup') ...[
                if (!_hasAnySelectableDay(
                  _pickupCalendarFirstDay,
                  _pickupCalendarLastDay,
                ))
                  MyText(
                    text:
                        'The owner has no pickup availability within your selected booking dates. Please choose different booking dates.',
                    size: 13,
                    color: kredColor,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
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
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: _pickupCalendarFirstDay,
                          lastDay: _pickupCalendarLastDay,
                          focusedDay: _pickupFocusedMonth,
                          selectedDayPredicate: (day) =>
                              _pickupDay != null && isSameDay(_pickupDay, day),
                          enabledDayPredicate: _isPickupDaySelectable,
                          onDaySelected: (selected, focused) =>
                              _selectPickupDay(selected, focused),
                          onPageChanged: (focused) {
                            setState(() => _pickupFocusedMonth = focused);
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
                            selectedDecoration: const BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            todayDecoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
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
                              color: kSubText.withOpacity(0.35),
                              fontSize: 15,
                            ),
                            disabledTextStyle: TextStyle(
                              color: kSubText.withOpacity(0.35),
                              fontSize: 15,
                            ),
                            cellMargin: const EdgeInsets.all(6),
                          ),
                        ),
                        if (widget.item.pickupSchedule != null) ...[
                          const Gap(4),
                          if (_pickupDay != null && pickupWindow == null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: MyText(
                                text:
                                    'This item is not available for pickup on the selected day.',
                                size: 13,
                                color: kredColor,
                              ),
                            )
                          else if (pickupWindow != null)
                            Row(
                              children: [
                                Expanded(
                                  child: _selectionCard(
                                    title: 'Available From',
                                    value: pickupWindow.allDay
                                        ? 'All day'
                                        : (pickupWindow.startTime != null
                                            ? _to12HourLabel(pickupWindow.startTime!)
                                            : '-'),
                                    onTap: () {},
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: _selectionCard(
                                    title: 'Available To',
                                    value: pickupWindow.allDay
                                        ? 'All day'
                                        : (pickupWindow.endTime != null
                                            ? _to12HourLabel(pickupWindow.endTime!)
                                            : '-'),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                        ] else ...[
                          const Gap(4),
                          Row(
                            children: [
                              Expanded(
                                child: _selectionCard(
                                  title: 'Pickup From',
                                  value: _pickupFromTime == null
                                      ? 'Select time'
                                      : _formatTime(_pickupFromTime!),
                                  onTap: () => _pickPickupTime(isFrom: true),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: _selectionCard(
                                  title: 'Pickup To',
                                  value: _pickupToTime == null
                                      ? 'Select time'
                                      : _formatTime(_pickupToTime!),
                                  onTap: () => _pickPickupTime(isFrom: false),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
              if (_selectedOption == 'delivery') ...[
                if (_selectedAddress == null)
                  MyButton(
                    onTap: _showSelectAddressSheet,
                    buttonText: 'Select address',
                    height: 50,
                    radius: 30,
                    fontSize: 14,
                    backgroundColor: kWhite3,
                    fontColor: kSubText,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: (_selectedAddress!.label ?? '').isNotEmpty
                                    ? _selectedAddress!.label!
                                    : 'Address',
                                size: 15,
                                weight: FontWeight.w600,
                              ),
                              const Gap(4),
                              MyText(
                                text: _selectedAddress!.displayAddress,
                                size: 12,
                                color: kSubText,
                              ),
                            ],
                          ),
                        ),
                        Bounce(
                          onTap: _showSelectAddressSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: kWhite3,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: MyText(
                              text: 'Change',
                              size: 13,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if ((controller.quoteErrorMessage ?? '').isNotEmpty) ...[
                const Gap(10),
                MyText(
                  text: controller.quoteErrorMessage!,
                  size: 13,
                  color: kredColor,
                ),
              ],
              const Gap(24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(24),
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
                    CustomCheckbox2(
                      text: 'Agree to',
                      text2: 'Terms & Cancellation Policy',
                      onChanged: (value) {
                        _agreedToTerms = value;
                      },
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: _discountController,
                            hint: 'Discount code',
                            hintColor: kSubText,
                            hintsize: 14,
                            marginBottom: 0,
                            backgroundColor: kbackground,
                          ),
                        ),
                        const Gap(12),
                        MyButton(
                          onTap: _requestQuote,
                          buttonText:
                              controller.isQuoteLoading ? 'Loading...' : 'Apply',
                          backgroundColor: kPrimaryColor.withOpacity(0.2),
                          fontColor: kPrimaryColor,
                          width: 100,
                          height: 50,
                          radius: 12,
                          fontSize: 14,
                          hasgrad: false,
                        ),
                      ],
                    ),
                    const Gap(20),
                    _buildPriceRow(
                      'Items Price',
                      _money(pricing?.basePrice ?? widget.item.dailyRate),
                    ),
                    const Gap(12),
                    _buildPriceRow(
                      'Discount (${(pricing?.discountPercent ?? 0).toStringAsFixed(0)}%)',
                      _money(pricing?.discountAmount),
                    ),
                    const Gap(12),
                    _buildPriceRow(
                      'Delivery Fees',
                      _money(quote?.deliveryFee),
                    ),
                    const Gap(12),
                    _buildPriceRow(
                      'Subtotal',
                      _money(pricing?.subtotal ?? pricing?.basePrice),
                    ),
                    const Gap(12),
                    _buildPriceRow(
                      'Service Fee',
                      _money(pricing?.serviceFee),
                    ),
                    const Gap(12),
                    Divider(color: kDividerColor),
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            MyText(
                              text: 'Price to Pay (Security Hold)',
                              size: 14,
                              color: kSubText,
                            ),
                            const Gap(4),
                            CommonImageView(
                              imagePath: Assets.imagesInfoCircleBlack,
                              height: 20,
                            ),
                          ],
                        ),
                        MyText(
                          text: _money(pricing?.securityDeposit),
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const Gap(12),
                    _buildPriceRow(
                      'Total Amount',
                      _money(pricing?.totalAmount),
                    ),
                  ],
                ),
              ),
              const Gap(100),
            ],
          ),
        );
      },
    );
  }

  Widget _deliveryPickupSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Bounce(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: MyText(
            text: label,
            size: 15,
            weight: FontWeight.w600,
            color: isSelected ? kPrimaryColor : kSubText,
          ),
        ),
      ),
    );
  }

  Widget _selectionCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Bounce(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(text: title, size: 12, color: kSubText),
            const Gap(4),
            MyText(text: value, size: 16, weight: FontWeight.w600),
          ],
        ),
      ),
    );
  }
}

class _AddressOptionCard extends StatelessWidget {
  const _AddressOptionCard({
    required this.address,
    required this.selected,
    required this.distanceKm,
    required this.estimatedFee,
    required this.currency,
    required this.onTap,
  });

  final AddressModel address;
  final bool selected;
  final double? distanceKm;
  final double? estimatedFee;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite3,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: (address.label ?? '').isNotEmpty
                            ? address.label!
                            : 'Address',
                        size: 15,
                        weight: FontWeight.w600,
                      ),
                      const Gap(4),
                      MyText(
                        text: address.displayAddress,
                        size: 12,
                        color: kSubText,
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? kPrimaryColor : kSubText,
                  size: 22,
                ),
              ],
            ),
            if (distanceKm != null || estimatedFee != null) ...[
              const Gap(10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      text: distanceKm != null
                          ? '${distanceKm!.toStringAsFixed(1)} KM'
                          : '-',
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                    MyText(
                      text: estimatedFee != null
                          ? '$currency ${estimatedFee!.toStringAsFixed(2)} delivery fees'
                          : 'Delivery fee unavailable',
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
