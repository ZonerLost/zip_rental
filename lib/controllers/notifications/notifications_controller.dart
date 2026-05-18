import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/models/notifications/notification_models.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';

class NotificationsController extends GetxController {
  NotificationsController({NotificationsService? notificationsService})
    : _notificationsService = notificationsService ?? NotificationsService();

  final NotificationsService _notificationsService;

  final ScrollController scrollController = ScrollController();

  final List<NotificationItem> notifications = <NotificationItem>[];
  int unreadCount = 0;
  int currentPage = 1;
  int pageSize = 20;
  bool hasMore = true;

  bool isLoadingInitial = false;
  bool isLoadingMore = false;
  bool isMarkingAllRead = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadNotifications(reset: true);
  }

  Future<void> loadNotifications({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      hasMore = true;
      notifications.clear();
      isLoadingInitial = true;
      update();
    } else {
      if (isLoadingMore || !hasMore) {
        return;
      }
      isLoadingMore = true;
      update();
    }

    final targetPage = currentPage;
    final result = await _notificationsService.getNotifications(
      page: targetPage,
      limit: pageSize,
    );

    if (!result.success || result.data == null) {
      if (reset) {
        isLoadingInitial = false;
      } else {
        isLoadingMore = false;
      }
      update();
      if (!reset) {
        Get.snackbar('Notifications', result.message);
      }
      return;
    }

    final pageData = result.data!;
    if (reset) {
      notifications
        ..clear()
        ..addAll(pageData.items);
    } else {
      notifications.addAll(pageData.items);
    }

    unreadCount = pageData.unreadCount;
    currentPage = targetPage + 1;

    final reachedTotalPages =
        pageData.totalPages > 0 && pageData.page >= pageData.totalPages;
    final effectiveLimit = pageData.limit > 0 ? pageData.limit : pageSize;
    final reachedByItemsCount = pageData.items.length < effectiveLimit;
    hasMore = !(reachedTotalPages || reachedByItemsCount);

    isLoadingInitial = false;
    isLoadingMore = false;
    update();
  }

  Future<void> refreshNotifications() => loadNotifications(reset: true);

  Future<void> markAllRead() async {
    if (isMarkingAllRead) {
      return;
    }
    isMarkingAllRead = true;
    update();

    final result = await _notificationsService.markAllRead();
    isMarkingAllRead = false;
    if (!result.success) {
      update();
      Get.snackbar('Mark All Read Failed', result.message);
      return;
    }

    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    unreadCount = 0;
    update();
  }

  Future<void> markOneRead(String notificationId) async {
    final index = notifications.indexWhere((e) => e.id == notificationId);
    if (index < 0) {
      return;
    }
    if (notifications[index].isRead) {
      return;
    }

    final result = await _notificationsService.markOneRead(notificationId);
    if (!result.success) {
      Get.snackbar('Mark Read Failed', result.message);
      return;
    }

    notifications[index] = notifications[index].copyWith(isRead: true);
    if (unreadCount > 0) {
      unreadCount -= 1;
    }
    update();
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = notifications.indexWhere((e) => e.id == notificationId);
    if (index < 0) {
      return;
    }

    final wasUnread = !notifications[index].isRead;
    final removed = notifications.removeAt(index);
    if (wasUnread && unreadCount > 0) {
      unreadCount -= 1;
    }
    update();

    final result = await _notificationsService.deleteNotification(
      notificationId,
    );
    if (result.success) {
      return;
    }

    notifications.insert(index, removed);
    if (wasUnread) {
      unreadCount += 1;
    }
    update();
    Get.snackbar('Delete Failed', result.message);
  }

  Future<void> saveFcmToken(String token) async {
    final result = await _notificationsService.saveFcmToken(token);
    if (!result.success) {
      Get.snackbar('FCM Token Sync Failed', result.message);
    }
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final now = DateTime.now();
    final local = dateTime.toLocal();
    final difference = now.difference(local);
    if (difference.inDays >= 1) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      }
      return DateFormat('MMM d').format(local);
    }
    return DateFormat.jm().format(local);
  }

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      unawaited(loadNotifications());
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
