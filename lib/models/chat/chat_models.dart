import 'dart:convert';

import '../../utils/media_url.dart';

// ─────────────────────────────────────────────
//  Participant
// ─────────────────────────────────────────────
class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    this.isOnline = false,
    this.lastSeenAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final bool isOnline;
  final DateTime? lastSeenAt;

  String get fullName => '$firstName $lastName'.trim();

  factory ChatParticipant.fromMap(Map<String, dynamic> m) {
    return ChatParticipant(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? '',
      firstName: m['firstName']?.toString() ?? '',
      lastName: m['lastName']?.toString() ?? '',
      profilePhoto: normalizeMediaUrl(m['profilePhoto']?.toString()),
      isOnline: m['isOnline'] == true,
      lastSeenAt: ChatMessage._parseOptionalDate(m['lastSeenAt']),
    );
  }

  /// Some responses (e.g. the nested `conversation` object on `POST /chats`)
  /// list participants as bare ID strings rather than full objects — this
  /// still gives callers something to match against `otherParticipant()`,
  /// just without a name/photo/presence to show.
  factory ChatParticipant.fromId(String id) {
    return ChatParticipant(id: id, firstName: '', lastName: '');
  }
}

// ─────────────────────────────────────────────
//  Message
// ─────────────────────────────────────────────
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName = '',
    this.senderPhoto,
    required this.rawContent,
    required this.content,
    this.itemId,
    this.itemTitle,
    this.isRead = false,
    this.deliveredAt,
    this.readAt,
    this.isDeleted = false,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final String rawContent;
  final String content;
  final String? itemId;
  final String? itemTitle;
  final bool isRead;
  // Absent on the wire until the corresponding event actually happens — see
  // guide §4 ("a field that has not happened yet is absent, not null").
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isDeleted;
  final DateTime createdAt;

  /// Tick state for the UI: 'sent' (single check), 'delivered' (double
  /// check, gray), or 'read' (double check, blue). Derived from the
  /// message's own timestamps/flags — plus whatever `messages_delivered`
  /// / `messages_read` socket events have since applied via [copyWith] —
  /// rather than a server-sent enum, since the real API never sends one.
  String get status {
    if (isRead || readAt != null) return 'read';
    if (deliveredAt != null) return 'delivered';
    return 'sent';
  }

  ChatMessage copyWith({
    bool? isRead,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      rawContent: rawContent,
      content: content,
      itemId: itemId,
      itemTitle: itemTitle,
      isRead: isRead ?? this.isRead,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }

  factory ChatMessage.fromRaw({
    required String id,
    required String conversationId,
    required String senderId,
    String senderName = '',
    String? senderPhoto,
    required String rawContent,
    bool isRead = false,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool isDeleted = false,
    required DateTime createdAt,
  }) {
    final parsed = _parseContent(rawContent);
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      rawContent: rawContent,
      content: parsed.content,
      itemId: parsed.itemId,
      itemTitle: parsed.itemTitle,
      isRead: isRead,
      deliveredAt: deliveredAt,
      readAt: readAt,
      isDeleted: isDeleted,
      createdAt: createdAt,
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> m, String conversationId) {
    final sender = m['sender'];
    String senderId;
    String senderName = '';
    String? senderPhoto;

    if (sender is Map) {
      senderId = sender['_id']?.toString() ?? sender['id']?.toString() ?? '';
      final fn = sender['firstName']?.toString() ?? '';
      final ln = sender['lastName']?.toString() ?? '';
      senderName = '$fn $ln'.trim();
      senderPhoto = normalizeMediaUrl(sender['profilePhoto']?.toString());
    } else {
      senderId = sender?.toString() ?? '';
    }

    return ChatMessage.fromRaw(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? '',
      // `conversationId` is the field that works everywhere (confirmed
      // with backend — see docs/backend-chat-socket-questions.md item #1);
      // `conversation` is kept as a fallback since raw REST message objects
      // still use it, before finally falling back to whatever the caller
      // already knows.
      conversationId: m['conversationId']?.toString() ??
          m['conversation']?.toString() ??
          conversationId,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      rawContent: m['content']?.toString() ?? '',
      isRead: m['isRead'] == true,
      deliveredAt: _parseOptionalDate(m['deliveredAt']),
      readAt: _parseOptionalDate(m['readAt']),
      isDeleted: m['isDeleted'] == true,
      createdAt: _parseDate(m['createdAt']),
    );
  }

  static String encodeContentWithItemReference(
    String content, {
    String? itemId,
    String? itemTitle,
  }) {
    final trimmedContent = content.trim();
    final trimmedItemId = itemId?.trim() ?? '';
    final trimmedItemTitle = itemTitle?.trim() ?? '';

    if (trimmedItemId.isEmpty && trimmedItemTitle.isEmpty) {
      return trimmedContent;
    }

    return '$_itemReferencePrefix'
        '${jsonEncode({'itemId': trimmedItemId, 'itemTitle': trimmedItemTitle})}'
        '$_itemReferenceSuffix'
        '$trimmedContent';
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString()) ?? DateTime.now();
  }

  /// Unlike [_parseDate], stays null when [raw] is absent — used for
  /// deliveredAt/readAt, which genuinely mean "hasn't happened yet".
  static DateTime? _parseOptionalDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString());
  }

  static _ParsedMessageContent _parseContent(String rawContent) {
    if (!rawContent.startsWith(_itemReferencePrefix)) {
      return _ParsedMessageContent(content: rawContent);
    }

    final markerEnd = rawContent.indexOf(
      _itemReferenceSuffix,
      _itemReferencePrefix.length,
    );
    if (markerEnd == -1) {
      return _ParsedMessageContent(content: rawContent);
    }

    final encodedMeta = rawContent.substring(
      _itemReferencePrefix.length,
      markerEnd,
    );
    final visibleContent = rawContent
        .substring(markerEnd + _itemReferenceSuffix.length)
        .trimLeft();

    try {
      final decoded = jsonDecode(encodedMeta);
      if (decoded is Map<String, dynamic>) {
        final parsedItemId = decoded['itemId']?.toString().trim();
        final parsedItemTitle = decoded['itemTitle']?.toString().trim();
        return _ParsedMessageContent(
          content: visibleContent,
          itemId: parsedItemId?.isEmpty == true ? null : parsedItemId,
          itemTitle: parsedItemTitle?.isEmpty == true ? null : parsedItemTitle,
        );
      }
    } catch (_) {
      return _ParsedMessageContent(content: rawContent);
    }

    return _ParsedMessageContent(content: visibleContent);
  }

  static const String _itemReferencePrefix = '__ZIP_ITEM_REF__';
  static const String _itemReferenceSuffix = '__END_ZIP_ITEM_REF__';
}

