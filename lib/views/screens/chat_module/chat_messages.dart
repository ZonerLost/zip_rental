// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/chat/chat_controller.dart';
import 'package:zip_peer/controllers/chat/chat_messages_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/screens/chat_module/chat_bubble.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ChatMessagesScreen extends StatefulWidget {
  const ChatMessagesScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantPhoto,
  });

  final String conversationId;
  final String participantName;
  final String? participantPhoto;

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ChatMessagesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ChatMessagesController(conversationId: widget.conversationId),
      tag: widget.conversationId,
    );
  }

  @override
  void dispose() {
    Get.delete<ChatMessagesController>(tag: widget.conversationId);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (widget.participantPhoto ?? '').startsWith('http');

    return GetBuilder<ChatMessagesController>(
      tag: widget.conversationId,
      init: _controller,
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
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
                            const SizedBox(width: 10),
                            ClipOval(
                              child: hasPhoto
                                  ? Image.network(
                                      widget.participantPhoto!,
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          CommonImageView(
                                            imagePath: Assets.imagesChatAvatar,
                                            height: 40,
                                          ),
                                    )
                                  : CommonImageView(
                                      imagePath: Assets.imagesChatAvatar,
                                      height: 40,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: widget.participantName,
                                  size: 16,
                                  color: kBlack,
                                  weight: FontWeight.w600,
                                ),
                                if (controller.otherUserIsTyping)
                                  MyText(
                                    text: 'typing...',
                                    size: 13,
                                    color: kPrimaryColor,
                                    weight: FontWeight.w400,
                                  )
                                else
                                  MyText(
                                    text: 'Last seen 08:00 PM',
                                    size: 16,
                                    color: kSubText2,
                                    weight: FontWeight.w400,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Bounce(
                          onTap: () {
                            showMenu<String>(
                              context: context,
                              color: kWhite,
                              position: RelativeRect.fromLTRB(100, 120, 20, 0),
                              items: [
                                PopupMenuItem(
                                  value: 'archive',
                                  child: MyText(
                                    text: 'Archive User',
                                    color: kBlack,
                                    size: 14,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'block',
                                  child: MyText(
                                    text: 'Block User',
                                    color: kBlack,
                                    size: 14,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'report',
                                  child: MyText(
                                    text: 'Report User',
                                    color: kBlack,
                                    size: 14,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ).then((value) {
                              if (value == 'archive') {
                                ArchiveUserBottomSheet(
                                  context,
                                  onConfirm: () {
                                    if (Get.isRegistered<ChatController>()) {
                                      Get.find<ChatController>().setArchived(
                                        widget.conversationId,
                                        true,
                                      );
                                    }
                                    Get.back();
                                  },
                                );
                              }
                              if (value == 'block') BlockBottomSheet(context);
                              if (value == 'report') ReportUserBottomSheet(context);
                            });
                          },
                          child: CommonImageView(
                            imagePath: Assets.imagesMore,
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Messages ──────────────────────────────────────────────────
              Expanded(
                child: controller.isLoading && controller.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : controller.errorMessage != null &&
                            controller.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MyText(
                                  text: controller.errorMessage!,
                                  size: 14,
                                  color: kSubText,
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(12),
                                Bounce(
                                  onTap: controller.loadMessages,
                                  child: MyText(
                                    text: 'Retry',
                                    size: 14,
                                    color: kPrimaryColor,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            itemCount: controller.messages.length,
                            itemBuilder: (context, index) {
                              // reverse: true means index 0 is the last message
                              final reversed = controller.messages.reversed
                                  .toList();
                              final msg = reversed[index];
                              if (msg.isDeleted) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Center(
                                    child: MyText(
                                      text: 'Message deleted',
                                      size: 12,
                                      color: kSubText2,
                                    ),
                                  ),
                                );
                              }
                              return GestureDetector(
                                onLongPress: controller.isMe(msg.senderId)
                                    ? () => _showDeleteDialog(msg.id)
                                    : null,
                                child: ChatBubble(
                                  message: msg.content,
                                  time: _formatTime(msg.createdAt),
                                  isMe: controller.isMe(msg.senderId),
                                  showCheck: controller.isMe(msg.senderId),
                                ),
                              );
                            },
                          ),
              ),

              // ── Input bar ─────────────────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 12),
                    decoration: BoxDecoration(
                      color: kWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: controller.messageInputController,
                            marginBottom: 0,
                            hint: 'Type your message here...',
                            hintColor: kBlack,
                            alwaysShowLabel: true,
                            radius: 24,
                            backgroundColor: const Color(0xFFF4F4F4),
                            suffix: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CommonImageView(
                                imagePath: Assets.imagesCameraNew,
                                height: 24,
                              ),
                            ),
                            onChanged: controller.onMessageInputChanged,
                          ),
                        ),
                        const Gap(8),
                        Bounce(
                          onTap: () async {
                            await controller.sendMessage();
                            _scrollToBottom();
                          },
                          child: CommonImageView(
                            imagePath: Assets.imagesSend,
                            height: 52,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(String messageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kWhite,
        title: const MyText(
          text: 'Delete Message',
          size: 16,
          weight: FontWeight.w600,
          color: kBlack,
        ),
        content: const MyText(
          text: 'Delete this message?',
          size: 14,
          color: kSubText,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const MyText(text: 'Cancel', size: 14, color: kSubText),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _controller.deleteMessage(messageId);
            },
            child: const MyText(
              text: 'Delete',
              size: 14,
              color: Colors.red,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
