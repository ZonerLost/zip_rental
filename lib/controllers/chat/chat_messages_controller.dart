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
    ChatService? chatService,
    AuthService? authService,
    ChatSocketService? socketService,
  }) : _chatService = chatService ?? ChatService(),
       _authService = authService ?? AuthService(),
       _socket = socketService ?? ChatSocketService();

  final String conversationId;
  final String? activeItemId;
  final String? activeItemTitle;
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

  // Debounce timer to stop emitting typing after user pauses
  Timer? _typingTimer;
  bool _isEmittingTyping = false;

  StreamSubscription<ChatMessage>? _newMsgSub;
  StreamSubscription<SocketTypingEvent>? _typingSub;
  StreamSubscription<Map<String, dynamic>>? _convUpdatedSub;

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
    // Reuse an already-connected socket if possible (shared via Get.find)
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

    // There's no dedicated "message read" socket event — conversation_updated
    // is the closest general-purpose signal, and it's the most plausible
    // way a read receipt on the other end would reach us live. Refresh the
    // thread so sent/delivered ticks can flip to read without the user
    // having to leave and reopen the conversation.
    _convUpdatedSub = _socket.onConversationUpdated.listen((data) {
      final targetId = data['conversationId']?.toString() ??
          data['_id']?.toString();
      if (targetId != null && targetId != conversationId) return;
      loadMessages();
    });
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
      status: 'sent',
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
      Get.snackbar('Send failed', result.message);
    } else {
      debugPrint(
        '[ChatMessages] sendMessage ⚠ server reported success but returned '
        'no parsable message — optimistic $tempId left in place as-is',
      );
    }
    update();
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
    _convUpdatedSub?.cancel();
    _typingTimer?.cancel();
    messageInputController.dispose();
    super.onClose();
  }
}
