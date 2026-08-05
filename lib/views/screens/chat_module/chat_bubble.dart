// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String? itemId;
  final String? itemTitle;
  final String time;
  final bool isMe;
  final bool showCheck; // Whether to show the orange double tick

  const ChatBubble({
    super.key,
    required this.message,
    this.itemId,
    this.itemTitle,
    required this.time,
    required this.isMe,
    this.showCheck = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Chat Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? kPrimaryColor : kWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((itemId ?? '').isNotEmpty || (itemTitle ?? '').isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withOpacity(0.16)
                          : kPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: MyText(
                      text: itemTitle?.isNotEmpty == true
                          ? itemTitle!
                          : 'Item reference',
                      size: 12,
                      color: isMe ? kWhite : kPrimaryColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                MyText(
                  text: message,
                  size: 15,
                  color: isMe ? kWhite : kBlack,
                  weight: FontWeight.w400,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Gap(4),
          // Timestamp + Checkmark
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                text: time,
                size: 12,
                paddingTop: 4,
                color: kSubText2,
                weight: FontWeight.w500,
              ),
              if (showCheck) ...[
                Gap(4),
                CommonImageView(imagePath: Assets.imagesDoubleTick, height: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
