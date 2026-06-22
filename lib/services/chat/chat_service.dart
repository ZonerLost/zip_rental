import 'package:zip_peer/models/chat/chat_models.dart';
import 'package:zip_peer/services/base/api_service_base.dart';

class ChatService extends ApiServiceBase {
  ChatService({super.authService});

  // ── Start or retrieve an existing conversation ────────────────────────────
  Future<StartConversationResult> startConversation({
    required String otherUserId,
    required String message,
    String? itemId,
  }) async {
    final body = <String, dynamic>{
      'participantId': otherUserId,
      'message': message,
      if (itemId != null && itemId.isNotEmpty) 'itemId': itemId,
    };

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/chats/',
      requiresAuth: true,
      body: body,
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);

    if (!ok) return StartConversationResult(success: false, message: msg);

    final map = asMap(response.body);
    final data = map['data'] ?? map['conversation'] ?? map;
    if (data is Map) {
      final conv = data['conversation'] ?? data;
      if (conv is Map) {
        final convo = ChatConversation.fromMap(
          Map<String, dynamic>.from(conv),
          '',
        );
        return StartConversationResult(
          success: true,
          message: msg,
          conversationId: convo.id,
          conversation: convo,
        );
      }
      // API may return just the id
      final id = data['conversationId']?.toString() ??
          data['_id']?.toString() ??
          data['id']?.toString();
      return StartConversationResult(
        success: true,
        message: msg,
        conversationId: id,
      );
    }
    return StartConversationResult(success: true, message: msg);
  }

  // ── Fetch conversations list ──────────────────────────────────────────────
  Future<ConversationsResult> getConversations() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/chats',
      requiresAuth: true,
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);

    if (!ok) return ConversationsResult(success: false, message: msg);

    final map = asMap(response.body);
    final raw = map['data'] ?? map;
    List<dynamic>? list;

    if (raw is Map) {
      list = raw['conversations'] as List<dynamic>? ??
          raw['data'] as List<dynamic>?;
    } else if (raw is List) {
      list = raw;
    }

    if (list == null) {
      return ConversationsResult(success: true, message: msg);
    }

    final conversations = list
        .whereType<Map>()
        .map((m) => ChatConversation.fromMap(
              Map<String, dynamic>.from(m),
              '',
            ))
        .toList();

    return ConversationsResult(
      success: true,
      message: msg,
      conversations: conversations,
    );
  }

  // ── Fetch messages for a conversation ────────────────────────────────────
  Future<MessagesResult> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/chats/$conversationId/messages',
      requiresAuth: true,
      query: {'page': '$page', 'limit': '$limit'},
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);

    if (!ok) return MessagesResult(success: false, message: msg);

    final map = asMap(response.body);
    final raw = map['data'] ?? map;
    List<dynamic>? list;

    if (raw is Map) {
      list = raw['messages'] as List<dynamic>? ??
          raw['data'] as List<dynamic>?;
    } else if (raw is List) {
      list = raw;
    }

    if (list == null) {
      return MessagesResult(success: true, message: msg);
    }

    final messages = list
        .whereType<Map>()
        .map((m) => ChatMessage.fromMap(
              Map<String, dynamic>.from(m),
              conversationId,
            ))
        .toList();

    // API returns newest-first; reverse so oldest is first for the UI
    return MessagesResult(
      success: true,
      message: msg,
      messages: messages.reversed.toList(),
    );
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<SendMessageResult> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/chats/$conversationId/messages',
      requiresAuth: true,
      body: {'content': content},
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);

    if (!ok) return SendMessageResult(success: false, message: msg);

    final map = asMap(response.body);
    final raw = map['data'] ?? map['message'] ?? map;
    if (raw is Map) {
      final msgMap = raw['message'] ?? raw;
      if (msgMap is Map) {
        final chatMsg = ChatMessage.fromMap(
          Map<String, dynamic>.from(msgMap),
          conversationId,
        );
        return SendMessageResult(
          success: true,
          message: msg,
          chatMessage: chatMsg,
        );
      }
    }

    return SendMessageResult(success: true, message: msg);
  }

  // ── Mark conversation as read ─────────────────────────────────────────────
  Future<bool> markAsRead(String conversationId) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/chats/$conversationId/read',
      requiresAuth: true,
    );
    return resolveSuccess(response);
  }

  // ── Delete a message ──────────────────────────────────────────────────────
  Future<bool> deleteMessage({
    required String conversationId,
    required String messageId,
  }) async {
    final response = await request(
      method: ApiHttpMethod.delete,
      path: '/chats/$conversationId/messages/$messageId',
      requiresAuth: true,
    );
    return resolveSuccess(response);
  }
}
