import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/bottom_nav_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/add_item_main.dart';
import 'package:zip_peer/views/screens/booking/booking.dart';
import 'package:zip_peer/views/screens/chat_module/chat_main.dart';
import 'package:zip_peer/views/screens/home/home.dart';
import 'package:zip_peer/views/screens/listing_module/my_listed.dart';
import 'package:zip_peer/views/screens/profile/profile_setting.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final BottomNavController _navController;

  final List<Widget> screens = [
    const HomeScreen(),
    const BookingsScreen(),
    const AddNewItemScreen(),
    const MyListedItemsScreen(),
    const ChatMainScreen(),
    const UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // `permanent: true` + never deleting here on purpose: BottomNavBar is
    // re-created via Get.offAll() from many places (login, signup, add-item
    // success, booking confirmation, ...), and during that transition the
    // outgoing and incoming BottomNavBar instances are briefly mounted at
    // the same time. Get.put() reuses an already-registered instance rather
    // than replacing it, so if this dispose() deleted the controller, it
    // could rip it out from under a newer BottomNavBar that's still relying
    // on it — causing "BottomNavController not found" the moment any screen
    // (e.g. My Listings) calls `BottomNavController.to`. The controller is
    // explicitly torn down on logout instead (see LogoutBottomSheet).
    _navController = Get.put(BottomNavController(), permanent: true);
    _navController.currentIndex = widget.initialIndex;
  }

  List<Map<String, dynamic>> _buildItems(int currentIndex) {
    return [
      {
        'image': currentIndex == 0
            ? Assets.imagesBottomNavBarSearch
            : Assets.imagesBottomNavBarSearch2,
        'label': 'Search',
      },
      {
        'image': currentIndex == 1
            ? Assets.imagesBottomNavBarBooking2
            : Assets.imagesBottomNavBarBooking,
        'label': 'Bookings',
      },
      {
        'image': currentIndex == 2
            ? Assets.imagesNewAddNav2
            : Assets.imagesNewAddNav,
        'label': 'Add Item',
      },
      {
        'image': currentIndex == 3
            ? Assets.imagesBottomNavBarChat2
            : Assets.imagesBottomNavBarChat,
        'label': 'My Listings',
      },
      {
        'image': currentIndex == 4
            ? Assets.imagesBottomNavBarListing2
            : Assets.imagesBottomNavBarLisitng,
        'label': 'Chats',
      },
      {'isProfile': true, 'label': 'Dashboard'},
    ];
  }

  Widget _buildNavItem(
    int index,
    int currentIndex,
    List<Map<String, dynamic>> items,
    BottomNavController nav,
  ) {
    final isSelected = currentIndex == index;
    final isProfileItem = items[index]['isProfile'] == true;
    final isChatsItem = items[index]['label'] == 'Chats';
    return Bounce(
      onTap: () => _navController.switchTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (isProfileItem)
                  _buildProfileAvatar(nav.profilePhotoUrl, isSelected)
                else
                  CommonImageView(
                    imagePath: items[index]['image'],
                    fit: BoxFit.cover,
                    height: 24,
                  ),
                if (isChatsItem && nav.unreadChatCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: kWhite, width: 1.5),
                      ),
                      child: MyText(
                        text: nav.unreadChatCount > 99
                            ? '99+'
                            : '${nav.unreadChatCount}',
                        color: kWhite,
                        size: 9,
                        weight: FontWeight.w700,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // FittedBox shrinks longer labels (e.g. "My Listings") to fit
            // the item's share of the row instead of overflowing it.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: MyText(
                text: items[index]['label'],
                color: isSelected ? kPrimaryColor : Colors.grey.shade600,
                weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                size: 11,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? url, bool isSelected) {
    final hasPhoto = (url ?? '').trim().isNotEmpty;
    final borderColor = isSelected ? kPrimaryColor : Colors.grey.shade300;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipOval(
        child: hasPhoto
            ? CommonImageView(
                url: url,
                fit: BoxFit.cover,
                height: 24,
                width: 24,
                placeHolder: Assets.imagesPersonIcon,
              )
            : Container(
                color: Colors.grey.shade100,
                child: CommonImageView(
                  imagePath: Assets.imagesPersonIcon,
                  fit: BoxFit.contain,
                  height: 14,
                  width: 14,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavController>(
      init: _navController,
      builder: (nav) {
        final items = _buildItems(nav.currentIndex);
        // Devices on classic 3-button navigation (as opposed to gesture nav)
        // reserve a system bar at the bottom of the screen that this Stack's
        // edge-to-edge body draws behind. Without this inset, the system
        // buttons sit on top of our own nav row instead of below it.
        final systemNavInset = MediaQuery.of(context).padding.bottom;
        return Scaffold(
          backgroundColor: kWhite,
          extendBody: true,
          body: Stack(
            children: [
              screens[nav.currentIndex],
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 100 + systemNavInset,
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8 + systemNavInset,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      6,
                      (index) => Expanded(
                        child: _buildNavItem(
                          index,
                          nav.currentIndex,
                          items,
                          nav,
                        ),
                      ),
                    ),
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
