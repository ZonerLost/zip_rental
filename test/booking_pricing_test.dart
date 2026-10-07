import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/bookings/booking_models.dart';

// Exact response taken from the 2026-09-29 pricing rewrite doc
// (`pricing-atussa-fee-commission.md`) — a $100/1-day rental, no delivery.
const _quoteJson = {
  'totalDays': 1,
  'deliveryFee': 0,
  'atussaFeeExplainer':
      'The Atussa Fee is 3% of the rental amount, with a minimum fee of '
          r'$3.99 per transaction, plus applicable taxes.',
  'pricing': {
    'currency': 'CAD',
    'rentalAmount': 100,
    'deliveryFee': 0,
    'subtotal': 100,
    'serviceFee': 3.99,
    'securityDeposit': 0,
    'totalAmount': 104.59,
    'taxTotal': 2.85,
    'taxes': [
      {
        'code': 'TPS',
        'label': 'TPS (GST)',
        'rate': 0.05,
        'amount': 0.20,
        'appliedTo': 'atussa_fee',
      },
      {
        'code': 'TVQ',
        'label': 'TVQ (QST)',
        'rate': 0.09975,
        'amount': 0.40,
        'appliedTo': 'atussa_fee',
      },
      {
        'code': 'TPS',
        'label': 'TPS (GST)',
        'rate': 0.05,
        'amount': 0.75,
        'appliedTo': 'owner_commission',
      },
      {
        'code': 'TVQ',
        'label': 'TVQ (QST)',
        'rate': 0.09975,
        'amount': 1.50,
        'appliedTo': 'owner_commission',
      },
    ],
    'renterFee': {
      'percent': 3,
      'minimum': 3.99,
      'amount': 3.99,
      'taxTotal': 0.60,
      'minimumApplied': true,
    },
    'ownerPayout': {
      'commissionPercent': 15,
      'commission': 15,
      'commissionTaxTotal': 2.25,
      'amount': 82.75,
    },
    'platform': {'revenue': 18.99, 'taxCollected': 2.85},
  },
};

void main() {
  _paymentStateTests();
  group('QuoteResponseModel / BookingPricingModel (2026-09-29 pricing rewrite)', () {
    final quote = QuoteResponseModel.fromJson(_quoteJson);
    final pricing = quote.pricing!;

    test('atussaFeeExplainer is surfaced for the tooltip', () {
      expect(quote.atussaFeeExplainer, contains('3% of the rental amount'));
    });

    test('renterFee carries the fee breakdown', () {
      expect(pricing.renterFee?.amount, 3.99);
      expect(pricing.renterFee?.minimumApplied, isTrue);
      expect(pricing.renterFee?.taxTotal, 0.60);
    });

    test('feeAmount prefers renterFee.amount', () {
      expect(pricing.feeAmount, 3.99);
    });

    test('renterTaxes filters out owner_commission lines', () {
      final renterTaxes = pricing.renterTaxes;
      expect(renterTaxes, hasLength(2));
      expect(renterTaxes.map((t) => t.code), containsAll(['TPS', 'TVQ']));
      expect(
        renterTaxes.fold<double>(0, (sum, t) => sum + (t.amount ?? 0)),
        closeTo(0.60, 0.001),
      );
    });

    test('ownerPayout is the honest take-home figure', () {
      expect(pricing.ownerPayout?.amount, 82.75);
      expect(pricing.ownerPayout?.commission, 15);
    });

    test('securityDeposit is always 0 under the new model', () {
      expect(pricing.securityDeposit, 0);
    });

    test('totalAmount already includes taxes', () {
      expect(pricing.totalAmount, 104.59);
    });

    test('feeAmount falls back to the old flat serviceFee when renterFee is absent', () {
      // Pre-2026-09-29 bookings never had `renterFee` at all.
      final legacy = BookingPricingModel.fromJson({
        'serviceFee': 5.0,
        'securityDeposit': 100.0,
        'totalAmount': 130.0,
      });
      expect(legacy.renterFee, isNull);
      expect(legacy.feeAmount, 5.0);
      expect(legacy.renterTaxes, isEmpty);
    });
  });
}

// ── payment state ─────────────────────────────────────────────────────────────────────────────────
// booking.paymentStatus exists because `status` says nothing about money: a paid booking and an
// unpaid one are both `accepted`. Keying Pay Now off `status` alone kept the button on screen after
// a successful charge, so the renter saw "Payment Successful" and then the same button.
void _paymentStateTests() {
  BookingModel booking({String? status, String? paymentStatus}) =>
      BookingModel.fromJson(<String, dynamic>{
        '_id': '65f1a2b3c4d5e6f7a8b9c0d1',
        'status': status,
        'paymentStatus': paymentStatus,
      });

  group('BookingModel payment state', () {
    test('accepted and unpaid is awaiting payment', () {
      final b = booking(status: 'accepted', paymentStatus: 'unpaid');
      expect(b.isPaid, isFalse);
      expect(b.awaitingPayment, isTrue);
    });

    test('accepted and paid is NOT awaiting payment', () {
      final b = booking(status: 'accepted', paymentStatus: 'paid');
      expect(b.isPaid, isTrue);
      expect(b.awaitingPayment, isFalse);
    });

    test('a failed attempt leaves Pay Now available', () {
      final b = booking(status: 'accepted', paymentStatus: 'failed');
      expect(b.isPaid, isFalse);
      expect(b.awaitingPayment, isTrue);
    });

    test('a refund makes a live booking payable again', () {
      final b = booking(status: 'accepted', paymentStatus: 'refunded');
      expect(b.isPaid, isFalse);
      expect(b.awaitingPayment, isTrue);
    });

    test('a missing paymentStatus reads as unpaid, not paid', () {
      // Every booking created before the server grew the field. Unpaid is the safe direction: the
      // worst case is offering Pay Now on a paid booking, which the server refuses with a 409.
      // Treating null as paid would hide the button on genuinely unpaid bookings and leave an owner
      // unpaid with no way for the renter to fix it.
      final b = booking(status: 'accepted');
      expect(b.paymentStatus, isNull);
      expect(b.isPaid, isFalse);
      expect(b.awaitingPayment, isTrue);
    });

    test('payment state never makes a pending booking payable', () {
      expect(booking(status: 'pending', paymentStatus: 'unpaid').awaitingPayment, isFalse);
      expect(booking(status: 'completed', paymentStatus: 'unpaid').awaitingPayment, isFalse);
      expect(booking(status: 'cancelled', paymentStatus: 'unpaid').awaitingPayment, isFalse);
    });
  });
}
