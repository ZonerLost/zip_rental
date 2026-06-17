import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/bookings/booking_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class CheckoutScreen2 extends StatefulWidget {
  const CheckoutScreen2({super.key, required this.item});

  final ItemModel item;

  @override
  State<CheckoutScreen2> createState() => _CheckoutScreen2State();
}

class _CheckoutScreen2State extends State<CheckoutScreen2> {
  late final BookingController _bookingController;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _addressLabelController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();

  bool _agreedToTerms = false;
  String? _selectedOption;
  DateTimeRange? _dateRange;
  TimeOfDay? _pickupFromTime;
  TimeOfDay? _pickupToTime;

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
    _addressLabelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: _dateRange,
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _dateRange = selected;
    });

    await _requestQuote();
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

  Future<void> _submitBooking() async {
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
    if (_selectedOption == 'pickup' &&
        (_pickupFromTime == null || _pickupToTime == null)) {
      Get.snackbar(
        'Pickup Time Required',
        'Please select pickup start and end times.',
      );
      return;
    }
    if (_selectedOption == 'delivery' &&
        _streetController.text.trim().isEmpty) {
      Get.snackbar(
        'Delivery Address Required',
        'Please add your delivery street address.',
      );
      return;
    }

    final quote = _bookingController.latestQuote ?? await _requestQuote();
    if (quote == null) {
      return;
    }

    final booking = await _bookingController.createBooking(
      CreateBookingRequestModel(
        itemId: widget.item.id,
        startDate: _apiDate(_dateRange!.start),
        endDate: _apiDate(_dateRange!.end),
        deliveryType: _selectedOption!,
        deliveryAddress: _selectedOption == 'delivery'
            ? BookingAddressModel(
                label: _addressLabelController.text.trim(),
                street: _streetController.text.trim(),
                city: _cityController.text.trim(),
                province: _provinceController.text.trim(),
              )
            : null,
        pickupTimeFrom: _selectedOption == 'pickup'
            ? _formatTime(_pickupFromTime!)
            : null,
        pickupTimeTo: _selectedOption == 'pickup'
            ? _formatTime(_pickupToTime!)
            : null,
        discountCode: _discountController.text.trim(),
      ),
    );

    if (booking == null || !mounted) {
      return;
    }

    Get.off(() => const BottomNavBar(initialIndex: 1));
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      buttonText: controller.isQuoteLoading ? 'Loading...' : 'Apply',
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
                Column(
                  children: [
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
                const Gap(20),
                MyButton(
                  onTap: _submitBooking,
                  buttonText: controller.isCreateBookingLoading
                      ? 'Submitting...'
                      : 'Continue to payment',
                  height: 56,
                  radius: 30,
                  fontSize: 16,
                ),
                const Gap(20),
              ],
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
                  color: kPrimaryColor.withOpacity(0.08),
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
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: () async {
                        setState(() {
                          _selectedOption = 'delivery';
                        });
                        await _requestQuote();
                      },
                      buttonText: 'Delivery',
                      height: 50,
                      radius: 30,
                      fontSize: 14,
                      backgroundColor: _selectedOption == 'delivery'
                          ? kPrimaryColor
                          : kWhite,
                      fontColor: _selectedOption == 'delivery'
                          ? kWhite
                          : kBlack,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: MyButton(
                      onTap: () async {
                        setState(() {
                          _selectedOption = 'pickup';
                        });
                        await _requestQuote();
                      },
                      buttonText: 'Pickup',
                      height: 50,
                      radius: 30,
                      fontSize: 14,
                      backgroundColor: _selectedOption == 'pickup'
                          ? kPrimaryColor
                          : kWhite,
                      fontColor: _selectedOption == 'pickup' ? kWhite : kBlack,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              if (_selectedOption == 'pickup') ...[
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
              if (_selectedOption == 'delivery') ...[
                MyTextField(
                  controller: _addressLabelController,
                  hint: 'Home / Office (optional)',
                  label: 'Address Label',
                  backgroundColor: kWhite,
                ),
                MyTextField(
                  controller: _streetController,
                  hint: '123 Main Street',
                  label: 'Street Address',
                  backgroundColor: kWhite,
                ),
                MyTextField(
                  controller: _cityController,
                  hint: 'Montreal',
                  label: 'City',
                  backgroundColor: kWhite,
                ),
                MyTextField(
                  controller: _provinceController,
                  hint: 'QC',
                  label: 'Province',
                  backgroundColor: kWhite,
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
              const Gap(100),
            ],
          ),
        );
      },
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
