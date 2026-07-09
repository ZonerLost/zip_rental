import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/views/screens/bottom_nav/bottom_nav.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class BookingRequestSentScreen extends StatelessWidget {
  const BookingRequestSentScreen({
    super.key,
    required this.booking,
    required this.paymentMethodLabel,
  });

  final BookingModel booking;
  final String paymentMethodLabel;

  String _dateRangeLabel() {
    final formatter = DateFormat('MMM d, yyyy');
    final start = booking.startDate;
    final end = booking.endDate;
    if (start == null && end == null) {
      return '-';
    }
    if (start != null && end != null) {
      return '${formatter.format(start)} - ${formatter.format(end)}';
    }
    return formatter.format(start ?? end!);
  }

  String _durationLabel() {
    final start = booking.startDate;
    final end = booking.endDate;
    if (start == null || end == null) {
      return '-';
    }
    final days = end.difference(start).inDays + 1;
    return '$days day${days == 1 ? '' : 's'}';
  }

  String _money(double? value) {
    final currency = booking.item?.currency ?? 'CAD';
    if (value == null) {
      return '$currency 0.00';
    }
    return '$currency ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Gap(60),
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: kPrimaryColor,
                  size: 64,
                ),
              ),
            ),
            const Gap(24),
            MyText(
              text: 'Request Sent!',
              size: 24,
              weight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            MyText(
              text:
                  'Your request for renting this item has been sent to the owner of the product, you\'ll receive a notification once approved.',
              size: 14,
              color: kSubText,
              textAlign: TextAlign.center,
            ),
            const Gap(30),
            _detailRow('Date & Time', _dateRangeLabel()),
            _detailRow('Rented Duration', _durationLabel()),
            _detailRow(
              'Order Type',
              (booking.deliveryType ?? '-').isEmpty
                  ? '-'
                  : booking.deliveryType![0].toUpperCase() +
                      booking.deliveryType!.substring(1),
            ),
            _detailRow(
              'Amount in escrow',
              _money(booking.pricing?.securityDeposit),
            ),
            _detailRow('Payment Method Used', paymentMethodLabel),
            const Gap(20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kgreenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_outlined, color: kgreenColor, size: 20),
                  const Gap(10),
                  const Expanded(
                    child: MyText(
                      text:
                          'Renting instead of buying helps reduce waste — thanks for choosing to rent!',
                      size: 12,
                      color: kgreenColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(30),
            MyButton(
              onTap: () => Get.offAll(() => const BottomNavBar(initialIndex: 1)),
              buttonText: 'Go to Home Page',
              height: 56,
              radius: 30,
              fontSize: 16,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(text: label, size: 14, color: kSubText),
          MyText(text: value, size: 14, weight: FontWeight.w600),
        ],
      ),
    );
  }
}
