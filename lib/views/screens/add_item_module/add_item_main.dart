
// import 'package:bounce/bounce.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:zip_peer/constants/app_colors.dart';
// import 'package:zip_peer/constants/app_sizes.dart';
// import 'package:zip_peer/generated/assets.dart';
// import 'package:zip_peer/views/screens/add_item_module/address_additem.dart';
// import 'package:zip_peer/views/screens/add_item_module/delivery_item.dart';
// import 'package:zip_peer/views/widget/common_image_view_widget.dart';
// import 'package:zip_peer/views/widget/custom_animated_column.dart';
// import 'package:zip_peer/views/widget/custom_dropdown.dart';
// import 'package:zip_peer/views/widget/my_button_new.dart';
// import 'package:zip_peer/views/widget/my_text_widget.dart';
// import 'package:zip_peer/views/widget/my_textfeild.dart';

// class AddNewItemScreen extends StatefulWidget {
//   const AddNewItemScreen({super.key});

//   @override
//   State<AddNewItemScreen> createState() => _AddNewItemScreenState();
// }

// class _AddNewItemScreenState extends State<AddNewItemScreen> {
//   int? _selectedTabIndex; // Changed to nullable
//   final List<String> _tabs = ['Delivery only', 'Pickup only', 'Enable Both'];

//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   String _selectedCategory = 'Footwear';
//   String _selectedCondition = 'used, good condition';
//   String _selectedPriceType = 'Per Day';

//   bool _showError = false; // new flag

