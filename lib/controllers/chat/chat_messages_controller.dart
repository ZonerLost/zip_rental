import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/chat/chat_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/chat/chat_service.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';

class ChatMessagesController extends GetxController {
  ChatMessagesController({
    required this.conversationId,
    this.activeItemId,
    this.activeItemTitle,
    this.participantId,
    bool initialParticipantIsOnline = false,
    DateTime? initialParticipantLastSeenAt,
    ChatService? chatService,
    AuthService? authService,
    ChatSocketService? socketService,
  }) : _chatService = chatService ?? ChatService(),
       _authService = authService ?? AuthService(),
       // Shared with the chat list screen's socket — see
       // ChatSocketService.shared. Previously each screen opened its own
       // separate connection despite this comment already claiming
       // otherwise; now it's actually true.
       _socket = socketService ?? ChatSocketService.shared,
       otherIsOnline = initialParticipantIsOnline,
       otherLastSeenAt = initialParticipantLastSeenAt;

  final String conversationId;
  final String? activeItemId;
  final String? activeItemTitle;
  /// The other participant's user ID — needed to filter presence_update
  /// events to just this conversation's counterpart. Optional because not
  /// every call site knows it up front (matches ChatMessagesScreen).
  final String? participantId;
  final ChatService _chatService;
  final AuthService _authService;
  final ChatSocketService _socket;

  final messageInputController = TextEditingController();

  List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;
  String? currentUserId;
  bool otherUserIsTyping = false;
  /// Live presence for [participantId] — seeded from whatever the caller
  /// already knew (e.g. the snapshot on GET /chats) and updated in real
  /// time via presence_update while this screen is open.
  bool otherIsOnline;
  DateTime? otherLastSeenAt;

  // Debounce timer to stop emitting typing after user pauses
  Timer? _typingTimer;
  bool _isEmittingTyping = false;

