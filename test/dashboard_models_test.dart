import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/profile/dashboard_models.dart';

// Exact example response from the Module 10 — Dashboard spec.
const _dashboardJson = {
  'items': {'total': 5, 'available': 3},
  'rentals': {'total': 12, 'active': 2, 'completed': 8, 'pending': 2},
  'lending': {'total': 20, 'active': 3, 'completed': 15, 'pending': 2},
  'earnings': {'total': 1250.00, 'currency': 'CAD', 'totalTransactions': 15},
  'eco': {
    'totalCO2Saved': 127.5,
    'totalKmEquivalent': 606.9,
    'totalRentals': 5,
    'equivalence': '606.9 km by car',
  },
  'rating': {'average': 4.8, 'total': 20},
  'recentBookings': [],
  'recentListings': [],
};

void main() {
  group('DashboardStats.fromJson (spec example)', () {
    final stats = DashboardStats.fromJson(_dashboardJson);

    test('items', () {
      expect(stats.items.total, 5);
      expect(stats.items.available, 3);
    });

    test('rentals (items I rented from others)', () {
      expect(stats.rentals.total, 12);
      expect(stats.rentals.active, 2);
      expect(stats.rentals.completed, 8);
      expect(stats.rentals.pending, 2);
    });

    test('lending (items I rented out)', () {
      expect(stats.lending.total, 20);
      expect(stats.lending.active, 3);
      expect(stats.lending.completed, 15);
      expect(stats.lending.pending, 2);
    });

    test('earnings', () {
      expect(stats.earnings.total, 1250.00);
      expect(stats.earnings.currency, 'CAD');
      expect(stats.earnings.totalTransactions, 15);
    });

    test('eco', () {
      expect(stats.eco.totalCO2Saved, 127.5);
      expect(stats.eco.totalKmEquivalent, 606.9);
      expect(stats.eco.totalRentals, 5);
      expect(stats.eco.equivalence, '606.9 km by car');
    });

    test('rating', () {
      expect(stats.rating.average, 4.8);
      expect(stats.rating.total, 20);
    });

    test('recentBookings / recentListings default to empty, not crash', () {
      expect(stats.recentBookings, isEmpty);
      expect(stats.recentListings, isEmpty);
    });
  });

  group('DashboardStats.fromJson defensive parsing', () {
    test('missing sections fall back to zeroed defaults instead of throwing', () {
      final stats = DashboardStats.fromJson(const {});
      expect(stats.items.total, 0);
      expect(stats.rentals.total, 0);
      expect(stats.earnings.currency, 'CAD');
      expect(stats.rating.average, 0);
      expect(stats.recentBookings, isEmpty);
      expect(stats.recentListings, isEmpty);
    });

    test('recentBookings items missing an id are filtered out', () {
      final stats = DashboardStats.fromJson({
        'recentBookings': [
          {'status': 'completed'}, // no _id/id — should be dropped
          {'_id': 'b1', 'status': 'completed'},
        ],
      });
      expect(stats.recentBookings, hasLength(1));
      expect(stats.recentBookings.single.id, 'b1');
    });
  });
}
