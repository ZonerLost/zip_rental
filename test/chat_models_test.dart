import 'package:flutter_test/flutter_test.dart';
import 'package:zip_peer/models/chat/chat_models.dart';

// Conversation payload taken directly from the "Chat Module — New Features"
// spec's GET /chats example response.
const _conversationMap = {
  '_id': '6a5768229482b0d7b6a5805e',
  'participants': [
    {
      '_id': 'renter1',
      'firstName': 'buyer',
      'lastName': 'one',
      'profilePhoto': 'https://example.com/a.png',
    },
    {'_id': 'owner1', 'firstName': 'Moiz', 'lastName': 'Rana'},
  ],
  'item': {
    '_id': 'item1',
    'title': 'Dirt Bike Duke 790',
    'photos': [],
  },
  'lastMessage': {
    'content': 'Hi, I am interested in your bike',
    'sender': '6a0b0c3879fdc48385185a68',
    'createdAt': '2026-07-18T19:00:35.078Z',
  },
  'unreadCount': {'6a5607949482b0d7b6a57f76': 1},
  'archivedBy': [],
  'createdAt': '2026-07-15T10:59:46.090Z',
  'updatedAt': '2026-07-18T19:00:35.571Z',
};

void main() {
  group('ChatConversation.fromMap (spec example)', () {
    final conv = ChatConversation.fromMap(_conversationMap, '');

    test('parses id, participants, item', () {
      expect(conv.id, '6a5768229482b0d7b6a5805e');
      expect(conv.participants, hasLength(2));
      expect(conv.itemTitle, 'Dirt Bike Duke 790');
    });

    test('unreadCount is a per-user map, not a flat number', () {
      // This is the exact shape the API returns — a map keyed by user ID.
      // Parsing it as a plain int (the old behavior) would always yield 0.
      expect(conv.unreadCountFor('6a5607949482b0d7b6a57f76'), 1);
      expect(conv.unreadCountFor('someone-else'), 0);
    });

    test('archivedBy defaults to not-archived for everyone', () {
      expect(conv.archivedBy, isEmpty);
      expect(conv.isArchivedFor('renter1'), isFalse);
      expect(conv.isArchivedFor('owner1'), isFalse);
    });

    test('otherParticipant resolves relative to the current user', () {
      expect(conv.otherParticipant('renter1')?.id, 'owner1');
      expect(conv.otherParticipant('owner1')?.id, 'renter1');
    });
  });

  group('ChatConversation archivedBy parsing', () {
    test('reflects a conversation archived by one participant', () {
      final map = {
        ..._conversationMap,
        'archivedBy': ['renter1'],
      };
      final conv = ChatConversation.fromMap(map, '');
      expect(conv.isArchivedFor('renter1'), isTrue);
      // Archiving is one-sided — the other participant is unaffected.
      expect(conv.isArchivedFor('owner1'), isFalse);
    });
  });

  group('BlockedUser.fromMap', () {
    test('parses a blocked-users list entry', () {
      final user = BlockedUser.fromMap({
        '_id': '6a5607949482b0d7b6a57f76',
        'firstName': 'John',
        'lastName': 'Doe',
        'profilePhoto': 'https://example.com/john.png',
      });
      expect(user.id, '6a5607949482b0d7b6a57f76');
      expect(user.fullName, 'John Doe');
      expect(user.profilePhoto, 'https://example.com/john.png');
    });
  });

  group('ReportReasons', () {
    test('all 6 valid API reason values are present with labels', () {
      expect(ReportReasons.all, hasLength(6));
      for (final reason in ReportReasons.all) {
        expect(ReportReasons.labels[reason], isNotNull);
      }
      expect(ReportReasons.all, contains('spam'));
      expect(ReportReasons.all, contains('fake_profile'));
      expect(ReportReasons.all, contains('harassment'));
      expect(ReportReasons.all, contains('inappropriate_content'));
      expect(ReportReasons.all, contains('scam'));
      expect(ReportReasons.all, contains('other'));
    });
  });
}
