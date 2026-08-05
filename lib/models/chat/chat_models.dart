import 'dart:convert';

// ─────────────────────────────────────────────
//  Participant
// ─────────────────────────────────────────────
class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhoto;

  String get fullName => '$firstName $lastName'.trim();

  factory ChatParticipant.fromMap(Map<String, dynamic> m) {
    return ChatParticipant(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? '',
      firstName: m['firstName']?.toString() ?? '',
      lastName: m['lastName']?.toString() ?? '',
      profilePhoto: m['profilePhoto']?.toString(),
    );
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
    this.status = 'sent',
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
  final String status; // sent | delivered | read
  final bool isDeleted;
  final DateTime createdAt;

  bool get isRead => status == 'read';

  factory ChatMessage.fromRaw({
    required String id,
    required String conversationId,
    required String senderId,
    String senderName = '',
    String? senderPhoto,
    required String rawContent,
    String status = 'sent',
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
      status: status,
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
      senderPhoto = sender['profilePhoto']?.toString();
    } else {
      senderId = sender?.toString() ?? '';
    }

    return ChatMessage.fromRaw(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? '',
      conversationId: m['conversationId']?.toString() ?? conversationId,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      rawContent: m['content']?.toString() ?? '',
      status: m['status']?.toString() ?? 'sent',
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
    this.unreadCountByUser = const <String, int>{},
    required this.updatedAt,
    this.archivedBy = const <String>[],
  });

  final String id;
  final List<ChatParticipant> participants;
  final String? itemId;
  final String? itemTitle;
  final ChatMessage? lastMessage;
  /// Per-user unread counts, keyed by user ID — the API returns
  /// `unreadCount` as e.g. `{ "<userId>": 1 }`, not a single number, since
  /// each participant has their own unread count for the conversation.
  final Map<String, int> unreadCountByUser;
  final DateTime updatedAt;
  /// User IDs who have archived this conversation (per the `archivedBy`
  /// field on GET /chats). Archiving is one-sided — the other participant
  /// still sees the conversation normally.
  final List<String> archivedBy;

  int unreadCountFor(String userId) => unreadCountByUser[userId] ?? 0;

  bool isArchivedFor(String userId) => archivedBy.contains(userId);

  ChatConversation copyWith({
    Map<String, int>? unreadCountByUser,
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
      unreadCountByUser: unreadCountByUser ?? this.unreadCountByUser,
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

    final unreadRaw = m['unreadCount'];
    final unreadCountByUser = <String, int>{};
    if (unreadRaw is Map) {
      unreadRaw.forEach((key, value) {
        if (value is num) {
          unreadCountByUser[key.toString()] = value.toInt();
        }
      });
    }

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
      unreadCountByUser: unreadCountByUser,
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
      profilePhoto: m['profilePhoto']?.toString(),
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
