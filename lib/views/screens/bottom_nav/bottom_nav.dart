import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/constants/app_colors.dart';
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
  int? currentIndex = 0;
  late List<Map<String, dynamic>> items;
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
    currentIndex = widget.initialIndex;
    updateItems();
  }

  void updateItems() {
    items = [
      {
        'image': currentIndex == 0
            ? Assets.imagesBottomNavBarSearch
            : Assets.imagesBottomNavBarSearch2,
        'label': "Search",
      },
      {
        'image': currentIndex == 1
            ? Assets.imagesBottomNavBarBooking2
            : Assets.imagesBottomNavBarBooking,
        'label': "Bookings",
      },
      {
        'image': currentIndex == 2
            ? Assets.imagesNewAddNav2
            : Assets.imagesNewAddNav,
        'label': "Add Item",
      },
      {
        'image': currentIndex == 3
            ? Assets.imagesBottomNavBarChat2
            : Assets.imagesBottomNavBarChat,
        'label': "My Listings",
      },
      {
        'image': currentIndex == 4
            ? Assets.imagesBottomNavBarListing2
            : Assets.imagesBottomNavBarLisitng,
        'label': "Chats",
      },
      {
        'image': currentIndex == 5
            ? Assets.imagesBottomNavBarDashboard2
            : Assets.imagesBottomNavBarDashboard,
        'label': "Dashboard",
      },
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
      updateItems();
    });
  }

  Widget _buildNavItem(int index) {
    final isSelected = currentIndex == index;

    return Bounce(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImageView(
              imagePath: items[index]['image'],
              fit: BoxFit.cover,
              height: 24,
            ),
            const SizedBox(height: 6),
            MyText(
              text: items[index]['label'],
              color: isSelected ? kPrimaryColor : Colors.grey.shade600,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
              size: 11,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(6, (index) => _buildNavItem(index)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      extendBody: true,
      body: Stack(
        children: [
          screens[currentIndex!],
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNavBar()),
        ],
      ),
    );
  }
}