  StreamSubscription<ChatMessage>? _newMsgSub;
  StreamSubscription<SocketTypingEvent>? _typingSub;
  StreamSubscription<SocketReceiptEvent>? _deliveredSub;
  StreamSubscription<SocketReceiptEvent>? _readSub;
  StreamSubscription<SocketMessageDeletedEvent>? _deletedSub;
  StreamSubscription<SocketPresenceEvent>? _presenceSub;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Logged once per screen-open so a send-failure trace can always be
    // matched back to exactly which conversationId this screen was opened
    // with (and from where, via the caller's own logs just before this).
    debugPrint(
      '[ChatMessages] screen opened with conversationId="$conversationId" '
      'activeItemId=$activeItemId',
    );
    await _resolveUserId();
    await _connectSocket();
    await loadMessages();
    // Mark as read once loaded
    _chatService.markAsRead(conversationId);
  }

  // ── User identity ─────────────────────────────────────────────────────────
  Future<void> _resolveUserId() async {
    final token = await _authService.ensureAccessToken();
    if (token != null) {
      currentUserId = extractUserIdFromJwt(token);
    }
  }

  bool isMe(String senderId) => senderId == currentUserId;

  // ── Socket ────────────────────────────────────────────────────────────────
  Future<void> _connectSocket() async {
    // Reuse the shared socket if it's already connected (e.g. from the
    // chat list screen) rather than opening a second connection.
    if (!_socket.isConnected) {
      final token = await _authService.ensureAccessToken();
      if (token != null) _socket.connect(token);
    }

    _socket.joinConversation(conversationId);

    _newMsgSub = _socket.onNewMessage.listen((msg) {
      debugPrint(
        '[ChatMessages] socket new_message received id=${msg.id} '
        'conversationId=${msg.conversationId} senderId=${msg.senderId} '
        '(this screen\'s conversationId=$conversationId)',
      );
      if (msg.conversationId != conversationId) return;
      // Avoid duplicates (message may have been added optimistically)
      if (messages.any((m) => m.id == msg.id)) {
        debugPrint('[ChatMessages] socket new_message id=${msg.id} already present — skipped');
        return;
      }
      messages.add(msg);
      update();
      // Mark read immediately when the screen is open
      _chatService.markAsRead(conversationId);
    });

    _typingSub = _socket.onTyping.listen((event) {
      if (event.conversationId != conversationId) return;
      if (event.userId == currentUserId) return;
      otherUserIsTyping = event.isTyping;
      update();
    });

    _deliveredSub = _socket.onMessagesDelivered.listen((event) {
      if (event.conversationId != conversationId) return;
      _applyReceipt(event.messageIds, deliveredAt: event.at);
    });

    _readSub = _socket.onMessagesRead.listen((event) {
      if (event.conversationId != conversationId) return;
      _applyReceipt(event.messageIds, readAt: event.at);
    });

    _deletedSub = _socket.onMessageDeleted.listen((event) {
      if (event.conversationId != conversationId) return;
      final removed = messages.length;
      messages.removeWhere((m) => m.id == event.messageId);
      if (messages.length != removed) update();
    });

    if ((participantId ?? '').isNotEmpty) {
      _presenceSub = _socket.onPresenceUpdate.listen((event) {
        if (event.userId != participantId) return;
        otherIsOnline = event.isOnline;
        otherLastSeenAt = event.lastSeenAt ?? otherLastSeenAt;
        update();
      });
    }
  }

  /// Flips the tick state of the given messages in place — called from the
  /// `messages_delivered`/`messages_read` socket listeners above.
  void _applyReceipt(
    List<String> messageIds, {
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    if (messageIds.isEmpty) return;
    final ids = messageIds.toSet();
    var changed = false;
    messages = messages.map((m) {
      if (!ids.contains(m.id)) return m;
      changed = true;
      return m.copyWith(
        deliveredAt: deliveredAt,
        readAt: readAt,
        isRead: readAt != null ? true : null,
      );
    }).toList();
    if (changed) update();
  }

  // ── REST ──────────────────────────────────────────────────────────────────
  Future<void> loadMessages() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _chatService.getMessages(conversationId);

    isLoading = false;
    if (result.success) {
      messages = result.messages;
      errorMessage = null;
    } else {
      errorMessage = result.message;
    }
    update();
  }

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty || isSending) return;

    // Optimistic UI — add a temporary message immediately
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final rawContent = ChatMessage.encodeContentWithItemReference(
      text,
      itemId: activeItemId,
      itemTitle: activeItemTitle,
    );
    final optimistic = ChatMessage.fromRaw(
      id: tempId,
      conversationId: conversationId,
      senderId: currentUserId ?? '',
      rawContent: rawContent,
      createdAt: DateTime.now(),
    );
    messages.add(optimistic);
    messageInputController.clear();
    _stopTypingEmit();
    isSending = true;
    update();

    debugPrint(
      '[ChatMessages] sendMessage → conversationId="$conversationId" '
      'tempId=$tempId textLength=${text.length} '
      'hasItemRef=${(activeItemId ?? '').isNotEmpty}',
    );

    final result = await _chatService.sendMessage(
      conversationId: conversationId,
      content: rawContent,
    );

    debugPrint(
      '[ChatMessages] sendMessage ← success=${result.success} '
      'message="${result.message}" '
      'chatMessage=${result.chatMessage != null ? "id=${result.chatMessage!.id} status=${result.chatMessage!.status}" : "null"}',
    );

    isSending = false;
    if (result.success && result.chatMessage != null) {
      // Replace optimistic with the real message. If the optimistic entry
      // is gone (e.g. a conversation_updated refresh replaced the whole
      // list while this send was in flight) but the real one isn't there
      // either, add it rather than silently dropping it.
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages[idx] = result.chatMessage!;
        debugPrint('[ChatMessages] sendMessage ✓ replaced optimistic $tempId with real message');
      } else if (!messages.any((m) => m.id == result.chatMessage!.id)) {
        messages.add(result.chatMessage!);
        debugPrint(
          '[ChatMessages] sendMessage ⚠ optimistic $tempId was gone by the '
          'time the response arrived (likely a conversation_updated '
          'refresh raced it) — appended the real message instead of '
          'dropping it',
        );
      }
    } else if (!result.success) {
      // Remove optimistic and show error
      messages.removeWhere((m) => m.id == tempId);
      debugPrint('[ChatMessages] sendMessage ✗ failed — reverted optimistic $tempId: ${result.message}');
      Get.snackbar('Send failed', _friendlySendError(result.message));
    } else {
      debugPrint(
        '[ChatMessages] sendMessage ⚠ server reported success but returned '
        'no parsable message — optimistic $tempId left in place as-is',
      );
    }
    update();
  }

  /// The backend sometimes surfaces raw validation strings — like "Invalid
  /// ID format" for `POST /chats/{id}/messages`, seen even when this exact
  /// same conversationId just succeeded on GET/other endpoints (a
  /// server-side inconsistency, not something wrong with the ID this app
  /// sent) — that mean nothing to a user. Swap those for plain language;
  /// everything else passes through as the backend phrased it.
  String _friendlySendError(String backendMessage) {
    if (backendMessage.toLowerCase().contains('invalid id format')) {
      return "Couldn't send that message. Try leaving and reopening this chat.";
    }
    return backendMessage;
  }

  Future<void> deleteMessage(String messageId) async {
    final ok = await _chatService.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
    if (ok) {
      messages.removeWhere((m) => m.id == messageId);
      update();
    }
  }

  // ── Typing indicator ──────────────────────────────────────────────────────
  void onMessageInputChanged(String value) {
    if (value.isNotEmpty && !_isEmittingTyping) {
      _isEmittingTyping = true;
      _socket.emitTyping(conversationId);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTypingEmit);
    update(); // Refresh send button active state
  }

  void _stopTypingEmit() {
    if (_isEmittingTyping) {
      _isEmittingTyping = false;
      _socket.emitStopTyping(conversationId);
    }
    _typingTimer?.cancel();
  }

  bool get canSend =>
      messageInputController.text.trim().isNotEmpty && !isSending;

  // ── Cleanup ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _stopTypingEmit();
    _socket.leaveConversation(conversationId);
    _newMsgSub?.cancel();
    _typingSub?.cancel();
    _deliveredSub?.cancel();
    _readSub?.cancel();
    _deletedSub?.cancel();
    _presenceSub?.cancel();
    _typingTimer?.cancel();
    messageInputController.dispose();
    super.onClose();
  }
}
