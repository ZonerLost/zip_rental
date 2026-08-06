import 'package:zip_peer/models/bookings/booking_models.dart';
import 'package:zip_peer/models/items/item_models.dart';

class DashboardItemsStats {
  const DashboardItemsStats({this.total = 0, this.available = 0});

  final int total;
  final int available;

  factory DashboardItemsStats.fromJson(Map<String, dynamic> json) {
    return DashboardItemsStats(
      total: _asInt(json['total']),
      available: _asInt(json['available']),
    );
  }
}

/// Shared shape for both `rentals` (items I rented from others) and
/// `lending` (items I rented out to others).
class DashboardActivityStats {
  const DashboardActivityStats({
    this.total = 0,
    this.active = 0,
    this.completed = 0,
    this.pending = 0,
  });

  final int total;
  final int active;
  final int completed;
  final int pending;

  factory DashboardActivityStats.fromJson(Map<String, dynamic> json) {
    return DashboardActivityStats(
      total: _asInt(json['total']),
      active: _asInt(json['active']),
      completed: _asInt(json['completed']),
      pending: _asInt(json['pending']),
    );
  }
}

class DashboardEarningsStats {
  const DashboardEarningsStats({
    this.total = 0,
    this.currency = 'CAD',
    this.totalTransactions = 0,
  });

  final double total;
  final String currency;
  final int totalTransactions;

  factory DashboardEarningsStats.fromJson(Map<String, dynamic> json) {
    return DashboardEarningsStats(
      total: _asDouble(json['total']),
      currency: _asString(json['currency']) ?? 'CAD',
      totalTransactions: _asInt(json['totalTransactions']),
    );
  }
}

class DashboardEcoStats {
  const DashboardEcoStats({
    this.totalCO2Saved = 0,
    this.totalKmEquivalent = 0,
    this.totalRentals = 0,
    this.equivalence,
  });

  final double totalCO2Saved;
  final double totalKmEquivalent;
  final int totalRentals;
  final String? equivalence;

  factory DashboardEcoStats.fromJson(Map<String, dynamic> json) {
    return DashboardEcoStats(
      totalCO2Saved: _asDouble(json['totalCO2Saved']),
      totalKmEquivalent: _asDouble(json['totalKmEquivalent']),
      totalRentals: _asInt(json['totalRentals']),
      equivalence: _asString(json['equivalence']),
    );
  }
}

class DashboardRatingStats {
  const DashboardRatingStats({this.average = 0, this.total = 0});

  final double average;
  final int total;

  factory DashboardRatingStats.fromJson(Map<String, dynamic> json) {
    return DashboardRatingStats(
      average: _asDouble(json['average']),
      total: _asInt(json['total']),
    );
  }
}

class DashboardStats {
  const DashboardStats({
    this.items = const DashboardItemsStats(),
    this.rentals = const DashboardActivityStats(),
    this.lending = const DashboardActivityStats(),
    this.earnings = const DashboardEarningsStats(),
    this.eco = const DashboardEcoStats(),
    this.rating = const DashboardRatingStats(),
    this.recentBookings = const <BookingModel>[],
    this.recentListings = const <ItemModel>[],
  });

  final DashboardItemsStats items;
  final DashboardActivityStats rentals;
  final DashboardActivityStats lending;
  final DashboardEarningsStats earnings;
  final DashboardEcoStats eco;
  final DashboardRatingStats rating;
  final List<BookingModel> recentBookings;
  final List<ItemModel> recentListings;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> section(String key) {
      final raw = json[key];
      return raw is Map ? Map<String, dynamic>.from(raw) : const {};
    }

    final recentBookingsRaw = json['recentBookings'];
    final recentBookings = recentBookingsRaw is List
        ? recentBookingsRaw
              .whereType<Map>()
              .map((m) => BookingModel.fromJson(Map<String, dynamic>.from(m)))
              .where((b) => b.id.trim().isNotEmpty)
              .toList(growable: false)
        : const <BookingModel>[];

    final recentListingsRaw = json['recentListings'];
    final recentListings = recentListingsRaw is List
        ? recentListingsRaw
              .whereType<Map>()
              .map((m) => ItemModel.fromJson(Map<String, dynamic>.from(m)))
              .where((i) => i.id.trim().isNotEmpty)
              .toList(growable: false)
        : const <ItemModel>[];

    return DashboardStats(
      items: DashboardItemsStats.fromJson(section('items')),
      rentals: DashboardActivityStats.fromJson(section('rentals')),
      lending: DashboardActivityStats.fromJson(section('lending')),
      earnings: DashboardEarningsStats.fromJson(section('earnings')),
      eco: DashboardEcoStats.fromJson(section('eco')),
      rating: DashboardRatingStats.fromJson(section('rating')),
      recentBookings: recentBookings,
      recentListings: recentListings,
    );
  }
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  if (normalized.isEmpty || normalized.toLowerCase() == 'null') return null;
  return normalized;
}
