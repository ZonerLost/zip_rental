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
    ChatService? chatService,
    AuthService? authService,
    ChatSocketService? socketService,
  })  : _chatService = chatService ?? ChatService(),
        _authService = authService ?? AuthService(),
        _socket = socketService ?? ChatSocketService();

  final String conversationId;
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

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
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
      if (msg.conversationId != conversationId) return;
      // Avoid duplicates (message may have been added optimistically)
      if (messages.any((m) => m.id == msg.id)) return;
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
    final optimistic = ChatMessage(
      id: tempId,
      conversationId: conversationId,
      senderId: currentUserId ?? '',
      content: text,
      status: 'sent',
      createdAt: DateTime.now(),
    );
    messages.add(optimistic);
    messageInputController.clear();
    _stopTypingEmit();
    isSending = true;
    update();

    final result = await _chatService.sendMessage(
      conversationId: conversationId,
      content: text,
    );

    isSending = false;
    if (result.success && result.chatMessage != null) {
      // Replace optimistic with real message
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) messages[idx] = result.chatMessage!;
    } else if (!result.success) {
      // Remove optimistic and show error
      messages.removeWhere((m) => m.id == tempId);
      Get.snackbar('Send failed', result.message);
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
      _socket.emitTyping(conversationId: conversationId, isTyping: true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTypingEmit);
    update(); // Refresh send button active state
  }

  void _stopTypingEmit() {
    if (_isEmittingTyping) {
      _isEmittingTyping = false;
      _socket.emitTyping(conversationId: conversationId, isTyping: false);
    }
    _typingTimer?.cancel();
  }

  bool get canSend => messageInputController.text.trim().isNotEmpty && !isSending;

  // ── Cleanup ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _stopTypingEmit();
    _socket.leaveConversation(conversationId);
    _newMsgSub?.cancel();
    _typingSub?.cancel();
    _typingTimer?.cancel();
    messageInputController.dispose();
    super.onClose();
  }
}
