import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/chat/chat_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/chat/chat_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

/// 2.3 GET /users/blocked + 2.2 DELETE /users/block/:userId — lets a user
/// review and undo the blocks they've placed on others.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadBlockedUsers();
    });
  }

  Future<void> _confirmUnblock(BlockedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kWhite,
        title: const MyText(
          text: 'Unblock User',
          size: 16,
          weight: FontWeight.w600,
          color: kBlack,
        ),
        content: MyText(
          text: 'Unblock ${user.fullName}? You will both be able to message each other again.',
          size: 14,
          color: kSubText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const MyText(text: 'Cancel', size: 14, color: kSubText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const MyText(
              text: 'Unblock',
              size: 14,
              color: kPrimaryColor,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.unblockUser(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      init: _controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Padding(
              padding: AppSizes.DEFAULT,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(20),
                  Row(
                    children: [
                      Bounce(
                        onTap: () => Get.back(),
                        child: CommonImageView(
                          imagePath: Assets.imagesBack,
                          height: 50,
                        ),
                      ),
                      const Gap(10),
                      const MyText(
                        text: 'Blocked Users',
                        size: 16,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.loadBlockedUsers,
                      child: _buildBody(controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ChatController controller) {
    if (controller.isLoadingBlockedUsers && controller.blockedUsers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if ((controller.blockedUsersErrorMessage ?? '').isNotEmpty &&
        controller.blockedUsers.isEmpty) {
      return ListView(
        children: [
          const Gap(60),
          MyText(
            text: controller.blockedUsersErrorMessage!,
            size: 14,
            color: kredColor,
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Center(
            child: Bounce(
              onTap: controller.loadBlockedUsers,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const MyText(
                  text: 'Retry',
                  size: 13,
                  color: kPrimaryColor,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (controller.blockedUsers.isEmpty) {
      return ListView(
        children: const [
          Gap(80),
          Center(
            child: MyText(
              text: "You haven't blocked anyone.",
              size: 14,
              color: kSubText,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: controller.blockedUsers.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final user = controller.blockedUsers[index];
        final hasPhoto = (user.profilePhoto ?? '').isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            children: [
              ClipOval(
                child: hasPhoto
                    ? Image.network(
                        user.profilePhoto!,
                        height: 44,
                        width: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => CommonImageView(
                          imagePath: Assets.imagesChatAvatar1,
                          height: 44,
                          width: 44,
                        ),
                      )
                    : CommonImageView(
                        imagePath: Assets.imagesChatAvatar1,
                        height: 44,
                        width: 44,
                      ),
              ),
              const Gap(12),
              Expanded(
                child: MyText(
                  text: user.fullName,
                  size: 15,
                  weight: FontWeight.w600,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              Bounce(
                onTap: controller.isBlockActionLoading
                    ? () {}
                    : () => _confirmUnblock(user),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kredColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const MyText(
                    text: 'Unblock',
                    size: 13,
                    weight: FontWeight.w600,
                    color: kredColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