// ─────────────────────────────────────────────
//  Conversation
// ─────────────────────────────────────────────
class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participants,
    this.itemId,
    this.itemTitle,
    this.lastMessage,
    this.unread = 0,
    required this.updatedAt,
    this.archivedBy = const <String>[],
  });

  final String id;
  final List<ChatParticipant> participants;
  final String? itemId;
  final String? itemTitle;
  final ChatMessage? lastMessage;
  /// The calling user's own unread count for this conversation — the API
  /// returns this directly as a top-level `unread` field (it also returns a
  /// per-user `unreadCount` map, but nothing in the app ever needs anyone
  /// else's count, so there's no reason to carry the whole map around).
  final int unread;
  final DateTime updatedAt;
  /// User IDs who have archived this conversation (per the `archivedBy`
  /// field on GET /chats). Archiving is one-sided — the other participant
  /// still sees the conversation normally.
  final List<String> archivedBy;

  bool isArchivedFor(String userId) => archivedBy.contains(userId);

  ChatConversation copyWith({
    int? unread,
    DateTime? updatedAt,
    ChatMessage? lastMessage,
    List<String>? archivedBy,
  }) {
    return ChatConversation(
      id: id,
      participants: participants,
      itemId: itemId,
      itemTitle: itemTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      unread: unread ?? this.unread,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedBy: archivedBy ?? this.archivedBy,
    );
  }

  /// Returns the participant that is NOT the current user.
  ChatParticipant? otherParticipant(String currentUserId) {
    try {
      return participants.firstWhere((p) => p.id != currentUserId);
    } catch (_) {
      return participants.isNotEmpty ? participants.first : null;
    }
  }

  factory ChatConversation.fromMap(
    Map<String, dynamic> m,
    String conversationId,
  ) {
    final rawParticipants = m['participants'];
    final participants = <ChatParticipant>[];
    if (rawParticipants is List) {
      for (final p in rawParticipants) {
        if (p is Map) {
          participants.add(
            ChatParticipant.fromMap(Map<String, dynamic>.from(p)),
          );
        } else if (p is String && p.trim().isNotEmpty) {
          // Some responses (e.g. POST /chats's nested conversation object)
          // list participants as bare ID strings instead of full objects.
          participants.add(ChatParticipant.fromId(p.trim()));
        }
      }
    }

    ChatMessage? lastMessage;
    final lm = m['lastMessage'];
    if (lm is Map) {
      lastMessage = ChatMessage.fromMap(
        Map<String, dynamic>.from(lm),
        m['_id']?.toString() ?? conversationId,
      );
    }

    final item = m['item'];
    String? itemId;
    String? itemTitle;
    if (item is Map) {
      itemId = item['_id']?.toString() ?? item['id']?.toString();
      itemTitle = item['title']?.toString();
    } else if (item is String) {
      itemId = item;
    }

    final unreadRaw = m['unread'];
    final unread = unreadRaw is num ? unreadRaw.toInt() : 0;

    final archivedByRaw = m['archivedBy'];
    final archivedBy = archivedByRaw is List
        ? archivedByRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    return ChatConversation(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? conversationId,
      participants: participants,
      itemId: itemId,
      itemTitle: itemTitle,
      lastMessage: lastMessage,
      unread: unread,
      updatedAt: ChatMessage._parseDate(m['updatedAt'] ?? m['createdAt']),
      archivedBy: archivedBy,
    );
  }
}

