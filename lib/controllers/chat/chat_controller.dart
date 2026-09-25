import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:zip_peer/controllers/bottom_nav_controller.dart';
import 'package:zip_peer/controllers/notifications/notifications_controller.dart';
import 'package:zip_peer/models/chat/chat_models.dart';
import 'package:zip_peer/models/notifications/notification_models.dart';
import 'package:zip_peer/services/auth/auth_service.dart';
import 'package:zip_peer/services/chat/chat_service.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';

class ChatController extends GetxController {
  ChatController({
    ChatService? chatService,
    AuthService? authService,
    ChatSocketService? socketService,
  }) : _chatService = chatService ?? ChatService(),
       _authService = authService ?? AuthService(),
       // Shared across the whole app — see ChatSocketService.shared. This
       // controller only cancels its OWN subscriptions on close; it must
       // never disconnect/dispose the shared socket itself, since a thread
       // screen (ChatMessagesController) may still be relying on it, and
       // this controller gets recreated every time the Chats tab reopens.
       _socket = socketService ?? ChatSocketService.shared;

  final ChatService _chatService;
  final AuthService _authService;
  final ChatSocketService _socket;

  List<ChatConversation> conversations = [];
  bool isLoading = false;
  String? errorMessage;

  List<ChatConversation> archivedConversations = [];
  bool isLoadingArchived = false;
  String? archivedErrorMessage;
  // The archived tab is loaded lazily (only once the user actually opens
  // it) rather than eagerly on every bootstrap.
  bool hasLoadedArchivedOnce = false;

  bool isArchivingConversation = false;

  List<BlockedUser> blockedUsers = [];
  bool isLoadingBlockedUsers = false;
  String? blockedUsersErrorMessage;
  bool isBlockActionLoading = false;
  bool isReportActionLoading = false;
  // Mirrors blockedUsers as a Set for O(1) lookups when filtering the
  // conversation lists and gating messaging — updated optimistically the
  // moment a block/unblock succeeds, not just after the next full reload.
  final Set<String> blockedUserIds = <String>{};

  /// Conversations with anyone blocked filtered out — this is what every
  /// screen should render instead of [conversations] directly.
  List<ChatConversation> get visibleConversations =>
      conversations.where((c) => !_isWithBlockedUser(c)).toList(growable: false);

  List<ChatConversation> get visibleArchivedConversations => archivedConversations
      .where((c) => !_isWithBlockedUser(c))
      .toList(growable: false);

  bool _isWithBlockedUser(ChatConversation conversation) {
    final other = conversation.otherParticipant(currentUserId ?? '');
    return other != null && blockedUserIds.contains(other.id);
  }

  bool isUserBlocked(String? userId) =>
      (userId ?? '').isNotEmpty && blockedUserIds.contains(userId);

  String? currentUserId;

  // Typing state per conversation (conversationId → isTyping), driven by the
  // socket's user_typing/user_stop_typing events — shown as a "typing..."
  // preview on that conversation's row in the chat list.
  final Map<String, bool> _typingState = {};
  final Map<String, Timer> _typingFallbackTimers = {};

