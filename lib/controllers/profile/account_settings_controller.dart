import 'package:get/get.dart';

class AccountSettingsController extends GetxController {
  bool notificationsEnabled = true;

  void onNotificationToggle(bool value) {
    notificationsEnabled = value;
    update();
  }
}
