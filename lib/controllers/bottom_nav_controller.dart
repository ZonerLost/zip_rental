import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:zip_peer/models/profile/profile_models.dart';
import 'package:zip_peer/services/chat/chat_service.dart';
import 'package:zip_peer/services/chat/chat_socket_service.dart';
import 'package:zip_peer/services/profile/profile_service.dart';

class BottomNavController extends GetxController with WidgetsBindingObserver {
  BottomNavController({ProfileService? profileService, ChatService? chatService})
    : _profileService = profileService ?? ProfileService(),
      _chatService = chatService ?? ChatService();

  static BottomNavController get to => Get.find();

  final ProfileService _profileService;
  final ChatService _chatService;

  int currentIndex = 0;
  String? profilePhotoUrl;
  bool isLoadingProfilePhoto = false;
  int unreadChatCount = 0;

  // ── Badge polling fallback ───────────────────────────────────────────────
  // The socket can't connect at all right now (see ChatSocketService.
  // socketEnabled) — this is the backend team's own recommended interim
  // approach (docs/backend-chat-socket-questions.md section 4) while their
  // fixed host isn't live yet. Becomes a no-op automatically once
  // socketEnabled flips back to true.
  static const Duration _pollInterval = Duration(seconds: 30);
  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    refreshProfilePhoto();
    refreshUnreadChatCount();
    _startPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshUnreadChatCount();
      _startPolling();
    } else {
      // Only poll a foregrounded screen (backend's explicit rate-limit
      // guidance — the cap is shared per-IP, not per-user).
      _pollTimer?.cancel();
    }
  }

  void _startPolling() {
    if (ChatSocketService.socketEnabled) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => refreshUnreadChatCount());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.onClose();
  }

  void switchTo(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    update();
  }

  /// Seeds/refreshes the "Chats" badge from the dedicated summary endpoint —
  /// needed so the badge is correct even before ChatController has ever
  /// loaded anything (e.g. right after login, before the Chats tab is
  /// opened). Once ChatController is active, it keeps the count in sync
  /// locally via [setUnreadChatCount] instead of re-hitting this endpoint.
  Future<void> refreshUnreadChatCount() async {
    final result = await _chatService.getUnreadCount();
    if (result.success) {
      unreadChatCount = result.total;
      update();
    }
  }

  void setUnreadChatCount(int value) {
    if (unreadChatCount == value) return;
    unreadChatCount = value;
    update();
  }

  Future<void> refreshProfilePhoto() async {
    isLoadingProfilePhoto = true;
    update();

    final result = await _profileService.getProfile();
    if (result.success && result.profile != null) {
      profilePhotoUrl = _withCacheBust(
        _bestPhotoUrl(result),
        result.profile?.updatedAt?.millisecondsSinceEpoch,
      );
    } else {
      profilePhotoUrl = null;
    }

    isLoadingProfilePhoto = false;
    update();
  }

  String? _bestPhotoUrl(ProfileResult result) {
    final candidates = <String?>[
      result.profilePhoto,
      result.profile?.profilePhoto,
      result.data?['data']?['profilePhoto']?.toString(),
      result.data?['profilePhoto']?.toString(),
    ];

    for (final candidate in candidates) {
      final value = candidate?.trim() ?? '';
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return value;
      }
    }
    return null;
  }

  String? _withCacheBust(String? url, int? updatedAtMs) {
    final value = (url ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    if (updatedAtMs == null) {
      return value;
    }
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return value;
    }
    final query = Map<String, String>.from(uri.queryParameters);
    query['v'] = updatedAtMs.toString();
    return uri.replace(queryParameters: query).toString();
  }
}
