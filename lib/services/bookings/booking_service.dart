import 'dart:io';

import 'package:get/get.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class BookingService extends ApiServiceBase {
  BookingService({AuthService? authService}) : super(authService: authService);

  Future<QuoteResponseModel> quoteBooking(QuoteRequestModel requestModel) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/bookings/quote',
      requiresAuth: false,
      body: requestModel.toJson(),
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    if (!success) {
      throw Exception(message);
    }

    final data = _dataMap(response);
    return QuoteResponseModel.fromJson(data);
  }

  Future<BookingModel> createBooking(
    CreateBookingRequestModel requestModel,
  ) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/bookings',
      requiresAuth: true,
      body: requestModel.toJson(),
    );

    return _parseSingleBookingOrThrow(response);
  }

  Future<PaginatedBookingsResponse> getSentBookings({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    return _getBookingsList(
      '/bookings/sent',
      status: status,
      page: page,
      limit: limit,
    );
  }

  Future<PaginatedBookingsResponse> getReceivedBookings({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    return _getBookingsList(
      '/bookings/received',
      status: status,
      page: page,
      limit: limit,
    );
  }

  Future<BookingModel> getBookingById(String bookingId) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/bookings/${Uri.encodeComponent(bookingId)}',
      requiresAuth: true,
    );

    return _parseSingleBookingOrThrow(
      response,
      notFoundMessage: 'Booking not found',
    );
  }

  Future<BookingModel> acceptBooking(String bookingId) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/bookings/${Uri.encodeComponent(bookingId)}/accept',
      requiresAuth: true,
    );

    return _parseSingleBookingOrThrow(
      response,
      notFoundMessage: 'Booking not found',
      forbiddenMessage: 'You do not have permission to accept this booking.',
    );
  }

  Future<BookingModel> declineBooking(String bookingId, {String? reason}) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/bookings/${Uri.encodeComponent(bookingId)}/decline',
      requiresAuth: true,
      body: <String, dynamic>{
        if ((reason ?? '').trim().isNotEmpty) 'reason': reason!.trim(),
      },
    );

    return _parseSingleBookingOrThrow(
      response,
      notFoundMessage: 'Booking not found',
      forbiddenMessage: 'You do not have permission to decline this booking.',
    );
  }

  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/bookings/${Uri.encodeComponent(bookingId)}/cancel',
      requiresAuth: true,
      body: <String, dynamic>{
        if ((reason ?? '').trim().isNotEmpty) 'reason': reason!.trim(),
      },
    );

    return _parseSingleBookingOrThrow(
      response,
      notFoundMessage: 'Booking not found',
      forbiddenMessage: 'You do not have permission to cancel this booking.',
    );
  }

  Future<BookingModel> completeBooking(String bookingId) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/bookings/${Uri.encodeComponent(bookingId)}/complete',
      requiresAuth: true,
    );

    return _parseSingleBookingOrThrow(
      response,
      notFoundMessage: 'Booking not found',
      forbiddenMessage: 'You do not have permission to complete this booking.',
    );
  }

  Future<BookingModel?> uploadPreRentalPhotos(
    String bookingId,
    List<File> photos,
  ) async {
    return _uploadPhotos(
      bookingId,
      photos,
      pathSuffix: 'pre-photos',
      forbiddenMessage:
          'You do not have permission to upload pre-rental photos.',
    );
  }

  Future<BookingModel?> uploadPostRentalPhotos(
    String bookingId,
    List<File> photos,
  ) async {
    return _uploadPhotos(
      bookingId,
      photos,
      pathSuffix: 'post-photos',
      forbiddenMessage:
          'You do not have permission to upload post-rental photos.',
    );
  }

  Future<PaginatedBookingsResponse> _getBookingsList(
    String path, {
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: path,
      requiresAuth: true,
      query: <String, dynamic>{
        if ((status ?? '').trim().isNotEmpty) 'status': status!.trim(),
        'page': page.toString(),
        'limit': limit.clamp(1, 50).toString(),
      },
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(response, success);
    final root = asMap(response.body);

    if (!success) {
      return PaginatedBookingsResponse(success: false, message: message);
    }

    final data = getByPath(root, 'data');
    final bookings = data is List
        ? data
              .whereType<Map>()
              .map((entry) => BookingModel.fromJson(stringKeyMap(entry)))
              .where((booking) => booking.id.trim().isNotEmpty)
              .toList(growable: false)
        : const <BookingModel>[];

    final paginationRaw = getByPath(root, 'pagination');
    final pagination = paginationRaw is Map
        ? BookingPaginationModel.fromJson(stringKeyMap(paginationRaw))
        : null;

    return PaginatedBookingsResponse(
      success: true,
      message: message,
      bookings: bookings,
      pagination: pagination,
    );
  }

  Future<BookingModel?> _uploadPhotos(
    String bookingId,
    List<File> photos, {
    required String pathSuffix,
    String? forbiddenMessage,
  }) async {
    final multipartFiles = photos
        .map(multipartFileFromPath)
        .toList(growable: false);

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/bookings/${Uri.encodeComponent(bookingId)}/$pathSuffix',
      requiresAuth: true,
      body: FormData(<String, dynamic>{'photos': multipartFiles}),
    );

    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: 'Booking not found',
      forbiddenMessage: forbiddenMessage,
    );

    if (!success) {
      throw Exception(message);
    }

    return _parseSingleBooking(response);
  }

  BookingModel _parseSingleBookingOrThrow(
    Response<dynamic> response, {
    String? notFoundMessage,
    String? forbiddenMessage,
  }) {
    final success = resolveSuccess(response);
    final message = resolveMessage(
      response,
      success,
      notFoundMessage: notFoundMessage,
      forbiddenMessage: forbiddenMessage,
    );

    if (!success) {
      throw Exception(message);
    }

    final booking = _parseSingleBooking(response);
    if (booking == null) {
      throw Exception(message);
    }
    return booking;
  }

  BookingModel? _parseSingleBooking(Response<dynamic> response) {
    final root = asMap(response.body);
    final candidates = <dynamic>[
      getByPath(root, 'data'),
      getByPath(root, 'booking'),
      root,
    ];

    for (final candidate in candidates) {
      if (candidate is Map) {
        final bookingMap = stringKeyMap(candidate);
        if (_looksLikeBooking(bookingMap)) {
          final booking = BookingModel.fromJson(bookingMap);
          if (booking.id.trim().isNotEmpty) {
            return booking;
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _dataMap(Response<dynamic> response) {
    final root = asMap(response.body);
    final data = getByPath(root, 'data');
    if (data is Map) {
      return stringKeyMap(data);
    }
    return <String, dynamic>{};
  }

  bool _looksLikeBooking(Map<String, dynamic> map) {
    return map.containsKey('_id') ||
        map.containsKey('id') ||
        map.containsKey('status') ||
        map.containsKey('startDate') ||
        map.containsKey('endDate');
  }
}
