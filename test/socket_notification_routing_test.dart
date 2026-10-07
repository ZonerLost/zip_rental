import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/notifications/notification_models.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';

/// The server has **no** `notification` socket event — confirmed against its emit sites on
/// 2026-10-07. In-app notifications arrive as `conversation_updated` with `type: "notification"` and
/// the row nested one level down under `notification`.
///
/// This matters because every failure mode here is silent. A `.on('notification')` listener never
/// fires at all, and reading the outer map instead of the nested one yields a NotificationItem with
/// an empty id, which ChatController drops on the floor. Both look identical from the outside: no
/// notifications, no error, nothing in the logs.
void main() {
  group('conversation_updated -> notification routing', () {
    // The documented payload, exactly as the server sends it.
    final notificationEvent = <String, dynamic>{
      'type': 'notification',
      'notification': {
        '_id': '65f1a2b3c4d5e6f7a8b9c0d1',
        'type': 'booking_request',
        'title': 'New booking request',
        'message': 'Jane Smith wants to rent your camera',
        'isRead': false,
        'createdAt': '2026-08-01T10:00:00.000Z',
      },
    };

    test('extracts the nested row from a notification event', () {
      final row = ChatSocketService.notificationRowFrom(notificationEvent);

      expect(row, isNotNull);
      expect(row!['_id'], '65f1a2b3c4d5e6f7a8b9c0d1');
      expect(row['type'], 'booking_request');
    });

    test('the extracted row parses into a usable NotificationItem', () {
      // The id is what ChatController checks before forwarding, so an empty one is the bug.
      final item = NotificationItem.fromJson(
        ChatSocketService.notificationRowFrom(notificationEvent)!,
      );

      expect(item.id, isNotEmpty);
      expect(item.id, '65f1a2b3c4d5e6f7a8b9c0d1');
      expect(item.type, NotificationTypes.bookingRequest);
      expect(item.title, 'New booking request');
      expect(item.isRead, isFalse);
    });

    test('reading the outer event instead of the nested row loses the id', () {
      // Guards against someone "simplifying" the handler back to passing the whole event through.
      final wrong = NotificationItem.fromJson(notificationEvent);

      expect(wrong.id, isEmpty);
    });

    test('returns null when the row is missing or not a map', () {
      expect(
        ChatSocketService.notificationRowFrom({'type': 'notification'}),
        isNull,
      );
      expect(
        ChatSocketService.notificationRowFrom({'type': 'notification', 'notification': 'nope'}),
        isNull,
      );
    });
  });

  group('socket host configuration', () {
    test('is enabled by default now that a wss://-capable origin exists', () {
      // Off for weeks because App Runner rejects the upgrade and this client only speaks WebSocket
      // on native. A CloudFront distribution in front of the ALB answers 101 over TLS, so there is
      // somewhere to connect to; disabling it again is a --dart-define, not a code change.
      expect(ChatSocketService.socketEnabled, isTrue);
    });
  });
}
