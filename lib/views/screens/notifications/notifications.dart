import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showList = false;

  final List<Map<String, String>> notifications = [
    {
      'title': 'Account Created!',
      'subtitle': 'Your account has been created.',
      'time': '12:33 am',
    },
    {
      'title': 'Review Plan',
      'subtitle': 'Please review your new credit plan.',
      'time': '12:33 am',
    },
    {
      'title': 'New Message',
      'subtitle': 'Your advisor sent you a message.',
      'time': '12:33 am',
    },
    {
      'title': 'Dispute Letter',
      'subtitle': 'Your next dispute letter is ready.',
      'time': '12:33 am',
    },
    {
      'title': 'New Message',
      'subtitle': 'Your advisor sent you a message.',
      'time': 'Yesterday',
    },
    {
      'title': 'Review Plan',
      'subtitle': 'Please review your new credit plan.',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppSizes.DEFAULT,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(50),
            // Top Bar
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
                  text: "Notifications",
                  size: 16,
                  paddingLeft: 6,
                  weight: FontWeight.w500,
                ),
              ],
            ),
            Gap(20),

            // Animated section
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _showList ? _buildNotificationList() : _buildEmptyView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Bounce(
            onTap: () {
              setState(() {
                _showList = true;
              });
            },
            child: CommonImageView(imagePath: Assets.imagesBell, height: 120),
          ),
          const Gap(20),
          MyText(
            text: "No New Notifications",
            size: 18,
            weight: FontWeight.w600,
          ),
          const Gap(6),
          MyText(
            text: "No alerts right now—keep up the great progress!",
            size: 13,
            color: kSubText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      key: const ValueKey('list'),
      itemCount: notifications.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final item = notifications[index];

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
                    child: CommonImageView(
                      imagePath: Assets.imagesTrashNew,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(16),
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
                      color:
                          (item['title']!.startsWith('A')
                                  ? Colors.green
                                  : Colors.amber)
                              .withOpacity(0.2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item['title']![0].toUpperCase(),
                      style: TextStyle(
                        color: item['title']!.startsWith('A')
                            ? Colors.green
                            : Colors.amber,
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
                          text: item['title']!,
                          size: 16,
                          weight: FontWeight.w600,
                          color: kBlack,
                        ),
                        const Gap(4),
                        MyText(
                          text: item['subtitle']!,
                          size: 14,
                          weight: FontWeight.w500,
                          color: kSubText,
                        ),
                      ],
                    ),
                  ),
                  MyText(
                    text: item['time']!,
                    size: 14,
                    weight: FontWeight.w500,
                    color: kSubText,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
