import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/notifications/notifications_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/notifications/notification_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (controller) {
        return Scaffold(
          body: Padding(
            padding: AppSizes.DEFAULT,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Bounce(
                          onTap: () => Get.back(),
                          child: CommonImageView(
                            imagePath: Assets.imagesBack,
                            height: 50,
                          ),
                        ),
                        MyText(
                          text: 'Notifications',
                          size: 16,
                          paddingLeft: 6,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    if (controller.unreadCount > 0)
                      Bounce(
                        onTap: controller.markAllRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: MyText(
                            text: controller.isMarkingAllRead
                                ? 'Marking...'
                                : 'Mark all read',
                            size: 12,
                            weight: FontWeight.w600,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const Gap(8),
                // MyText(
                //   text: 'Unread: ${controller.unreadCount}',
                //   size: 13,
                //   color: kSubText,
                //   weight: FontWeight.w500,
                // ),
                const Gap(12),
                Expanded(
                  child: controller.isLoadingInitial
                      ? const Center(child: CircularProgressIndicator())
                      : controller.notifications.isEmpty
                      ? _buildEmptyView()
                      : RefreshIndicator(
                          onRefresh: controller.refreshNotifications,
                          child: _buildNotificationList(controller),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonImageView(imagePath: Assets.imagesBell, height: 120),
          const Gap(20),
          MyText(
            text: 'No New Notifications',
            size: 18,
            weight: FontWeight.w600,
          ),
          const Gap(6),
          MyText(
            text: 'No alerts right now-keep up the great progress!',
            size: 13,
            color: kSubText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationsController controller) {
    final itemCount =
        controller.notifications.length + (controller.isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: controller.scrollController,
      itemCount: itemCount,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (index >= controller.notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = controller.notifications[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.3,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Bounce(
                    onTap: () => controller.deleteNotification(item.id),
                    child: CommonImageView(
                      imagePath: Assets.imagesTrashNew,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),
            child: Bounce(
              onTap: () => controller.markOneRead(item.id),
              child: _notificationCard(controller, item),
            ),
          ),
        );
      },
    );
  }

  Widget _notificationCard(
    NotificationsController controller,
    NotificationItem item,
  ) {
    final isUnread = !item.isRead;
    final accentColor = _colorForType(item.type);

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? kPrimaryColor.withOpacity(0.08) : kWhite,
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(color: kPrimaryColor.withOpacity(0.25))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              item.title.isEmpty ? 'N' : item.title[0].toUpperCase(),
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: item.title,
                  size: 16,
                  weight: isUnread ? FontWeight.w700 : FontWeight.w600,
                  color: kBlack,
                ),
                const Gap(4),
                MyText(
                  text: item.message,
                  size: 14,
                  weight: FontWeight.w500,
                  color: kSubText,
                ),
              ],
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyText(
                text: controller.formatTime(item.createdAt),
                size: 12,
                weight: FontWeight.w500,
                color: kSubText,
              ),
              if (isUnread) ...[
                const Gap(8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('booking')) {
      return Colors.green;
    }
    if (normalized.contains('dispute')) {
      return Colors.redAccent;
    }
    if (normalized.contains('payment')) {
      return Colors.blueAccent;
    }
    if (normalized.contains('review')) {
      return Colors.amber;
    }
    return kPrimaryColor;
  }
}
