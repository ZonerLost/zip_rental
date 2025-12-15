// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets_2.dart';
import 'package:zip_peer/views/screens/chat_module/chat_bubble.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class ChatMessagesScreen extends StatefulWidget {
  const ChatMessagesScreen({super.key});

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final ScrollController _scrollController = ScrollController();

  // Sample chat messages
  final List<Map<String, dynamic>> _messages = [
    {"text": "I'm doing good", "isMe": true, "time": "12:22 am"},

    {
      "text":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt",
      "isMe": false,
      "time": "12:22 am",
    },
    {
      "text": "Hello there ! Hope you are doing well",
      "isMe": false,
      "time": "12:22 am",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                        CommonImageView(
                          imagePath: Assets.imagesChatAvatar,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: "Courtney Tess",
                              size: 16,
                              color: kBlack,
                              weight: FontWeight.w600,
                            ),
                            MyText(
                              text: "Last seen 08:00 PM",
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
                        showMenu(
                          context: context,
                          color: kWhite,

                          position: RelativeRect.fromLTRB(
                            100,
                            120,
                            20,
                            0,
                          ), // adjust if needed
                          items: [
                            PopupMenuItem(
                              child: MyText(
                                text: "Clear Chat",
                                color: kBlack,
                                size: 14,
                                weight: FontWeight.w500,
                              ),
                              value: "clear",
                            ),
                            PopupMenuItem(
                              child: MyText(
                                text: "Block User",
                                color: kBlack,
                                size: 14,
                                weight: FontWeight.w500,
                              ),
                              value: "block",
                            ),
                            PopupMenuItem(
                              child: MyText(
                                text: "Report User",
                                color: kBlack,
                                size: 14,
                                weight: FontWeight.w500,
                              ),
                              value: "report",
                            ),
                          ],
                        ).then((value) {
                          if (value == "clear") {
                            // your clear action
                          } else if (value == "block") {
                            BlockBottomSheet(context);
                          } else if (value == "report") {
                            ReportUserBottomSheet(context);
                            // your report action
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
              ],
            ),
          ),
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  message: msg["text"],
                  time: msg["time"],
                  isMe: msg["isMe"],
                  showCheck: true,
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                decoration: BoxDecoration(
                  color: kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Text Field
                    Expanded(
                      child: // Email Field
                      MyTextField(
                        marginBottom: 0,
                        hint: "Type your message here...",
                        hintColor: kBlack,
                        alwaysShowLabel: true,
                        radius: 24,
                        backgroundColor: Color(0xFFF4F4F4),
                        suffix: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CommonImageView(
                            imagePath: Assets.imagesCameraNew,
                            height: 24,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    Gap(8),

                    // Camera Button

                    // Send Button
                    Bounce(
                      onTap: () {},
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
  }
}
