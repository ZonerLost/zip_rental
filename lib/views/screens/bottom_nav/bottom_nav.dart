
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/add_item_main.dart';
import 'package:zip_peer/views/screens/booking/booking.dart';
import 'package:zip_peer/views/screens/chat_module/chat_main.dart';
import 'package:zip_peer/views/screens/home/home.dart';
import 'package:zip_peer/views/screens/profile/profile_setting.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  late List<Map<String, dynamic>> items;
  final List<Widget> screens = [
    const HomeScreen(),
    BookingsScreen(),
    AddNewItemScreen(),
    ChatMainScreen(),
    UserProfileScreen(),
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
            ? Assets.imagesNavSearch1
            : Assets.imagesNavSearch2,
      },
      {
        'image': currentIndex == 1
            ? Assets.imagesNavBooking2
            : Assets.imagesNavBooking1,
      },
      {'image': currentIndex == 2 ? Assets.imagesNavAdd : Assets.imagesNavAdd},
      {
        'image': currentIndex == 3
            ? Assets.imagesNavChat2
            : Assets.imagesNavChat1,
      },
      {
        'image': currentIndex == 4
            ? Assets.imagesNavProfile2
            : Assets.imagesNavProfile1,
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
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: index == 2 ? const Offset(0, -5) : Offset.zero,
          child: Bounce(
            onTap: () => _onItemTapped(index),
            child: CommonImageView(
              imagePath: items[index]['image'],
              height: 45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(0),
          _buildNavItem(1),
          _buildNavItem(2),
          _buildNavItem(3),
          _buildNavItem(4),
        ],
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
          screens[currentIndex],
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNavBar()),
        ],
      ),
    );
  }
}