// ─────────────────────────────────────────────
//  Result wrappers
// ─────────────────────────────────────────────
class ConversationsResult {
  const ConversationsResult({
    required this.success,
    required this.message,
    this.conversations = const [],
  });

  final bool success;
  final String message;
  final List<ChatConversation> conversations;
}

class MessagesResult {
  const MessagesResult({
    required this.success,
    required this.message,
    this.messages = const [],
  });

  final bool success;
  final String message;
  final List<ChatMessage> messages;
}

/// `GET /chats/unread-count` — the app-wide badge summary, distinct from
/// any single conversation's own `unread` count.
class UnreadSummaryResult {
  const UnreadSummaryResult({
    required this.success,
    this.total = 0,
    this.conversations = 0,
  });

  final bool success;
  final int total;
  final int conversations;
}

class StartConversationResult {
  const StartConversationResult({
    required this.success,
    required this.message,
    this.conversationId,
    this.conversation,
  });

  final bool success;
  final String message;
  final String? conversationId;
  final ChatConversation? conversation;
}

class SendMessageResult {
  const SendMessageResult({
    required this.success,
    required this.message,
    this.chatMessage,
  });

  final bool success;
  final String message;
  final ChatMessage? chatMessage;
}

/// Generic success/message wrapper for the archive, block, unblock, and
/// report actions — none of them return a meaningful payload beyond a
/// confirmation message.
class ChatActionResult {
  const ChatActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

// ─────────────────────────────────────────────
//  Block
// ─────────────────────────────────────────────
class BlockedUser {
  const BlockedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhoto;

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isEmpty ? 'Unknown user' : combined;
  }

  factory BlockedUser.fromMap(Map<String, dynamic> m) {
    return BlockedUser(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? '',
      firstName: m['firstName']?.toString() ?? '',
      lastName: m['lastName']?.toString() ?? '',
      profilePhoto: normalizeMediaUrl(m['profilePhoto']?.toString()),
    );
  }
}

class BlockedUsersResult {
  const BlockedUsersResult({
    required this.success,
    required this.message,
    this.users = const <BlockedUser>[],
  });

  final bool success;
  final String message;
  final List<BlockedUser> users;
}

// ─────────────────────────────────────────────
//  Report
// ─────────────────────────────────────────────
/// The only `reason` values the backend accepts for POST /users/:id/report.
class ReportReasons {
  const ReportReasons._();

  static const String spam = 'spam';
  static const String fakeProfile = 'fake_profile';
  static const String harassment = 'harassment';
  static const String inappropriateContent = 'inappropriate_content';
  static const String scam = 'scam';
  static const String other = 'other';

  static const Map<String, String> labels = <String, String>{
    spam: 'Spam or unwanted promotions',
    fakeProfile: 'Fake or impersonation account',
    harassment: 'Bullying or harassment',
    inappropriateContent: 'Offensive or harmful content',
    scam: 'Fraud or scam attempt',
    other: 'Something else',
  };

  static const List<String> all = <String>[
    spam,
    fakeProfile,
    harassment,
    inappropriateContent,
    scam,
    other,
  ];
}

class _ParsedMessageContent {
  const _ParsedMessageContent({
    required this.content,
    this.itemId,
    this.itemTitle,
  });

  final String content;
  final String? itemId;
  final String? itemTitle;
}

// ─────────────────────────────────────────────
//  JWT userId extractor (no extra deps)
// ─────────────────────────────────────────────
String? extractUserIdFromJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    // base64url → base64 padding
    String payload = parts[1];
    payload = payload.replaceAll('-', '+').replaceAll('_', '/');
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64.decode(payload));
    final map = jsonDecode(decoded) as Map<String, dynamic>;
    return map['userId']?.toString() ?? map['sub']?.toString();
  } catch (_) {
    return null;
  }
}