  StreamSubscription<ChatMessage>? _newMsgSub;
  StreamSubscription<Map<String, dynamic>>? _convUpdatedSub;
  StreamSubscription<SocketTypingEvent>? _typingSub;
  StreamSubscription<Map<String, dynamic>>? _notificationSub;
  StreamSubscription<bool>? _connSub;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _resolveUserId();
    await _connectSocket();
    // Load blocked users first so the very first conversations render
    // already has blocked-user chats filtered out — not just after the
    // user takes some action.
    await loadBlockedUsers();
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
    _convUpdatedSub = _socket.onConversationUpdated.listen(
      _handleConversationUpdated,
    );
    _typingSub = _socket.onTyping.listen(_handleTypingForList);
    _notificationSub = _socket.onNotification.listen(_handleRealtimeNotification);
    // No message_deleted listener here on purpose: backend confirmed a
    // conversation_updated now always follows a delete (with the preview
    // and unread count already reconciled server-side), so
    // _handleConversationUpdated's reload already covers this. A dedicated
    // listener here would just double the reload per delete.
  }

  void _handleTypingForList(SocketTypingEvent event) {
    if (event.conversationId.isEmpty) return;
    // Ignore our own typing echoed back, if the server ever does that.
    if (event.userId.isNotEmpty && event.userId == currentUserId) return;

    _typingFallbackTimers.remove(event.conversationId)?.cancel();

    if (event.isTyping) {
      _typingState[event.conversationId] = true;
      // Defensive fallback in case a stop_typing event is ever dropped —
      // don't leave "typing..." stuck on a row forever.
      _typingFallbackTimers[event.conversationId] = Timer(
        const Duration(seconds: 6),
        () {
          _typingState[event.conversationId] = false;
          update();
        },
      );
    } else {
      _typingState[event.conversationId] = false;
    }
    update();
  }

  void _handleRealtimeNotification(Map<String, dynamic> data) {
    if (!Get.isRegistered<NotificationsController>()) return;
    final item = NotificationItem.fromJson(data);
    if (item.id.trim().isEmpty) return;
    Get.find<NotificationsController>().addRealtimeNotification(item);
  }

  void _handleSocketNewMessage(ChatMessage msg) {
    // Find the matching conversation (active or archived — a new message
    // can still arrive for a conversation the user has archived) and update
    // its lastMessage + unread count.
    final activeIdx = conversations.indexWhere((c) => c.id == msg.conversationId);
    if (activeIdx != -1) {
      final old = conversations[activeIdx];
      conversations[activeIdx] = _applyIncomingMessage(old, msg);
      // Bubble the updated conversation to the top.
      final updated = conversations.removeAt(activeIdx);
      conversations.insert(0, updated);
      update();
      _syncUnreadBadge();
      return;
    }

    final archivedIdx =
        archivedConversations.indexWhere((c) => c.id == msg.conversationId);
    if (archivedIdx != -1) {
      archivedConversations[archivedIdx] = _applyIncomingMessage(
        archivedConversations[archivedIdx],
        msg,
      );
      update();
      return;
    }

    // Unknown conversation — reload the full list.
    loadConversations();
  }

  ChatConversation _applyIncomingMessage(ChatConversation old, ChatMessage msg) {
    final isFromMe = msg.senderId == currentUserId;
    return old.copyWith(
      lastMessage: msg,
      unread: isFromMe ? old.unread : old.unread + 1,
      updatedAt: msg.createdAt,
    );
  }

  void _handleConversationUpdated(Map<String, dynamic> data) {
    // Confirmed with backend: this event name is overloaded — `type` is
    // "conversation" for an actual chat update, but "notification" for an
    // in-app notification (booking accepted, review received, etc.) piggy-
    // backed onto the same event name. Route that case through the same
    // handler as the dedicated 'notification' socket event instead of
    // misreading it as a conversation change and reloading the chat list
    // for no reason.
    if (data['type']?.toString() == 'notification') {
      final notification = data['notification'];
      if (notification is Map) {
        _handleRealtimeNotification(Map<String, dynamic>.from(notification));
      }
      return;
    }
    // type == "conversation" (or absent, for safety) — reload conversations.
    loadConversations();
  }

  // ── REST — conversations ────────────────────────────────────────────────
  Future<void> loadConversations() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await _chatService.getConversations(archived: false);

    isLoading = false;
    if (result.success) {
      conversations = result.conversations;
      errorMessage = null;
      _syncUnreadBadge();
    } else {
      errorMessage = result.message;
    }
    update();
  }

  Future<void> loadArchivedConversations({bool refresh = false}) async {
    if (hasLoadedArchivedOnce && !refresh) return;

    isLoadingArchived = true;
    archivedErrorMessage = null;
    update();

    final result = await _chatService.getConversations(archived: true);

    isLoadingArchived = false;
    hasLoadedArchivedOnce = true;
    if (result.success) {
      archivedConversations = result.conversations;
      archivedErrorMessage = null;
    } else {
      archivedErrorMessage = result.message;
    }
    update();
  }

  Future<bool> archiveConversation(String conversationId) async {
    return _moveConversation(
      conversationId: conversationId,
      fromArchived: false,
      action: () => _chatService.archiveConversation(conversationId),
      failureTitle: 'Archive Failed',
    );
  }

  Future<bool> unarchiveConversation(String conversationId) async {
    return _moveConversation(
      conversationId: conversationId,
      fromArchived: true,
      action: () => _chatService.unarchiveConversation(conversationId),
      failureTitle: 'Unarchive Failed',
    );
  }

  Future<bool> _moveConversation({
    required String conversationId,
    required bool fromArchived,
    required Future<ChatActionResult> Function() action,
    required String failureTitle,
  }) async {
    if (isArchivingConversation) return false;
    isArchivingConversation = true;
    update();

    final result = await action();

    isArchivingConversation = false;
    if (!result.success) {
      update();
      Get.snackbar(failureTitle, result.message);
      return false;
    }

    final sourceList = fromArchived ? archivedConversations : conversations;
    final destList = fromArchived ? conversations : archivedConversations;
    final idx = sourceList.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final moved = sourceList.removeAt(idx);
      destList.insert(0, moved);
    }
    update();
    return true;
  }

  // ── REST — block/report ─────────────────────────────────────────────────
  Future<void> loadBlockedUsers() async {
    isLoadingBlockedUsers = true;
    blockedUsersErrorMessage = null;
    update();

    final result = await _chatService.getBlockedUsers();

    isLoadingBlockedUsers = false;
    if (result.success) {
      blockedUsers = result.users;
      blockedUserIds
        ..clear()
        ..addAll(result.users.map((u) => u.id));
      blockedUsersErrorMessage = null;
    } else {
      blockedUsersErrorMessage = result.message;
    }
    update();
  }

  Future<bool> blockUser(String userId) async {
    if (isBlockActionLoading) return false;
    isBlockActionLoading = true;
    update();

    final result = await _chatService.blockUser(userId);

    isBlockActionLoading = false;
    if (result.success) {
      // Hide immediately — don't wait on a round trip to disappear from the
      // chat list, and don't leave a conversation the user can still tap
      // into and try to message through.
      blockedUserIds.add(userId);
    }
    update();
    if (!result.success) {
      Get.snackbar('Block Failed', result.message);
      return false;
    }
    Get.snackbar('User Blocked', result.message);
    // Reconcile the full profile list (name/photo for the Blocked Users
    // screen) in the background — the id-based filtering above already
    // took effect above regardless of this call's outcome.
    unawaited(loadBlockedUsers());
    return true;
  }

  Future<bool> unblockUser(String userId) async {
    if (isBlockActionLoading) return false;
    isBlockActionLoading = true;
    update();

    final result = await _chatService.unblockUser(userId);

    isBlockActionLoading = false;
    if (result.success) {
      blockedUsers.removeWhere((u) => u.id == userId);
      blockedUserIds.remove(userId);
    }
    update();
    if (!result.success) {
      Get.snackbar('Unblock Failed', result.message);
      return false;
    }
    Get.snackbar('User Unblocked', result.message);
    return true;
  }

  Future<bool> reportUser({
    required String userId,
    required String reason,
    String? description,
    String? conversationId,
  }) async {
    if (isReportActionLoading) return false;
    isReportActionLoading = true;
    update();

    final result = await _chatService.reportUser(
      userId: userId,
      reason: reason,
      description: description,
      conversationId: conversationId,
    );

    isReportActionLoading = false;
    update();
    if (!result.success) {
      Get.snackbar('Report Failed', result.message);
      return false;
    }
    Get.snackbar('Report Submitted', result.message);
    return true;
  }

  // ── REST — start / send ─────────────────────────────────────────────────
  Future<String?> startConversation({
    required String otherUserId,
    required String message,
    String? itemId,
    String? itemTitle,
  }) async {
    debugPrint(
      '[ChatController] startConversation → otherUserId=$otherUserId '
      'itemId=$itemId',
    );

    if (isUserBlocked(otherUserId)) {
      debugPrint('[ChatController] startConversation ✗ otherUserId is blocked');
      Get.snackbar(
        'Blocked',
        'You have blocked this user. Unblock them from Account Settings to message them.',
      );
      return null;
    }

    // Check both lists — a user can have messaged this person before about a
    // different item and later archived that thread; re-messaging them
    // should continue that same conversation, not start a second one.
    await Future.wait([loadConversations(), loadArchivedConversations()]);

    final wasInActiveList = conversations.any(
      (c) => c.participants.any((p) => p.id == otherUserId),
    );
    final existingConversation = findConversationWithUser(otherUserId);
    debugPrint(
      '[ChatController] startConversation existingConversation='
      '${existingConversation?.id ?? "none"} wasInActiveList=$wasInActiveList',
    );
    if (existingConversation != null && !wasInActiveList) {
      // Found it, but not in the active list — it must have come from
      // archivedConversations. Bring it back since the user is actively
      // re-engaging with this person.
      debugPrint(
        '[ChatController] startConversation unarchiving '
        '${existingConversation.id} before reusing it',
      );
      await unarchiveConversation(existingConversation.id);
    }

    final encodedMessage = ChatMessage.encodeContentWithItemReference(
      message,
      itemId: itemId,
      itemTitle: itemTitle,
    );

    if (existingConversation != null) {
      debugPrint(
        '[ChatController] startConversation reusing existing conversation '
        '${existingConversation.id} — sending message instead of creating a new one',
      );
      final sendResult = await _chatService.sendMessage(
        conversationId: existingConversation.id,
        content: encodedMessage,
      );
      if (sendResult.success) {
        await loadConversations();
        debugPrint(
          '[ChatController] startConversation ✓ returning existing '
          'conversationId=${existingConversation.id}',
        );
        return existingConversation.id;
      }
      // Don't hard-fail here — the conversation we tried to reuse (possibly
      // just unarchived) may be stale or gone server-side. Fall through and
      // create a brand-new one instead of leaving the user stuck.
      debugPrint(
        '[ChatController] startConversation ⚠ reusing existing conversation '
        '${existingConversation.id} failed (${sendResult.message}) — '
        'falling back to creating a fresh conversation instead of failing',
      );
    }

    debugPrint('[ChatController] startConversation creating a new conversation');
    final result = await _chatService.startConversation(
      otherUserId: otherUserId,
      message: encodedMessage,
      itemId: itemId,
    );
    if (result.success) {
      await loadConversations();
      debugPrint(
        '[ChatController] startConversation ✓ created '
        'conversationId=${result.conversationId}',
      );
      return result.conversationId;
    }
    debugPrint('[ChatController] startConversation ✗ create failed: ${result.message}');
    Get.snackbar('Chat', result.message);
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool isTypingInConversation(String conversationId) =>
      _typingState[conversationId] == true;

  ChatConversation? findConversationWithUser(String otherUserId) {
    for (final conversation in [...conversations, ...archivedConversations]) {
      final hasOtherUser = conversation.participants.any(
        (participant) => participant.id == otherUserId,
      );
      if (hasOtherUser) {
        return conversation;
      }
    }
    return null;
  }

  void resetUnreadCount(String conversationId) {
    final activeIdx = conversations.indexWhere((c) => c.id == conversationId);
    if (activeIdx != -1) {
      conversations[activeIdx] = conversations[activeIdx].copyWith(unread: 0);
      update();
      _syncUnreadBadge();
      return;
    }

    final archivedIdx =
        archivedConversations.indexWhere((c) => c.id == conversationId);
    if (archivedIdx != -1) {
      archivedConversations[archivedIdx] =
          archivedConversations[archivedIdx].copyWith(unread: 0);
      update();
    }
  }

  /// Keeps the bottom-nav "Chats" badge in sync with what's already loaded
  /// here, instead of round-tripping `/chats/unread-count` again on every
  /// local change — that endpoint is only needed to seed the badge before
  /// this controller has ever loaded anything (see BottomNavController).
  void _syncUnreadBadge() {
    if (!Get.isRegistered<BottomNavController>()) return;
    final total = conversations.fold<int>(0, (sum, c) => sum + c.unread);
    Get.find<BottomNavController>().setUnreadChatCount(total);
  }

  @override
  void onClose() {
    _newMsgSub?.cancel();
    _convUpdatedSub?.cancel();
    _typingSub?.cancel();
    _notificationSub?.cancel();
    _connSub?.cancel();
    for (final timer in _typingFallbackTimers.values) {
      timer.cancel();
    }
    _typingFallbackTimers.clear();
    // Deliberately NOT disposing _socket here — it's the shared, app-wide
    // socket (see ChatSocketService.shared), not owned by this controller.
    // This controller gets recreated every time the Chats tab reopens, but
    // the connection itself should persist for the whole session; it's
    // torn down on logout instead (see LogoutBottomSheet).
    super.onClose();
  }
}
