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
  // The API also returns a per-user `unreadCount` map (`{ "<userId>": n }`),
  // but `unread` is the caller's own count, precomputed server-side —
  // confirmed live against the production API, where both fields are
  // present on every conversation row. The app reads `unread` directly
  // rather than resolving "who am I" and looking itself up in the map.
  'unread': 1,
  'archivedBy': [],
  'createdAt': '2026-07-15T10:59:46.090Z',
  'updatedAt': '2026-07-18T19:00:35.571Z',
};

void main() {
  group('ChatMessage.fromMap conversationId resolution', () {
    test('prefers conversationId when both fields are present', () {
      // Current production shape (backend fix, 2026-09-25): new_message
      // now carries both fields — `conversationId` is the one that works
      // on every chat event, `conversation` is kept for REST-shape
      // consistency. See docs/backend-chat-socket-questions.md item #1.
      final msg = ChatMessage.fromMap({
        '_id': 'msg1',
        'conversationId': 'conv1',
        'conversation': 'conv1',
        'sender': {'_id': 'renter1', 'firstName': 'buyer', 'lastName': 'one'},
        'content': 'hello',
        'createdAt': '2026-09-23T11:59:39.923Z',
      }, '');
      expect(msg.conversationId, 'conv1');
    });

    test('falls back to `conversation` when conversationId is absent', () {
      // Originally the *only* shape new_message sent, before the backend
      // fix above — before this fallback, ChatSocketService always
      // resolved this to '', so every real-time incoming message was
      // silently dropped by ChatMessagesController's conversationId check.
      // Kept as a fallback since raw REST message objects still use
      // `conversation` only.
      final msg = ChatMessage.fromMap({
        '_id': 'msg1',
        'conversation': 'conv1',
        'sender': {'_id': 'renter1', 'firstName': 'buyer', 'lastName': 'one'},
        'content': 'hello',
        'createdAt': '2026-09-23T11:59:39.923Z',
      }, '');
      expect(msg.conversationId, 'conv1');
    });

    test('falls back to the caller-supplied id when both are absent', () {
      final msg = ChatMessage.fromMap({
        '_id': 'msg1',
        'sender': 'renter1',
        'content': 'hello',
        'createdAt': '2026-09-23T11:59:39.923Z',
      }, 'caller-known-id');
      expect(msg.conversationId, 'caller-known-id');
    });
  });

  group('ChatMessage.fromMap image fields', () {
    test('defaults to type "text" when the field is absent', () {
      // Every message sent before the image-messages feature shipped has no
      // `type` field at all — must read as text, not as some third "null"
      // state (backend's explicit instruction).
      final msg = ChatMessage.fromMap({
        '_id': 'msg1',
        'sender': 'renter1',
        'content': 'hello',
        'createdAt': '2026-09-23T11:59:39.923Z',
      }, 'conv1');
      expect(msg.type, 'text');
      expect(msg.isImage, isFalse);
      expect(msg.imageUrl, isNull);
    });

    test('parses type "image" and imageUrl', () {
      final msg = ChatMessage.fromMap({
        '_id': 'msg1',
        'sender': 'renter1',
        'type': 'image',
        'imageUrl':
            'https://zonerlost-media.s3.us-east-1.amazonaws.com/chat-photos/a.jpg',
        'content': 'optional caption',
        'createdAt': '2026-09-23T11:59:39.923Z',
      }, 'conv1');
      expect(msg.type, 'image');
      expect(msg.isImage, isTrue);
      expect(msg.imageUrl, contains('chat-photos/a.jpg'));
      expect(msg.content, 'optional caption');
    });
  });

  group('ChatConversation.fromMap (spec example)', () {
    final conv = ChatConversation.fromMap(_conversationMap, '');

    test('parses id, participants, item', () {
      expect(conv.id, '6a5768229482b0d7b6a5805e');
      expect(conv.participants, hasLength(2));
      expect(conv.itemTitle, 'Dirt Bike Duke 790');
    });

    test('unread reads the caller-specific count directly', () {
      expect(conv.unread, 1);
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

    test('participant presence (isOnline/lastSeenAt) is parsed', () {
      // Real GET /chats shape: {"isOnline":false,"_id":"...",...,"lastSeenAt":null}
      final withPresence = ChatConversation.fromMap({
        ..._conversationMap,
        'participants': [
          {
            '_id': 'renter1',
            'firstName': 'buyer',
            'lastName': 'one',
            'isOnline': true,
            'lastSeenAt': null,
          },
          {
            '_id': 'owner1',
            'firstName': 'Moiz',
            'lastName': 'Rana',
            'isOnline': false,
            'lastSeenAt': '2026-07-18T19:00:35.078Z',
          },
        ],
      }, '');
      expect(withPresence.otherParticipant('owner1')?.isOnline, isTrue);
      expect(withPresence.otherParticipant('owner1')?.lastSeenAt, isNull);
      expect(withPresence.otherParticipant('renter1')?.isOnline, isFalse);
      expect(
        withPresence.otherParticipant('renter1')?.lastSeenAt,
        DateTime.parse('2026-07-18T19:00:35.078Z'),
      );
    });
  });

  group('ChatConversation participant parsing (POST /chats response)', () {
    test('accepts participants as bare ID strings, not just objects', () {
      // Confirmed live: the nested `conversation` object on POST /chats's
      // response lists participants as raw ID strings, e.g.
      // "participants": ["6ab106ab618496e4dbb8fe1e", "6ab0bfc5a71e40aeb370f177"]
      final conv = ChatConversation.fromMap({
        '_id': 'conv1',
        'participants': ['renter1', 'owner1'],
        'unread': 0,
        'archivedBy': [],
        'updatedAt': '2026-07-18T19:00:35.571Z',
      }, '');
      expect(conv.participants, hasLength(2));
      expect(conv.participants.map((p) => p.id), containsAll(['renter1', 'owner1']));
      expect(conv.otherParticipant('renter1')?.id, 'owner1');
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
