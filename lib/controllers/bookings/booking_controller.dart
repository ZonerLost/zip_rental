import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/services/bookings/booking_service.dart';

class BookingController extends GetxController {
  BookingController({BookingService? bookingService})
    : _bookingService = bookingService ?? BookingService();

  final BookingService _bookingService;
  static const int _pageSize = 10;

  bool isQuoteLoading = false;
  bool isCreateBookingLoading = false;
  bool isSentBookingsLoading = false;
  bool isReceivedBookingsLoading = false;
  bool isBookingDetailLoading = false;
  bool isActionLoading = false;
  bool isPrePhotoUploading = false;
  bool isPostPhotoUploading = false;

  QuoteResponseModel? latestQuote;
  String? sentErrorMessage;
  String? receivedErrorMessage;
  String? bookingDetailErrorMessage;
  String? quoteErrorMessage;

  final List<BookingModel> sentBookings = <BookingModel>[];
  final List<BookingModel> receivedBookings = <BookingModel>[];

  BookingModel? bookingDetail;

  int sentPage = 1;
  int receivedPage = 1;
  bool sentHasNext = false;
  bool receivedHasNext = false;
  int sentTotalPages = 1;
  int receivedTotalPages = 1;

  String? sentStatusFilter;
  String? receivedStatusFilter;

  Future<void> fetchSentBookings({bool refresh = false}) async {
    if (refresh) {
      sentPage = 1;
      sentHasNext = false;
      sentTotalPages = 1;
      sentBookings.clear();
    } else if (isSentBookingsLoading || (sentBookings.isNotEmpty && !sentHasNext)) {
      return;
    }

    isSentBookingsLoading = true;
    sentErrorMessage = null;
    update();

    final result = await _bookingService.getSentBookings(
      status: sentStatusFilter,
      page: sentPage,
      limit: _pageSize,
    );

    isSentBookingsLoading = false;
    if (!result.success) {
      sentErrorMessage = result.message;
      update();
      return;
    }

    if (refresh) {
      sentBookings
        ..clear()
        ..addAll(result.bookings);
    } else {
      sentBookings.addAll(result.bookings);
    }

    final pagination = result.pagination;
    sentHasNext = pagination?.hasNext ?? (result.bookings.length >= _pageSize);
    sentTotalPages = pagination?.totalPages ?? sentTotalPages;
    sentPage = (pagination?.page ?? sentPage) + 1;
    sentErrorMessage = null;
    update();
  }

  Future<void> fetchReceivedBookings({bool refresh = false}) async {
    if (refresh) {
      receivedPage = 1;
      receivedHasNext = false;
      receivedTotalPages = 1;
      receivedBookings.clear();
    } else if (isReceivedBookingsLoading ||
        (receivedBookings.isNotEmpty && !receivedHasNext)) {
      return;
    }

    isReceivedBookingsLoading = true;
    receivedErrorMessage = null;
    update();

    final result = await _bookingService.getReceivedBookings(
      status: receivedStatusFilter,
      page: receivedPage,
      limit: _pageSize,
    );

    isReceivedBookingsLoading = false;
    if (!result.success) {
      receivedErrorMessage = result.message;
      update();
      return;
    }

    if (refresh) {
      receivedBookings
        ..clear()
        ..addAll(result.bookings);
    } else {
      receivedBookings.addAll(result.bookings);
    }

    final pagination = result.pagination;
    receivedHasNext =
        pagination?.hasNext ?? (result.bookings.length >= _pageSize);
    receivedTotalPages = pagination?.totalPages ?? receivedTotalPages;
    receivedPage = (pagination?.page ?? receivedPage) + 1;
    receivedErrorMessage = null;
    update();
  }

  Future<void> fetchBookingDetail(String id) async {
    isBookingDetailLoading = true;
    bookingDetailErrorMessage = null;
    update();

    try {
      bookingDetail = await _bookingService.getBookingById(id);
      _upsertBooking(bookingDetail!);
    } catch (e) {
      bookingDetailErrorMessage = _readMessage(e);
    }

    isBookingDetailLoading = false;
    update();
  }

  Future<QuoteResponseModel?> getQuote({
    required double dailyRate,
    required String startDate,
    required String endDate,
    required String deliveryType,
    String? discountCode,
  }) async {
    isQuoteLoading = true;
    quoteErrorMessage = null;
    update();

    try {
      latestQuote = await _bookingService.quoteBooking(
        QuoteRequestModel(
          dailyRate: dailyRate,
          startDate: startDate,
          endDate: endDate,
          deliveryType: deliveryType,
          discountCode: discountCode,
        ),
      );
      return latestQuote;
    } catch (e) {
      quoteErrorMessage = _readMessage(e);
      Get.snackbar('Quote Failed', quoteErrorMessage!);
      return null;
    } finally {
      isQuoteLoading = false;
      update();
    }
  }

  Future<BookingModel?> createBooking(CreateBookingRequestModel request) async {
    isCreateBookingLoading = true;
    update();

    try {
      final booking = await _bookingService.createBooking(request);
      sentBookings.insert(0, booking);
      latestQuote = null;
      _upsertBooking(booking);
      await fetchSentBookings(refresh: true);
      Get.snackbar('Success', 'Booking request created successfully.');
      return booking;
    } catch (e) {
      Get.snackbar('Booking Failed', _readMessage(e));
      return null;
    } finally {
      isCreateBookingLoading = false;
      update();
    }
  }

