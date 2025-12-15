import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
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
  // Sample Data - Replace with real data later
  final List<Map<String, dynamic>> _recentMatches = const [
    {'name': 'Sarah P.', 'image': Assets.imagesChatAvatar1, 'online': true},
    {'name': 'Bessie P.', 'image': Assets.imagesChatAvatar1, 'online': true},
    {'name': 'Tanya K.', 'image': Assets.imagesChatAvatar1, 'online': true},
    {'name': 'Lily A.', 'image': Assets.imagesChatAvatar1, 'online': true},
    {'name': 'Yvonne K.', 'image': Assets.imagesChatAvatar1, 'online': true},
    {'name': 'J.', 'image': Assets.imagesChatAvatar1, 'online': false},
  ];
  int _selectedTabIndex = 0; // 0 = Email, 1 = Phone
  final List<String> _tabs = ["All Chats", "Archive Chats"];

  final List<Map<String, dynamic>> _chats = const [
    {
      'name': 'Courtney Tess',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Bessie Taylor',
      'image': Assets.imagesChatAvatar1,
      'message': 'Oh great! see you at 6pm',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Kristin Edward',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Tanya Khan',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Lily Awsap',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Kristin Edward',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': false,
    },
    {
      'name': 'Courtney Tess',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Courtney Tess',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Bessie Taylor',
      'image': Assets.imagesChatAvatar1,
      'message': 'Oh great! see you at 6pm',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Kristin Edward',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Tanya Khan',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Lily Awsap',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Kristin Edward',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': false,
    },
    {
      'name': 'Courtney Tess',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },

    {
      'name': 'Courtney Tess',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Bessie Taylor',
      'image': Assets.imagesChatAvatar1,
      'message': 'Oh great! see you at 6pm',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Kristin Edward',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Tanya Khan',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Lily Awsap',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
    {
      'name': 'Kristin Edward',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': false,
    },
    {
      'name': 'Courtney Tess',
      'image': Assets.imagesChatAvatar1,
      'message': 'Hello! What\'s happening?',
      'time': '12:22 am',
      'unread': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      MyText(
                        text: "Chats",
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
                hint: "Search here...",
                hintColor: kSubText2,
                isObSecure: true,
                radius: 25,
                hintWeight: FontWeight.w400,
                prefix: CommonImageView(
                  imagePath: Assets.imagesMynauiSearch,
                  height: 24,
                ),
              ),

              // ───── Recent Match Label ─────
              MyText(
                text: 'Recent Chats',
                size: 16,
                weight: FontWeight.w400,
                color: kSubText,
              ),

              const Gap(12),

              // ───── Horizontal Recent Matches ─────
              SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _recentMatches.length,
                  itemBuilder: (context, index) {
                    final match = _recentMatches[index];
                    return Bounce(
                      onTap: () {
                        Get.to(() => ChatMessagesScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            CommonImageView(
                              imagePath: match['image'],
                              height: 56,
                              width: 56,
                            ),
                            const Gap(6),
                            MyText(
                              text: match['name'],
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

              // YOUR CUSTOM TABS
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
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
                                  : Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Gap(24),

              // ───── Chat List (Scrollable) ─────
              ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: _chats.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return Bounce(
                    onTap: () {
                      // Navigate to chat detail
                      Get.to(() => ChatMessagesScreen());
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Profile Image
                            CommonImageView(
                              imagePath: chat['image'],
                              height: 50,
                              width: 50,
                            ),
                            const Gap(12),
                            // Name + Message + Time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: chat['name'],
                                    size: 16,
                                    weight: FontWeight.w600,
                                  ),
                                  const Gap(2),
                                  MyText(
                                    text: chat['message'],
                                    size: 14,
                                    color: kSubText2,
                                    maxLines: 1,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(8),
                            // Time + Unread Indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text: chat['time'],
                                  size: 12,
                                  color: Colors.black45,
                                ),
                                if (chat['unread'])
                                  CommonImageView(
                                    imagePath: Assets.imagesDoubleTick,
                                    height: 22,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Gap(8),
                        Divider(
                          color: const Color.fromARGB(255, 201, 201, 201),
                          height: 0,
                        ),
                        Gap(12),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Gap(100),
        ],
      ),
    );
  }
}
