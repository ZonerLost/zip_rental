import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zip_peer/services/notifications/notifications_service.dart';

class AccountSettingsController extends GetxController {
  AccountSettingsController({NotificationsService? notificationsService})
    : _notificationsService = notificationsService ?? NotificationsService();

  final NotificationsService _notificationsService;

  bool notificationsEnabled = true;
  bool isUpdatingNotificationPreference = false;

  @override
  void onInit() {
    super.onInit();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final savedPreference =
        await _notificationsService.getNotificationsEnabledPreference();
    // The user may have revoked the OS-level permission from system
    // settings without ever touching this toggle — reflect that here so the
    // switch never claims to be "on" when nothing will actually arrive.
    final osPermissionGranted = await Permission.notification.status.isGranted;

    notificationsEnabled = savedPreference && osPermissionGranted;
    if (notificationsEnabled != savedPreference) {
      await _notificationsService.setNotificationsEnabledPreference(
        notificationsEnabled,
      );
    }
    update();
  }

  Future<void> onNotificationToggle(bool value) async {
    if (isUpdatingNotificationPreference) return;
    isUpdatingNotificationPreference = true;
    update();

    if (value) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        notificationsEnabled = false;
        await _notificationsService.setNotificationsEnabledPreference(false);
        isUpdatingNotificationPreference = false;
        update();

        Get.snackbar(
          'Notifications Blocked',
          status.isPermanentlyDenied
              ? 'Notifications are blocked at the system level. Enable them from your device settings.'
              : 'Notification permission was not granted.',
          mainButton: status.isPermanentlyDenied
              ? TextButton(
                  onPressed: openAppSettings,
                  child: const Text('Settings'),
                )
              : null,
        );
        return;
      }

      notificationsEnabled = true;
      await _notificationsService.setNotificationsEnabledPreference(true);
      // Register this device for push again now that it's back on.
      await _notificationsService.syncSavedFcmTokenOnLaunch();
    } else {
      notificationsEnabled = false;
      await _notificationsService.setNotificationsEnabledPreference(false);
    }

    isUpdatingNotificationPreference = false;
    update();
  }
}
