import 'dart:async';

import 'package:get/get.dart';
import 'package:zip_peer/models/chat/chat_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/chat/chat_service.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';

class ChatController extends GetxController {
  ChatController({
    ChatService? chatService,
    AuthService? authService,
    ChatSocketService? socketService,
  })  : _chatService = chatService ?? ChatService(),
        _authService = authService ?? AuthService(),
        _socket = socketService ?? ChatSocketService();

  final ChatService _chatService;
  final AuthService _authService;
  final ChatSocketService _socket;

  List<ChatConversation> conversations = [];
  bool isLoading = false;
  String? errorMessage;
  String? currentUserId;

  // Typing state per conversation (conversationId → isTyping)
  final Map<String, bool> _typingState = {};

  StreamSubscription<ChatMessage>? _newMsgSub;
  StreamSubscription<Map<String, dynamic>>? _convUpdatedSub;
  StreamSubscription<bool>? _connSub;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _resolveUserId();
    await _connectSocket();
    await loadConversations();
  }

  // ── User identity ─────────────────────────────────────────────────────────
  Future<void> _resolveUserId() async {
    final token = await _authService.ensureAccessToken();
    if (token != null) {
      currentUserId = extractUserIdFromJwt(token);
    }
  }

  // ── Socket ────────────────────────────────────────────────────────────────
  Future<void> _connectSocket() async {
    final token = await _authService.ensureAccessToken();
    if (token == null) return;

    _socket.connect(token);

    _connSub = _socket.onConnectionStatus.listen((connected) {
      // Refresh list after reconnect so we don't miss messages
      if (connected) loadConversations();
    });

    _newMsgSub = _socket.onNewMessage.listen(_handleSocketNewMessage);
    _convUpdatedSub =
        _socket.onConversationUpdated.listen(_handleConversationUpdated);
  }

  void _handleSocketNewMessage(ChatMessage msg) {
    // Find the matching conversation and update its lastMessage + unreadCount
    final idx = conversations.indexWhere(
      (c) => c.id == msg.conversationId,
    );
    if (idx == -1) {
      // Unknown conversation — reload the full list
      loadConversations();
      return;
    }
    final old = conversations[idx];
    final isFromMe = msg.senderId == currentUserId;
    conversations[idx] = old.copyWith(
      lastMessage: msg,
      unreadCount: isFromMe ? old.unreadCount : old.unreadCount + 1,
      updatedAt: msg.createdAt,
    );
    // Bubble the updated conversation to the top
    final updated = conversations.removeAt(idx);
    conversations.insert(0, updated);
    update();
  }

  void _handleConversationUpdated(Map<String, dynamic> data) {
    // Server sent a full refresh signal — reload conversations
    loadConversations();
  }

  // ── REST ──────────────────────────────────────────────────────────────────
  Future<void> loadConversations() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _chatService.getConversations();

    isLoading = false;
    if (result.success) {
      conversations = result.conversations;
      errorMessage = null;
    } else {
      errorMessage = result.message;
    }
    update();
  }

  Future<String?> startConversation({
    required String otherUserId,
    required String message,
    String? itemId,
  }) async {
    final result = await _chatService.startConversation(
      otherUserId: otherUserId,
      message: message,
      itemId: itemId,
    );
    if (result.success) {
      await loadConversations();
      return result.conversationId;
    }
    Get.snackbar('Chat', result.message);
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool isTypingInConversation(String conversationId) =>
      _typingState[conversationId] == true;

  void resetUnreadCount(String conversationId) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    conversations[idx] = conversations[idx].copyWith(unreadCount: 0);
    update();
  }

  void setArchived(String conversationId, bool archived) {
    final idx = conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    conversations[idx] = conversations[idx].copyWith(isArchived: archived);
    update();
  }

  @override
  void onClose() {
    _newMsgSub?.cancel();
    _convUpdatedSub?.cancel();
    _connSub?.cancel();
    _socket.dispose();
    super.onClose();
  }
}
