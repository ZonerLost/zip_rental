// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
    this.participantId,
    this.isArchived = false,
    this.activeItemId,
    this.activeItemTitle,
  });

  final String conversationId;
  final String participantName;
  final String? participantPhoto;
  /// The other participant's user ID — needed to archive/block/report them.
  /// Optional because some call sites only know the conversation, not the
  /// participant, yet; falls back to resolving it from the loaded
  /// conversation once messages/participants are available.
  final String? participantId;
  /// Whether the conversation is currently archived (for the current user)
  /// — determines whether the header menu offers "Archive" or "Unarchive".
  final bool isArchived;
  final String? activeItemId;
  final String? activeItemTitle;

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late final ChatMessagesController _controller;
  late bool _isArchived;

  @override
  void initState() {
    super.initState();
    _isArchived = widget.isArchived;
    _controller = Get.put(
      ChatMessagesController(
        conversationId: widget.conversationId,
        activeItemId: widget.activeItemId,
        activeItemTitle: widget.activeItemTitle,
      ),
      tag: widget.conversationId,
    );
  }

  @override
  void dispose() {
    Get.delete<ChatMessagesController>(tag: widget.conversationId);
    _scrollController.dispose();
    super.dispose();
  }

  /// The other participant's user ID, needed for archive/block/report.
  /// Prefers the ID passed in by the caller; falls back to the sender of
  /// any message that isn't from the current user (works once at least one
  /// message has loaded — true for every conversation reachable from this
  /// screen, since starting one always sends an opening message).
  String? _resolvedParticipantId() {
    if ((widget.participantId ?? '').isNotEmpty) {
      return widget.participantId;
    }
    for (final message in _controller.messages) {
      if (message.senderId.isNotEmpty &&
          message.senderId != _controller.currentUserId) {
        return message.senderId;
      }
    }
    return null;
  }

  /// Whether the other participant is currently blocked — messaging is
  /// disabled locally rather than only relying on the server's 403, so the
  /// user gets an immediate, explicit "you can't message this person"
  /// instead of a failed-send error after the fact.
  bool get _isBlocked {
    if (!Get.isRegistered<ChatController>()) return false;
    final targetId = _resolvedParticipantId();
    return Get.find<ChatController>().isUserBlocked(targetId);
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(12),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: kBlack),
              title: const MyText(
                text: 'Take Photo',
                size: 15,
                weight: FontWeight.w500,
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: kBlack),
              title: const MyText(
                text: 'Choose from Gallery',
                size: 15,
                weight: FontWeight.w500,
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const Gap(12),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    // NOTE: the chat API only documents `POST /chats/:id/messages` with a
    // plain-text `{ content }` body — there's no endpoint to upload/send an
    // image as a message. Rather than build a preview flow that would
    // always dead-end at send time, this stops here and says so clearly.
    Get.snackbar(
      'Not Supported Yet',
      'Sending images in chat needs a backend endpoint that doesn\'t exist '
          'yet (the current API only accepts text messages).',
      duration: const Duration(seconds: 4),
    );
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
                                  value: _isArchived ? 'unarchive' : 'archive',
                                  child: MyText(
                                    text: _isArchived
                                        ? 'Unarchive Chat'
                                        : 'Archive Chat',
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
                            ).then((value) async {
                              if (value == 'archive') {
                                final confirmed = await ArchiveUserBottomSheet(
                                  context,
                                );
                                if (!confirmed ||
                                    !Get.isRegistered<ChatController>()) {
                                  return;
                                }
                                final ok = await Get.find<ChatController>()
                                    .archiveConversation(
                                      widget.conversationId,
                                    );
                                if (ok && mounted) {
                                  setState(() => _isArchived = true);
                                  Get.back();
                                }
                              }
                              if (value == 'unarchive') {
                                if (!Get.isRegistered<ChatController>()) {
                                  return;
                                }
                                final ok = await Get.find<ChatController>()
                                    .unarchiveConversation(
                                      widget.conversationId,
                                    );
                                if (ok && mounted) {
                                  setState(() => _isArchived = false);
                                  Get.snackbar(
                                    'Unarchived',
                                    '${widget.participantName} moved back to All Chats',
                                  );
                                  Get.back();
                                }
                              }
                              if (value == 'block') {
                                final targetId = _resolvedParticipantId();
                                if (targetId == null || targetId.isEmpty) {
                                  Get.snackbar(
                                    'Block Failed',
                                    'Unable to identify this user.',
                                  );
                                  return;
                                }
                                final confirmed = await BlockBottomSheet(
                                  context,
                                );
                                if (!confirmed ||
                                    !Get.isRegistered<ChatController>()) {
                                  return;
                                }
                                final ok = await Get.find<ChatController>()
                                    .blockUser(targetId);
                                if (ok && mounted) {
                                  Get.back();
                                }
                              }
                              if (value == 'report') {
                                final targetId = _resolvedParticipantId();
                                if (targetId == null || targetId.isEmpty) {
                                  Get.snackbar(
                                    'Report Failed',
                                    'Unable to identify this user.',
                                  );
                                  return;
                                }
                                ReportUserBottomSheet(
                                  context,
                                  targetUserId: targetId,
                                  conversationId: widget.conversationId,
                                );
                              }
                            });
                          },
                          child: CommonImageView(
                            imagePath: Assets.imagesMore,
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                    if ((widget.activeItemId ?? '').isNotEmpty ||
                        (widget.activeItemTitle ?? '').isNotEmpty) ...[
                      const Gap(12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: kPrimaryColor,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text:
                                        widget.activeItemTitle?.isNotEmpty ==
                                            true
                                        ? widget.activeItemTitle!
                                        : 'Item reference',
                                    size: 14,
                                    color: kBlack,
                                    weight: FontWeight.w600,
                                  ),
                                  MyText(
                                    text: 'Discussing this item',
                                    size: 12,
                                    color: kSubText2,
                                    weight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          // reverse: true means index 0 is the last message
                          final reversed = controller.messages.reversed
                              .toList();
                          final msg = reversed[index];
                          if (msg.isDeleted) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
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
                              itemId: msg.itemId,
                              itemTitle: msg.itemTitle,
                              time: _formatTime(msg.createdAt),
                              isMe: controller.isMe(msg.senderId),
                              status: msg.status,
                            ),
                          );
                        },
                      ),
              ),

              // ── Input bar ─────────────────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isBlocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.block, size: 18, color: kSubText),
                          const Gap(8),
                          MyText(
                            text: 'You have blocked ${widget.participantName}',
                            size: 13,
                            color: kSubText,
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 12,
                      ),
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
                              suffix: Bounce(
                                onTap: _showImageSourceSheet,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: CommonImageView(
                                    imagePath: Assets.imagesCameraNew,
                                    height: 24,
                                  ),
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
