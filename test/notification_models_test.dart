import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/notifications/notification_models.dart';

void main() {
  group('NotificationTypes', () {
    test('all 10 documented types are present and distinct', () {
      final all = <String>{
        NotificationTypes.bookingRequest,
        NotificationTypes.bookingAccepted,
        NotificationTypes.bookingDeclined,
        NotificationTypes.bookingCancelled,
        NotificationTypes.bookingCompleted,
        NotificationTypes.reviewReceived,
        NotificationTypes.messageReceived,
        NotificationTypes.disputeOpened,
        NotificationTypes.disputeResolved,
        NotificationTypes.paymentReceived,
      };
      expect(all, hasLength(10));
    });
  });

  group('NotificationItem.fromJson', () {
    test('parses a typical booking_request notification', () {
      final item = NotificationItem.fromJson({
        '_id': '65f1a2b3c4d5e6f7a8b9c0d1',
        'type': 'booking_request',
        'title': 'New booking request',
        'message': 'Jane Smith wants to rent your camera',
        'isRead': false,
        'createdAt': '2026-08-01T10:00:00.000Z',
      });

      expect(item.id, '65f1a2b3c4d5e6f7a8b9c0d1');
      expect(item.type, NotificationTypes.bookingRequest);
      expect(item.title, 'New booking request');
      expect(item.isRead, isFalse);
      expect(item.createdAt, DateTime.parse('2026-08-01T10:00:00.000Z'));
    });

    test('falls back to a title derived from type when title is missing', () {
      final item = NotificationItem.fromJson({
        '_id': 'abc123',
        'type': 'payment_received',
        'message': 'You received a payment',
        'read': true,
      });

      expect(item.title, 'Payment received');
      expect(item.isRead, isTrue);
    });

    test('tolerates alternate key names (id/read/body)', () {
      final item = NotificationItem.fromJson({
        'id': 'xyz789',
        'notificationType': 'dispute_opened',
        'body': 'A dispute was opened on your booking',
        'read': 'false',
      });

      expect(item.id, 'xyz789');
      expect(item.type, NotificationTypes.disputeOpened);
      expect(item.message, 'A dispute was opened on your booking');
      expect(item.isRead, isFalse);
    });

    test('missing id yields an empty string (filtered out by caller)', () {
      final item = NotificationItem.fromJson({'type': 'message_received'});
      expect(item.id, isEmpty);
    });
  });
}
