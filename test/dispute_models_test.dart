import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/disputes/dispute_models.dart';

// Real payloads captured live against production on 2026-09-29 while
// integrating the disputes API end to end — `POST /disputes`,
// `GET /disputes/my`, and `GET /disputes/:id` each send `booking`,
// `reportedBy` and `reportedAgainst` in a different shape.
const _createResponseJson = {
  'booking': '6abb8c2b5fad339ccdfa58c2',
  'reportedBy': '6ab0bfc5a71e40aeb370f177',
  'reportedAgainst': '6ab61352bcde82db5bf416a5',
  'reason': 'item_damaged',
  'description': 'The drill chuck was cracked when it came back.',
  'evidence': [],
  'status': 'open',
  '_id': '6abb96375fad339ccdfa5a2e',
  'createdAt': '2026-09-29T10:43:03.770Z',
  'updatedAt': '2026-09-29T10:43:03.770Z',
  '__v': 0,
};

const _myDisputesEntryJson = {
  '_id': '6abb96375fad339ccdfa5a2e',
  'booking': {
    '_id': '6abb8c2b5fad339ccdfa58c2',
    'startDate': '2026-10-25T09:00:00.000Z',
    'endDate': '2026-10-26T09:00:00.000Z',
    'status': 'completed',
  },
  'reportedBy': '6ab0bfc5a71e40aeb370f177',
  'reportedAgainst': {
    '_id': '6ab61352bcde82db5bf416a5',
    'firstName': 'Zain',
    'lastName': 'Hassan2',
    'profilePhoto': 'https://example.com/photo.jpg',
  },
  'reason': 'item_damaged',
  'description': 'The drill chuck was cracked when it came back.',
  'evidence': [],
  'status': 'open',
  'createdAt': '2026-09-29T10:43:03.770Z',
  'updatedAt': '2026-09-29T10:43:03.770Z',
  '__v': 0,
};

const _detailJson = {
  '_id': '6abb96375fad339ccdfa5a2e',
  'booking': {
    '_id': '6abb8c2b5fad339ccdfa58c2',
    'item': '6ab0c0ada71e40aeb370f1a6',
    'startDate': '2026-10-25T09:00:00.000Z',
    'endDate': '2026-10-26T09:00:00.000Z',
    'status': 'completed',
  },
  'reportedBy': {
    '_id': '6ab0bfc5a71e40aeb370f177',
    'firstName': 'Zain',
    'lastName': 'Hassan',
    'profilePhoto': 'https://example.com/photo2.jpg',
  },
  'reportedAgainst': {
    '_id': '6ab61352bcde82db5bf416a5',
    'firstName': 'Zain',
    'lastName': 'Hassan2',
    'profilePhoto': 'https://example.com/photo.jpg',
  },
  'reason': 'item_damaged',
  'description': 'The drill chuck was cracked when it came back.',
  'evidence': [
    'https://zonerlost-media.s3.us-east-1.amazonaws.com/disputes/6abb96375fad339ccdfa5a2e/evidence/17b62142-9ab0-41a0-ba90-5f3901fca702-1790678634148',
  ],
  'status': 'closed',
  'createdAt': '2026-09-29T10:43:03.770Z',
  'updatedAt': '2026-09-29T10:44:02.790Z',
  '__v': 0,
};

void main() {
  group('DisputeModel.fromJson (real production data, 2026-09-29)', () {
    test('POST /disputes sends booking/reportedBy/reportedAgainst as bare id strings', () {
      final dispute = DisputeModel.fromJson(_createResponseJson);
      expect(dispute.id, '6abb96375fad339ccdfa5a2e');
      expect(dispute.bookingId, '6abb8c2b5fad339ccdfa58c2');
      expect(dispute.reportedBy?.id, '6ab0bfc5a71e40aeb370f177');
      expect(dispute.reportedAgainst?.id, '6ab61352bcde82db5bf416a5');
      expect(dispute.reason, 'item_damaged');
      expect(dispute.status, 'open');
      expect(dispute.isOpen, isTrue);
      expect(dispute.evidence, isEmpty);
    });

    test('GET /disputes/my populates booking + reportedAgainst but keeps reportedBy bare', () {
      final dispute = DisputeModel.fromJson(_myDisputesEntryJson);
      expect(dispute.booking?.startDate, DateTime.parse('2026-10-25T09:00:00.000Z'));
      expect(dispute.booking?.status, 'completed');
      expect(dispute.reportedBy?.id, '6ab0bfc5a71e40aeb370f177');
      expect(dispute.reportedBy?.fullName, 'Zip Rental user');
      expect(dispute.reportedAgainst?.fullName, 'Zain Hassan2');
    });

    test('GET /disputes/:id populates reportedBy/reportedAgainst and booking.item', () {
      final dispute = DisputeModel.fromJson(_detailJson);
      expect(dispute.reportedBy?.fullName, 'Zain Hassan');
      expect(dispute.reportedAgainst?.fullName, 'Zain Hassan2');
      expect(dispute.booking?.itemId, '6ab0c0ada71e40aeb370f1a6');
      expect(dispute.evidence, hasLength(1));
      expect(dispute.status, 'closed');
      expect(dispute.isOpen, isFalse);
    });

    test('all seven DisputeReasons values are confirmed real via a live validation error', () {
      // POST /disputes with a bogus reason returned: "\"reason\" must be one
      // of [item_damaged, item_not_returned, item_not_as_described,
      // late_return, no_show, payment_issue, other]" — not a guess.
      expect(DisputeReasons.all, containsAll([
        DisputeReasons.itemDamaged,
        DisputeReasons.itemNotReturned,
        DisputeReasons.itemNotAsDescribed,
        DisputeReasons.lateReturn,
        DisputeReasons.noShow,
        DisputeReasons.paymentIssue,
        DisputeReasons.other,
      ]));
      expect(DisputeReasons.all, hasLength(7));
    });

    test('labelFor produces a friendly label for every known reason', () {
      expect(DisputeReasons.labelFor(DisputeReasons.itemNotAsDescribed), 'Item Not As Described');
      expect(DisputeReasons.labelFor('unknown_reason'), 'Other');
    });
  });

  group('CreateDisputeRequestModel', () {
    test('toJson matches the confirmed POST /disputes body exactly', () {
      const request = CreateDisputeRequestModel(
        bookingId: 'b1',
        reason: DisputeReasons.lateReturn,
        description: 'Returned two hours late.',
      );
      expect(request.toJson(), {
        'bookingId': 'b1',
        'reason': 'late_return',
        'description': 'Returned two hours late.',
      });
    });
  });
}
