import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/chat/chat_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/chat/chat_models.dart';
import 'package:zip_peer/views/screens/chat_module/chat_messages.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All Chats', 'Archive Chats'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('hh:mm a').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('MM/dd').format(dt);
  }

  List<ChatConversation> _filtered(List<ChatConversation> all) {
    if (_searchQuery.isEmpty) return all;
    return all.where((c) {
      final other = c.otherParticipant(_controller.currentUserId ?? '');
      final name = other?.fullName.toLowerCase() ?? '';
      final lastMsg = c.lastMessage?.content.toLowerCase() ?? '';
      return name.contains(_searchQuery) || lastMsg.contains(_searchQuery);
    }).toList();
  }

  void _openConversation(ChatConversation conv) {
    final currentUserId = _controller.currentUserId ?? '';
    final other = conv.otherParticipant(currentUserId);
    _controller.resetUnreadCount(conv.id);
    Get.to(
      () => ChatMessagesScreen(
        conversationId: conv.id,
        participantName: other?.fullName ?? 'User',
        participantPhoto: other?.profilePhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      init: _controller,
      builder: (controller) {
        final allConvs = controller.conversations;
        final filtered = _filtered(allConvs);
        final currentUserId = controller.currentUserId ?? '';

        return Scaffold(
          body: AnimatedListView(
            padding: const EdgeInsets.all(20),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const MyText(
                            text: 'Chats',
                            size: 20,
                            weight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Gap(20),

                  // ───── Search Bar ─────
                  MyTextField(
                    controller: _searchController,
                    hint: 'Search here...',
                    hintColor: kSubText2,
                    isObSecure: false,
                    radius: 25,
                    hintWeight: FontWeight.w400,
                    prefix: CommonImageView(
                      imagePath: Assets.imagesMynauiSearch,
                      height: 24,
                    ),
                    onChanged: (_) {},
                  ),

                  // ───── Recent Chats (hidden when no conversations) ─────
                  if (allConvs.isNotEmpty) ...[
                    const MyText(
                      text: 'Recent Chats',
                      size: 16,
                      weight: FontWeight.w400,
                      color: kSubText,
                    ),

                    const Gap(12),

                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemCount: allConvs.length,
                              itemBuilder: (context, index) {
                                final conv = allConvs[index];
                                final other =
                                    conv.otherParticipant(currentUserId);
                                final hasPhoto = (other?.profilePhoto ?? '')
                                    .startsWith('http');
                                return Bounce(
                                  onTap: () => _openConversation(conv),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Column(
                                      children: [
                                        ClipOval(
                                          child: hasPhoto
                                              ? Image.network(
                                                  other!.profilePhoto!,
                                                  height: 56,
                                                  width: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      CommonImageView(
                                                        imagePath: Assets
                                                            .imagesChatAvatar1,
                                                        height: 56,
                                                        width: 56,
                                                      ),
                                                )
                                              : CommonImageView(
                                                  imagePath:
                                                      Assets.imagesChatAvatar1,
                                                  height: 56,
                                                  width: 56,
                                                ),
                                        ),
                                        const Gap(6),
                                        MyText(
                                          text: other?.firstName ?? 'User',
                                          size: 14,
                                          weight: FontWeight.w500,
                                          color: kBlack,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],

                  // ───── Tabs ─────
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: List.generate(_tabs.length, (index) {
                        final isSelected = _selectedTabIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTabIndex = index),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kPrimaryColor.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: MyText(
                                  text: _tabs[index],
                                  size: 14,
                                  weight: FontWeight.w600,
                                  color: isSelected
                                      ? kPrimaryColor
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Gap(24),

                  // ───── Loading / Error / Empty ─────
                  if (controller.isLoading && allConvs.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.errorMessage != null && allConvs.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const Gap(40),
                          MyText(
                            text: controller.errorMessage!,
                            size: 14,
                            color: kSubText,
                            textAlign: TextAlign.center,
                          ),
                          const Gap(16),
                          Bounce(
                            onTap: controller.loadConversations,
                            child: const MyText(
                              text: 'Retry',
                              size: 14,
                              color: kPrimaryColor,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (filtered.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: MyText(
                          text: 'No conversations yet',
                          size: 14,
                          color: kSubText,
                        ),
                      ),
                    )
                  else

                  // ───── Chat List ─────
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final conv = filtered[index];
                        final other = conv.otherParticipant(currentUserId);
                        final hasPhoto = (other?.profilePhoto ?? '')
                            .startsWith('http');
                        final lastMsg = conv.lastMessage?.isDeleted == true
                            ? 'Message deleted'
                            : conv.lastMessage?.content ?? '';
                        final hasUnread = conv.unreadCount > 0;

                        return Bounce(
                          onTap: () => _openConversation(conv),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Avatar
                                  ClipOval(
                                    child: hasPhoto
                                        ? Image.network(
                                            other!.profilePhoto!,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                CommonImageView(
                                                  imagePath:
                                                      Assets.imagesChatAvatar1,
                                                  height: 50,
                                                  width: 50,
                                                ),
                                          )
                                        : CommonImageView(
                                            imagePath: Assets.imagesChatAvatar1,
                                            height: 50,
                                            width: 50,
                                          ),
                                  ),
                                  const Gap(12),
                                  // Name + last message
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: other?.fullName ?? 'User',
                                          size: 16,
                                          weight: FontWeight.w600,
                                        ),
                                        const Gap(2),
                                        MyText(
                                          text: lastMsg,
                                          size: 14,
                                          color: kSubText2,
                                          maxLines: 1,
                                          textOverflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(8),
                                  // Time + unread badge
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      MyText(
                                        text: _formatTime(conv.updatedAt),
                                        size: 12,
                                        color: Colors.black45,
                                      ),
                                      if (hasUnread)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: MyText(
                                            text: '${conv.unreadCount}',
                                            size: 11,
                                            color: Colors.white,
                                            weight: FontWeight.w600,
                                          ),
                                        )
                                      else
                                        CommonImageView(
                                          imagePath: Assets.imagesDoubleTick,
                                          height: 22,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(8),
                              const Divider(
                                color: Color.fromARGB(255, 201, 201, 201),
                                height: 0,
                              ),
                              const Gap(12),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const Gap(100),
            ],
          ),
        );
      },
    );
  }
}
