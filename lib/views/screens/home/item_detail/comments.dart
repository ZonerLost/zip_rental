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
  final List<Comment> _comments = [
    Comment(
      userName: "Melisa Thomas",
      timeAgo: "2 days ago",
      rating: 4.7,
      commentText:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      avatarPath: Assets.imagesShoes2, // Replace with actual avatar path
    ),
    Comment(
      userName: "Melisa Thomas",
      timeAgo: "2 days ago",
      rating: 4.7,
      commentText:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      avatarPath: Assets.imagesShoes2,
    ),
    Comment(
      userName: "Melisa Thomas",
      timeAgo: "2 days ago",
      rating: 4.7,
      commentText:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
      avatarPath: Assets.imagesShoes2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          Gap(20),
          // Comments List
          ListView.separated(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (context, index) => Gap(20),
            itemBuilder: (context, index) {
              return CommentCard(comment: _comments[index]);
            },
          ),
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
                    text: "${comment.rating} ratings",
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          Gap(6),
          Divider(color: kDividerColor), Gap(6),
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
