import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  int _selectedTab = 0; // 0 = Item Comments, 1 = Owner Comments

  final List<Comment> _itemComments = [
    Comment(
      userName: "Melisa Thomas",
      timeAgo: "2 days ago",
      rating: 4.7,
      commentText:
          "Great item! Works perfectly and exactly as described. Would definitely rent again.",
      avatarPath: Assets.imagesShoes2,
    ),
    Comment(
      userName: "John Smith",
      timeAgo: "5 days ago",
      rating: 4.5,
      commentText:
          "Item was in good condition. Had a small issue but overall satisfied with the rental experience.",
      avatarPath: Assets.imagesShoes2,
    ),
    Comment(
      userName: "Sarah Johnson",
      timeAgo: "1 week ago",
      rating: 5.0,
      commentText:
          "Perfect! The item exceeded my expectations. Clean, well-maintained, and worked flawlessly throughout the rental period.",
      avatarPath: Assets.imagesShoes2,
    ),
  ];

  final List<Comment> _ownerComments = [
    Comment(
      userName: "Mike Wilson",
      timeAgo: "3 days ago",
      rating: 4.8,
      commentText:
          "Excellent owner! Very responsive and professional. Made the rental process smooth and easy.",
      avatarPath: Assets.imagesShoes2,
    ),
    Comment(
      userName: "Emily Brown",
      timeAgo: "1 week ago",
      rating: 4.9,
      commentText:
          "Great communication and very accommodating. Would definitely rent from this owner again!",
      avatarPath: Assets.imagesShoes2,
    ),
    Comment(
      userName: "David Lee",
      timeAgo: "2 weeks ago",
      rating: 5.0,
      commentText:
          "Outstanding owner! Quick to respond, flexible with pickup times, and the item was exactly as advertised. Highly recommended!",
      avatarPath: Assets.imagesShoes2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentComments = _selectedTab == 0 ? _itemComments : _ownerComments;

    return Scaffold(
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
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
              Gap(16),
              MyText(text: "Comments", size: 20, weight: FontWeight.w600),
            ],
          ),
          Gap(24),

          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kBlack.withOpacity(0.1), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Bounce(
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0
                                ? kPrimaryColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: MyText(
                          text: 'Item Comments',
                          size: 16,
                          color: _selectedTab == 0 ? kBlack : kSubText,
                          weight: _selectedTab == 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Bounce(
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1
                                ? kPrimaryColor
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: MyText(
                          text: 'Owner Comments',
                          size: 16,
                          color: _selectedTab == 1 ? kBlack : kSubText,
                          weight: _selectedTab == 1
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(24),

          // Comments count
          MyText(
            text:
                '${currentComments.length} ${_selectedTab == 0 ? 'Item' : 'Owner'} Comments',
            size: 16,
            color: kSubText,
            weight: FontWeight.w500,
          ),
          Gap(20),

          // Comments List
          ListView.separated(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: currentComments.length,
            separatorBuilder: (context, index) => Gap(20),
            itemBuilder: (context, index) {
              return CommentCard(comment: currentComments[index]);
            },
          ),
          Gap(20),
        ],
      ),
    );
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar, Name, Time, Rating
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kbackground,
                ),
                child: ClipOval(
                  child: CommonImageView(
                    imagePath: comment.avatarPath,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Gap(12),
              // Name and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: comment.userName,
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                    Gap(4),
                    MyText(text: comment.timeAgo, size: 14, color: kSubText),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  CommonImageView(imagePath: Assets.imagesStar, height: 20),
                  Gap(4),
                  MyText(
                    text: "${comment.rating}",
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          Gap(6),
          Divider(color: kDividerColor),
          Gap(6),
          // Comment Text
          MyText(text: comment.commentText, size: 14, color: kSubText),
        ],
      ),
    );
  }
}

class Comment {
  final String userName;
  final String timeAgo;
  final double rating;
  final String commentText;
  final String avatarPath;

  Comment({
    required this.userName,
    required this.timeAgo,
    required this.rating,
    required this.commentText,
    required this.avatarPath,
  });
}
