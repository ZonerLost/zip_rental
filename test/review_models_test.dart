import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/reviews/review_models.dart';

// Real entries captured live from GET /reviews/admin/all on 2026-09-29 —
// confirms `booking` is a populated object ({_id, startDate, endDate}), not
// a bare id string, and that `reviewee` is absent on renter_to_item reviews.
const _ownerToRenterJson = {
  '_id': '6a4636c807b67b38132c83c5',
  'booking': {
    '_id': '6a46364f07b67b38132c834a',
    'startDate': '2026-08-01T00:00:00.000Z',
    'endDate': '2026-08-04T00:00:00.000Z',
  },
  'reviewer': {'_id': '6a4635f907b67b38132c8334', 'firstName': 'Landlord', 'lastName': 'Nine'},
  'reviewee': {'_id': '6a46342e07b67b38132c831c', 'firstName': 'Renter', 'lastName': 'Tester'},
  'item': {'_id': '6a46363907b67b38132c8345', 'title': 'Test Drill For API Verification', 'photos': []},
  'type': 'owner_to_renter',
  'rating': 5,
  'comment': 'Excellent renter, returned item in great condition.',
  'createdAt': '2026-07-02T10:00:40.650Z',
  'updatedAt': '2026-07-02T10:00:40.650Z',
  '__v': 0,
};

const _renterToItemJson = {
  '_id': '6a4636c707b67b38132c83bc',
  'booking': {
    '_id': '6a46364f07b67b38132c834a',
    'startDate': '2026-08-01T00:00:00.000Z',
    'endDate': '2026-08-04T00:00:00.000Z',
  },
  'reviewer': {'_id': '6a46342e07b67b38132c831c', 'firstName': 'Renter', 'lastName': 'Tester'},
  // No `reviewee` key at all — confirmed real shape for this type.
  'item': {'_id': '6a46363907b67b38132c8345', 'title': 'Test Drill For API Verification', 'photos': []},
  'type': 'renter_to_item',
  'rating': 4,
  'comment': 'Item worked well, minor wear and tear.',
  'createdAt': '2026-07-02T10:00:39.116Z',
  'updatedAt': '2026-07-02T10:00:39.116Z',
  '__v': 0,
};

void main() {
  group('ReviewModel.fromJson (real production data, 2026-09-29)', () {
    test('parses booking as a populated object, not a bare id', () {
      final review = ReviewModel.fromJson(_ownerToRenterJson);
      expect(review.bookingId, '6a46364f07b67b38132c834a');
      expect(review.booking?.startDate, DateTime.parse('2026-08-01T00:00:00.000Z'));
      expect(review.booking?.endDate, DateTime.parse('2026-08-04T00:00:00.000Z'));
    });

    test('reviewer/reviewee/item parse correctly for owner_to_renter', () {
      final review = ReviewModel.fromJson(_ownerToRenterJson);
      expect(review.reviewer?.fullName, 'Landlord Nine');
      expect(review.reviewee?.fullName, 'Renter Tester');
      expect(review.revieweeId, '6a46342e07b67b38132c831c');
      expect(review.item?.title, 'Test Drill For API Verification');
      expect(review.type, 'owner_to_renter');
      expect(review.rating, 5);
    });

    test('reviewee is null (not a crash) for renter_to_item, which has no reviewee key', () {
      final review = ReviewModel.fromJson(_renterToItemJson);
      expect(review.reviewee, isNull);
      expect(review.revieweeId, isNull);
      expect(review.reviewer?.fullName, 'Renter Tester');
      expect(review.bookingId, '6a46364f07b67b38132c834a');
      expect(review.type, 'renter_to_item');
    });

    test('all three ReviewTypes values are confirmed real (seen in production data)', () {
      // renter_to_owner and owner_to_renter and renter_to_item were all
      // observed live in GET /reviews/admin/all — the enum wasn't a guess.
      expect(ReviewTypes.all, containsAll([
        ReviewTypes.renterToOwner,
        ReviewTypes.ownerToRenter,
        ReviewTypes.renterToItem,
      ]));
    });

    test('falls back gracefully when booking is unpopulated (defensive, not yet seen live)', () {
      final review = ReviewModel.fromJson({
        '_id': 'r1',
        'booking': 'plain-id-string',
        'type': 'renter_to_owner',
      });
      expect(review.bookingId, 'plain-id-string');
    });
  });

  group('ReviewModel.fromJson — bare-string reviewee/item (real, confirmed 2026-09-29)', () {
    test('GET /reviews/user/:id sends reviewee as a bare string, not an object', () {
      final review = ReviewModel.fromJson({
        '_id': 'r1',
        'booking': '6abb8c2b5fad339ccdfa58c2',
        'reviewer': {'_id': 'u1', 'firstName': 'Zain', 'lastName': 'Hassan2'},
        'reviewee': '6ab0bfc5a71e40aeb370f177',
        'item': {'_id': 'i1', 'title': 'App screenshot', 'photos': []},
        'type': 'renter_to_owner',
        'rating': 5,
      });
      expect(review.bookingId, '6abb8c2b5fad339ccdfa58c2');
      expect(review.reviewee?.id, '6ab0bfc5a71e40aeb370f177');
      expect(review.item?.title, 'App screenshot');
    });

    test('GET /reviews/item/:id sends item as a bare string, not an object', () {
      final review = ReviewModel.fromJson({
        '_id': 'r2',
        'booking': '6abb8c2b5fad339ccdfa58c2',
        'reviewer': {'_id': 'u1', 'firstName': 'Zain', 'lastName': 'Hassan2'},
        'item': '6ab0c0ada71e40aeb370f1a6',
        'type': 'renter_to_item',
        'rating': 4,
      });
      expect(review.item?.id, '6ab0c0ada71e40aeb370f1a6');
      expect(review.item?.title, isNull);
    });
  });

  group('PendingReviewModel', () {
    test('pendingTypes is growable — ReviewController.submitReview() mutates '
        'it in place with .remove(), which throws on a fixed-length list', () {
      final pending = PendingReviewModel.fromJson({
        'booking': {
          '_id': 'b1',
          'item': {'title': 'Drill', 'photos': []},
        },
        'pendingTypes': ['renter_to_owner', 'renter_to_item'],
      });
      expect(() => pending.pendingTypes.remove('renter_to_owner'), returnsNormally);
      expect(pending.pendingTypes, ['renter_to_item']);
    });
  });

  group('CreateReviewRequestModel', () {
    test('toJson matches the confirmed POST /reviews body exactly', () {
      const request = CreateReviewRequestModel(
        bookingId: 'b1',
        type: ReviewTypes.renterToOwner,
        rating: 5,
        comment: 'Great communication.',
      );
      expect(request.toJson(), {
        'bookingId': 'b1',
        'type': 'renter_to_owner',
        'rating': 5,
        'comment': 'Great communication.',
      });
    });
  });
}