  Future<bool> acceptBooking(String id) async {
    return _runBookingAction(
      title: 'Accept Failed',
      action: () => _bookingService.acceptBooking(id),
      onSuccessMessage: 'Booking accepted successfully.',
      refreshReceived: true,
    );
  }

  Future<bool> declineBooking(String id, String? reason) async {
    return _runBookingAction(
      title: 'Decline Failed',
      action: () => _bookingService.declineBooking(id, reason: reason),
      onSuccessMessage: 'Booking declined successfully.',
      refreshReceived: true,
    );
  }

  Future<bool> cancelBooking(String id, String? reason) async {
    return _runBookingAction(
      title: 'Cancel Failed',
      action: () => _bookingService.cancelBooking(id, reason: reason),
      onSuccessMessage: 'Booking cancelled successfully.',
      refreshSent: true,
    );
  }

  Future<bool> completeBooking(String id) async {
    return _runBookingAction(
      title: 'Complete Failed',
      action: () => _bookingService.completeBooking(id),
      onSuccessMessage: 'Booking marked as completed.',
      refreshReceived: true,
    );
  }

  Future<bool> uploadPrePhotos(String id, List<File> photos) async {
    if (!_validatePhotoSelection(photos)) {
      return false;
    }

    isPrePhotoUploading = true;
    update();

    try {
      final updated = await _bookingService.uploadPreRentalPhotos(id, photos);
      if (updated != null) {
        _upsertBooking(updated);
      }
      if (bookingDetail?.id == id) {
        await fetchBookingDetail(id);
      } else {
        update();
      }
      Get.snackbar('Success', 'Pre-rental photos uploaded successfully.');
      return true;
    } catch (e) {
      Get.snackbar('Upload Failed', _readMessage(e));
      return false;
    } finally {
      isPrePhotoUploading = false;
      update();
    }
  }

  Future<bool> uploadPostPhotos(String id, List<File> photos) async {
    if (!_validatePhotoSelection(photos)) {
      return false;
    }

    isPostPhotoUploading = true;
    update();

    try {
      final updated = await _bookingService.uploadPostRentalPhotos(id, photos);
      if (updated != null) {
        _upsertBooking(updated);
      }
      if (bookingDetail?.id == id) {
        await fetchBookingDetail(id);
      } else {
        update();
      }
      Get.snackbar('Success', 'Post-rental photos uploaded successfully.');
      return true;
    } catch (e) {
      Get.snackbar('Upload Failed', _readMessage(e));
      return false;
    } finally {
      isPostPhotoUploading = false;
      update();
    }
  }

  Future<void> setSentStatusFilter(String? status) async {
    sentStatusFilter = _normalizedStatus(status);
    await fetchSentBookings(refresh: true);
  }

  Future<void> setReceivedStatusFilter(String? status) async {
    receivedStatusFilter = _normalizedStatus(status);
    await fetchReceivedBookings(refresh: true);
  }

  Future<bool> _runBookingAction({
    required String title,
    required Future<BookingModel> Function() action,
    required String onSuccessMessage,
    bool refreshSent = false,
    bool refreshReceived = false,
  }) async {
    isActionLoading = true;
    update();

    try {
      final booking = await action();
      _upsertBooking(booking);
      if (refreshSent) {
        await fetchSentBookings(refresh: true);
      }
      if (refreshReceived) {
        await fetchReceivedBookings(refresh: true);
      }
      if (bookingDetail?.id == booking.id) {
        bookingDetail = booking;
      }
      Get.snackbar('Success', onSuccessMessage);
      return true;
    } catch (e) {
      Get.snackbar(title, _readMessage(e));
      return false;
    } finally {
      isActionLoading = false;
      update();
    }
  }

  void _upsertBooking(BookingModel booking) {
    _replaceInList(sentBookings, booking);
    _replaceInList(receivedBookings, booking);
    if (bookingDetail?.id == booking.id) {
      bookingDetail = booking;
    }
  }

  void _replaceInList(List<BookingModel> list, BookingModel booking) {
    final index = list.indexWhere((entry) => entry.id == booking.id);
    if (index >= 0) {
      list[index] = booking;
    }
  }

  bool _validatePhotoSelection(List<File> photos) {
    if (photos.isEmpty) {
      Get.snackbar('No Photos Selected', 'Please choose at least one image.');
      return false;
    }
    if (photos.length > 5) {
      Get.snackbar('Invalid Selection', 'You can upload maximum 5 images.');
      return false;
    }

    for (final photo in photos) {
      final lower = photo.path.toLowerCase();
      final isImage =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
      if (!isImage) {
        Get.snackbar('Invalid Image', 'Only JPEG, PNG, or WebP are allowed.');
        return false;
      }
    }
    return true;
  }

  String? _normalizedStatus(String? value) {
    final trimmed = (value ?? '').trim().toLowerCase();
    if (trimmed.isEmpty) {
      return null;
    }
    return BookingStatuses.all.contains(trimmed) ? trimmed : null;
  }

  String _readMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
