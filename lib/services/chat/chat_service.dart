import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
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

    debugPrint(
      '[Chat] startConversation → POST /chats/ body=$body',
    );

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/chats/',
      requiresAuth: true,
      body: body,
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);
    debugPrint(
      '[Chat] startConversation ← status=${response.statusCode} '
      'success=$ok message="$msg" body=${response.body}',
    );

    if (!ok) return StartConversationResult(success: false, message: msg);

    final map = asMap(response.body);
    final id = _extractConversationId(map);
    if (id == null) {
      // Don't report success with a blank/missing ID — every subsequent
      // call (send message, mark read, ...) targets `/chats/$id/...`, and a
      // blank id there is exactly what produces the backend's generic
      // "Invalid ID format" error on the very next request.
      debugPrint(
        '[Chat] startConversation ✗ could not extract a conversation id '
        'from the response body above — check the shape the backend '
        'actually returns for POST /chats.',
      );
      return const StartConversationResult(
        success: false,
        message:
            "Couldn't read the new conversation's ID from the server response.",
      );
    }
    debugPrint('[Chat] startConversation ✓ resolved conversationId=$id');

    ChatConversation? conversation;
    final data = map['data'] ?? map['conversation'] ?? map;
    if (data is Map) {
      final conv = data['conversation'] ?? data;
      if (conv is Map) {
        conversation = ChatConversation.fromMap(
          Map<String, dynamic>.from(conv),
          id,
        );
      }
    }

    return StartConversationResult(
      success: true,
      message: msg,
      conversationId: id,
      conversation: conversation,
    );
  }

  /// Tries several known response shapes for the newly created conversation's
  /// ID — the exact nesting (`data`, `data.conversation`, `conversation`, or
  /// flat) isn't nailed down anywhere we've seen documented, so this checks
  /// all of them rather than assuming one.
  ///
  /// FOUND BUG (2026-08-05): POST /chats creates the conversation *and*
  /// sends the opening message atomically, and its response's primary
  /// `data` payload is the created **message**, not the conversation — with
  /// the real conversation id sitting alongside it under `conversationId`.
  /// The old code checked `_id` before `conversationId`, so it grabbed the
  /// *message's* id and handed that back as the "conversation id". That id
  /// is a perfectly well-formed ObjectId (which is why it looked fine in
  /// the logs) but doesn't refer to a conversation at all, so every
  /// following `/chats/<that-id>/messages` call 400'd with "Invalid ID
  /// format". Fixed by checking the unambiguous `conversationId` field (and
  /// nested `conversation`/`chat` objects) first, and only falling back to
  /// a bare `_id`/`id` on a candidate that doesn't look like a message.
  String? _extractConversationId(Map<String, dynamic> root) {
    final candidateMaps = <Map<String, dynamic>>[];
    for (final entry in [root['data'], root['conversation'], root]) {
      if (entry is Map) candidateMaps.add(Map<String, dynamic>.from(entry));
    }

    // 1) Unambiguous signals first: an explicit `conversationId` field, or
    //    a nested `conversation`/`chat` value (string id or object).
    for (final map in candidateMaps) {
      final direct = map['conversationId'];
      if (direct is String && direct.trim().isNotEmpty) {
        debugPrint('[Chat] _extractConversationId: matched direct conversationId field');
        return direct.trim();
      }

      final nested = map['conversation'] ?? map['chat'];
      if (nested is String && nested.trim().isNotEmpty) {
        debugPrint('[Chat] _extractConversationId: matched nested conversation/chat string');
        return nested.trim();
      }
      if (nested is Map) {
        final nestedMap = Map<String, dynamic>.from(nested);
        final nestedId = nestedMap['_id'] ?? nestedMap['id'];
        if (nestedId is String && nestedId.trim().isNotEmpty) {
          debugPrint('[Chat] _extractConversationId: matched nested conversation/chat object _id');
          return nestedId.trim();
        }
      }
    }

    // 2) Last resort: a bare `_id`/`id` on the candidate map itself — but
    //    skip any map that looks like the created *message* (has
    //    `content`/`sender`), since that id belongs to the message, not
    //    the conversation.
    for (final map in candidateMaps) {
      if (map.containsKey('content') || map.containsKey('sender')) continue;
      final id = map['_id'] ?? map['id'];
      if (id is String && id.trim().isNotEmpty) {
        debugPrint('[Chat] _extractConversationId: fell back to bare _id/id on a non-message-looking map');
        return id.trim();
      }
    }
    debugPrint('[Chat] _extractConversationId: no candidate matched at all');
    return null;
  }

  // ── Fetch conversations list ──────────────────────────────────────────────
  Future<ConversationsResult> getConversations({bool archived = false}) async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/chats',
      requiresAuth: true,
      query: archived ? {'archived': 'true'} : null,
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
    // Diagnostic only (read-only call, no behavior change) — to confirm
    // whether GET accepts the same conversationId that POST rejects.
    debugPrint(
      '[Chat] getMessages ← conversationId="$conversationId" '
      'status=${response.statusCode} success=$ok message="$msg"',
    );

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

    // API already returns oldest→newest within the page (confirmed against
    // the live backend, and matches the documented contract) — no reversal
    // needed; the message screen's own ListView(reverse: true) handles
    // bottom-anchoring for display.
    return MessagesResult(
      success: true,
      message: msg,
      messages: messages,
    );
  }

  // ── Unread badge summary ──────────────────────────────────────────────────
  Future<UnreadSummaryResult> getUnreadCount() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/chats/unread-count',
      requiresAuth: true,
    );

    final ok = resolveSuccess(response);
    if (!ok) return const UnreadSummaryResult(success: false);

    final map = asMap(response.body);
    final data = map['data'] ?? map;
    final total = data is Map && data['total'] is num
        ? (data['total'] as num).toInt()
        : 0;
    final conversationsCount = data is Map && data['conversations'] is num
        ? (data['conversations'] as num).toInt()
        : 0;

    return UnreadSummaryResult(
      success: true,
      total: total,
      conversations: conversationsCount,
    );
  }

  // ── Send a message ────────────────────────────────────────────────────────
  Future<SendMessageResult> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    debugPrint(
      '[Chat] sendMessage → conversationId="$conversationId" '
      'contentLength=${content.length}',
    );

    if (conversationId.trim().isEmpty) {
      // Fail fast with a clear message instead of hitting
      // `/chats//messages`, which the backend rejects as "Invalid ID
      // format" — a much more confusing message to the user than this.
      debugPrint(
        '[Chat] sendMessage ✗ aborted before the network call — '
        'conversationId was empty. This means whatever created/opened this '
        'conversation (startConversation, or the screen that navigated '
        'here) handed over a blank id — check that call site\'s logs.',
      );
      return const SendMessageResult(
        success: false,
        message: 'This conversation is missing an ID — try reopening it.',
      );
    }

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/chats/$conversationId/messages',
      requiresAuth: true,
      body: {'content': content},
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);
    debugPrint(
      '[Chat] sendMessage ← status=${response.statusCode} success=$ok '
      'message="$msg" body=${response.body}',
    );

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
        debugPrint(
          '[Chat] sendMessage ✓ parsed message id=${chatMsg.id} '
          'status=${chatMsg.status} senderId=${chatMsg.senderId}',
        );
        return SendMessageResult(
          success: true,
          message: msg,
          chatMessage: chatMsg,
        );
      }
    }

    debugPrint(
      '[Chat] sendMessage ⚠ request succeeded but no message object could '
      'be parsed from the response body above — the sent bubble will not '
      'get replaced with server data (id/status will stay the optimistic '
      'placeholder). Check the response shape.',
    );
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

  // ── Archive / unarchive a conversation ────────────────────────────────────
  Future<ChatActionResult> archiveConversation(String conversationId) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/chats/$conversationId/archive',
      requiresAuth: true,
    );
    return _toActionResult(
      response,
      notFoundMessage: 'Conversation not found.',
    );
  }

  Future<ChatActionResult> unarchiveConversation(String conversationId) async {
    final response = await request(
      method: ApiHttpMethod.put,
      path: '/chats/$conversationId/unarchive',
      requiresAuth: true,
    );
    return _toActionResult(
      response,
      notFoundMessage: 'Conversation not found.',
    );
  }

  // ── Block / unblock a user ────────────────────────────────────────────────
  Future<ChatActionResult> blockUser(String userId) async {
    final response = await request(
      method: ApiHttpMethod.post,
      path: '/users/block/$userId',
      requiresAuth: true,
    );
    return _toActionResult(response, notFoundMessage: 'User not found.');
  }

  Future<ChatActionResult> unblockUser(String userId) async {
    final response = await request(
      method: ApiHttpMethod.delete,
      path: '/users/block/$userId',
      requiresAuth: true,
    );
    return _toActionResult(response, notFoundMessage: 'User not found.');
  }

  Future<BlockedUsersResult> getBlockedUsers() async {
    final response = await request(
      method: ApiHttpMethod.get,
      path: '/users/blocked',
      requiresAuth: true,
    );

    final ok = resolveSuccess(response);
    final msg = resolveMessage(response, ok);
    if (!ok) return BlockedUsersResult(success: false, message: msg);

    final map = asMap(response.body);
    final raw = map['data'];
    // Growable — the controller mutates this list in place (removeWhere on
    // unblock), so it can't be a fixed-length list.
    final list = raw is List
        ? raw
              .whereType<Map>()
              .map((m) => BlockedUser.fromMap(Map<String, dynamic>.from(m)))
              .where((u) => u.id.isNotEmpty)
              .toList()
        : <BlockedUser>[];

    return BlockedUsersResult(success: true, message: msg, users: list);
  }

  // ── Report a user ─────────────────────────────────────────────────────────
  Future<ChatActionResult> reportUser({
    required String userId,
    required String reason,
    String? description,
    String? conversationId,
  }) async {
    final body = <String, dynamic>{
      'reason': reason,
      if ((description ?? '').trim().isNotEmpty)
        'description': description!.trim(),
      if ((conversationId ?? '').trim().isNotEmpty)
        'conversationId': conversationId!.trim(),
    };

    final response = await request(
      method: ApiHttpMethod.post,
      path: '/users/$userId/report',
      requiresAuth: true,
      body: body,
    );
    return _toActionResult(
      response,
      notFoundMessage: 'User not found.',
      conflictMessage: 'You have already reported this user.',
    );
  }

  ChatActionResult _toActionResult(
    Response<dynamic> response, {
    String? notFoundMessage,
    String? conflictMessage,
  }) {
    final ok = resolveSuccess(response);
    final msg = (!ok && response.statusCode == 409 && conflictMessage != null)
        ? conflictMessage
        : resolveMessage(response, ok, notFoundMessage: notFoundMessage);
    return ChatActionResult(success: ok, message: msg);
  }
}
