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
    required this.content,
    this.status = 'sent',
    this.isDeleted = false,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderPhoto;
  final String content;
  final String status; // sent | delivered | read
  final bool isDeleted;
  final DateTime createdAt;

  bool get isRead => status == 'read';

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

    return ChatMessage(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? '',
      conversationId: m['conversationId']?.toString() ?? conversationId,
      senderId: senderId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      content: m['content']?.toString() ?? '',
      status: m['status']?.toString() ?? 'sent',
      isDeleted: m['isDeleted'] == true,
      createdAt: _parseDate(m['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString()) ?? DateTime.now();
  }
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
    this.unreadCount = 0,
    required this.updatedAt,
    this.isArchived = false,
  });

  final String id;
  final List<ChatParticipant> participants;
  final String? itemId;
  final String? itemTitle;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final bool isArchived;

  ChatConversation copyWith({
    int? unreadCount,
    DateTime? updatedAt,
    ChatMessage? lastMessage,
    bool? isArchived,
  }) {
    return ChatConversation(
      id: id,
      participants: participants,
      itemId: itemId,
      itemTitle: itemTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
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

  factory ChatConversation.fromMap(Map<String, dynamic> m, String conversationId) {
    final rawParticipants = m['participants'];
    final participants = <ChatParticipant>[];
    if (rawParticipants is List) {
      for (final p in rawParticipants) {
        if (p is Map) {
          participants.add(ChatParticipant.fromMap(Map<String, dynamic>.from(p)));
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

    return ChatConversation(
      id: m['_id']?.toString() ?? m['id']?.toString() ?? conversationId,
      participants: participants,
      itemId: itemId,
      itemTitle: itemTitle,
      lastMessage: lastMessage,
      unreadCount: m['unreadCount'] is num
          ? (m['unreadCount'] as num).toInt()
          : 0,
      updatedAt: ChatMessage._parseDate(m['updatedAt'] ?? m['createdAt']),
      isArchived: m['isArchived'] == true,
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