//   @override
//   void initState() {
//     super.initState();
//     _titleController.text = 'Nike Jordan 6';
//     _priceController.text = '\$45.00';
//     _descriptionController.text = 'Lorem ipsum dolor ist amet';
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   void _handleContinue() {
//     if (_selectedTabIndex == null) {
//       setState(() {
//         _showError = true; // show error message
//       });
//       return;
//     }

//     // Navigate based on selection
//     if (_selectedTabIndex == 0 || _selectedTabIndex == 2) {
//       Get.to(() => DeliveryFeeScreen());
//     } else if (_selectedTabIndex == 1) {
//       Get.to(() => AddressAddItemScreen());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedListView(
//         padding: EdgeInsets.all(20),
//         children: [
//           Gap(50),
//           // Top Bar
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               MyText(text: "Add new item", size: 18, weight: FontWeight.w600),
//               MyText(
//                 text: _selectedTabIndex == 1 ? "Step 1/4" : "Step 1/5",
//                 size: 14,
//                 color: kSubText,
//               ),
//             ],
//           ),
//           Gap(20),

//           // Upload Product Images
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: kWhite,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     CommonImageView(
//                       imagePath: Assets.imagesGallery,
//                       height: 40,
//                     ),
//                     Gap(12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         MyText(
//                           text: "Upload Product Images",
//                           size: 16,
//                           weight: FontWeight.w600,
//                         ),
//                         MyText(
//                           text: "Multiple images allowed",
//                           size: 12,
//                           color: kSubText,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 MyButton(
//                   height: 50,
//                   onTap: () {},
//                   buttonText: "Upload",
//                   backgroundColor: kPrimaryColor.withOpacity(0.2),
//                   fontColor: kPrimaryColor,
//                   width: 100,
//                 ),
//               ],
//             ),
//           ),
//           Gap(20),
//           // Title Field
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: kWhite,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 MyText(
//                   text: "Title",
//                   size: 14,
//                   color: kSubText,
//                   weight: FontWeight.w500,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Nike Jordan 6",
//                   size: 16,
//                   color: kBlack,
//                   weight: FontWeight.w500,
//                 ),
//               ],
//             ),
//           ),
//           Gap(20),

//           Container(
//             decoration: BoxDecoration(
//               color: kWhite,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 MyText(
//                   text: "Category",
//                   size: 14,
//                   paddingTop: 20,
//                   paddingLeft: 16,
//                   color: kSubText,
//                   weight: FontWeight.w500,
//                 ),
//                 CustomDropDown(
//                   hint: 'Footwear',
//                   items: const [
//                     'Footwear',
//                     'Mens Outfit',
//                     'Womens Outfit',
//                     'Children Outfit',
//                     'Jacket',
//                   ],
//                   selectedValue: _selectedCategory,
//                   onChanged: (value) {
//                     setState(() => _selectedCategory = value);
//                   },
//                   bgColor: Colors.white,
//                   labelText: "",
//                 ),
//               ],
//             ),
//           ),
//           Gap(20),

//           Container(
//             decoration: BoxDecoration(
//               color: kWhite,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 MyText(
//                   text: "Condition",
//                   size: 14,
//                   paddingTop: 20,
//                   paddingLeft: 16,
//                   color: kSubText,
//                   weight: FontWeight.w500,
//                 ),
//                 CustomDropDown(
//                   hint: 'used, good condition',
//                   items: const [
//                     'used, good condition',
//                     'new',
//                     'like new',
//                     'used, fair condition',
//                   ],
//                   selectedValue: _selectedCondition,
//                   onChanged: (value) {
//                     setState(() => _selectedCondition = value);
//                   },
//                   bgColor: Colors.white,
//                   labelText: "",
//                 ),
//               ],
//             ),
//           ),
//           Gap(20),
//           // Price Row
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   padding: EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: kWhite,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       MyText(
//                         text: "Price",
//                         size: 14,
//                         color: kSubText,
//                         weight: FontWeight.w500,
//                       ),
//                       Gap(8),
//                       MyText(
//                         text: "\$45.00",
//                         size: 16,
//                         color: kBlack,
//                         weight: FontWeight.w500,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Gap(12),
//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomDropDown(
//                       marginBottom: 0,
//                       hint: 'Per Day',
//                       items: const ['Per Day', 'Per Week', 'Per Month'],
//                       selectedValue: _selectedPriceType,
//                       onChanged: (value) {
//                         setState(() => _selectedPriceType = value);
//                       },
//                       bgColor: Colors.white,
//                       labelText: " ",
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Gap(10),
//           // Product Description
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               MyText(
//                 text: "Product Description",
//                 size: 14,
//                 color: kSubText,
//                 weight: FontWeight.w500,
//               ),
//               Gap(8),
//               MyTextField(
//                 controller: _descriptionController,
//                 hint: "Lorem ipsum dolor ist amet",
//                 hintColor: kBlack,
//                 radius: 12,
//                 backgroundColor: Colors.white,
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           Gap(10),
//           if (_showError)
//             Center(
//               child: MyText(
//                 textAlign: TextAlign.center,
//                 text: "Selection Required Please select a delivery option",
//                 size: 16,
//                 paddingBottom: 10,
//                 color: kredColor,
//                 weight: FontWeight.w500,
//               ),
//             ),
//           // Custom Tabs - Moved to bottom
//           Container(
//             padding: EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: kWhite,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Row(
//               children: List.generate(_tabs.length, (index) {
//                 final isSelected = _selectedTabIndex == index;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedTabIndex = index;
//                       });
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? kPrimaryColor.withOpacity(0.2)
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Center(
//                         child: MyText(
//                           text: _tabs[index],
//                           size: 13,
//                           weight: FontWeight.w600,
//                           color: isSelected ? kPrimaryColor : Color(0xFF9CA3AF),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//           Gap(20),

//           MyButton(
//             onTap: _handleContinue,
//             buttonText: "Continue",
//             fontColor: Colors.white,
//             height: 56,
//             radius: 28,
//             hasgrad: false,
//             fontSize: 17,
//           ),

//           //error meaasge
//           Gap(100),
//         ],
//       ),
//     );
//   }
// }

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/address_additem.dart';
import 'package:zip_peer/views/screens/add_item_module/delivery_item.dart';
import 'package:zip_peer/views/screens/add_item_module/pickup_avalibility.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class AddNewItemScreen extends StatefulWidget {
  const AddNewItemScreen({super.key});

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  int? _selectedTabIndex; // null = not selected, 0 = Delivery only, 1 = Pickup only, 2 = Enable Both
  final List<String> _tabs = ['Delivery only', 'Pickup only', 'Enable Both'];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'Footwear';
  String _selectedCondition = 'used, good condition';
  String _selectedPriceType = 'Per Day';

  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = 'Nike Jordan 6';
    _priceController.text = '\$45.00';
    _descriptionController.text = 'Lorem ipsum dolor ist amet';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_selectedTabIndex == null) {
      setState(() {
        _showError = true;
      });
      return;
    }

    // Navigate based on selection
    if (_selectedTabIndex == 0) {
      // Delivery only: Delivery Fee → Pickup Availability → Boost → Summary
      Get.to(() => DeliveryFeeScreen(), arguments: {'rentalType': 'delivery'});
    } else if (_selectedTabIndex == 1) {
      // Pickup only: Pickup Availability → Boost → Summary
      Get.to(() => PickupAvailabilityScreen(), arguments: {'rentalType': 'pickup'});
    } else if (_selectedTabIndex == 2) {
      // Enable Both: Delivery Fee → Pickup Availability → Boost → Summary
      Get.to(() => DeliveryFeeScreen(), arguments: {'rentalType': 'both'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Gap(50),
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(text: "Add new item", size: 18, weight: FontWeight.w600),
              MyText(
                text: _selectedTabIndex == 1 ? "Step 1/4" : "Step 1/5",
                size: 14,
                color: kSubText,
              ),
            ],
          ),
          Gap(20),

          // Upload Product Images
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesGallery,
                      height: 40,
                    ),
                    Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: "Upload Product Images",
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                        MyText(
                          text: "Multiple images allowed",
                          size: 12,
                          color: kSubText,
                        ),
                      ],
                    ),
                  ],
                ),
                MyButton(
                  height: 50,
                  onTap: () {},
                  buttonText: "Upload",
                  backgroundColor: kPrimaryColor.withOpacity(0.2),
                  fontColor: kPrimaryColor,
                  width: 100,
                ),
              ],
            ),
          ),
          Gap(20),
          // Title Field
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: "Title",
                  size: 14,
                  color: kSubText,
                  weight: FontWeight.w500,
                ),
                Gap(8),
                MyText(
                  text: "Nike Jordan 6",
                  size: 16,
                  color: kBlack,
                  weight: FontWeight.w500,
                ),
              ],
            ),
          ),
          Gap(20),

          Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: "Category",
                  size: 14,
                  paddingTop: 20,
                  paddingLeft: 16,
                  color: kSubText,
                  weight: FontWeight.w500,
                ),
                CustomDropDown(
                  hint: 'Footwear',
                  items: const [
                    'Footwear',
                    'Mens Outfit',
                    'Womens Outfit',
                    'Children Outfit',
                    'Jacket',
                  ],
                  selectedValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                  bgColor: Colors.white,
                  labelText: "",
                ),
              ],
            ),
          ),
          Gap(20),

          Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kBlack.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: "Condition",
                  size: 14,
                  paddingTop: 20,
                  paddingLeft: 16,
                  color: kSubText,
                  weight: FontWeight.w500,
                ),
                CustomDropDown(
                  hint: 'used, good condition',
                  items: const [
                    'used, good condition',
                    'new',
                    'like new',
                    'used, fair condition',
                  ],
                  selectedValue: _selectedCondition,
                  onChanged: (value) {
                    setState(() => _selectedCondition = value);
                  },
                  bgColor: Colors.white,
                  labelText: "",
                ),
              ],
            ),
          ),
          Gap(20),
          // Price Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: kWhite,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: "Price",
                        size: 14,
                        color: kSubText,
                        weight: FontWeight.w500,
                      ),
                      Gap(8),
                      MyText(
                        text: "\$45.00",
                        size: 16,
                        color: kBlack,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
              Gap(12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropDown(
                      marginBottom: 0,
                      hint: 'Per Day',
                      items: const ['Per Day', 'Per Week', 'Per Month'],
                      selectedValue: _selectedPriceType,
                      onChanged: (value) {
                        setState(() => _selectedPriceType = value);
                      },
                      bgColor: Colors.white,
                      labelText: " ",
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(10),
          // Product Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: "Product Description",
                size: 14,
                color: kSubText,
                weight: FontWeight.w500,
              ),
              Gap(8),
              MyTextField(
                controller: _descriptionController,
                hint: "Lorem ipsum dolor ist amet",
                hintColor: kBlack,
                radius: 12,
                backgroundColor: Colors.white,
                maxLines: 3,
              ),
            ],
          ),
          Gap(10),
          if (_showError)
            Center(
              child: MyText(
                textAlign: TextAlign.center,
                text: "Selection Required. Please select a delivery option",
                size: 16,
                paddingBottom: 10,
                color: kredColor,
                weight: FontWeight.w500,
              ),
            ),
          // Custom Tabs - Moved to bottom
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
                        _showError = false;
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
                          size: 13,
                          weight: FontWeight.w600,
                          color: isSelected ? kPrimaryColor : Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Gap(20),

          MyButton(
            onTap: _handleContinue,
            buttonText: "Continue",
            fontColor: Colors.white,
            height: 56,
            radius: 28,
            hasgrad: false,
            fontSize: 17,
          ),
          Gap(100),
        ],
      ),
    );
  }
}