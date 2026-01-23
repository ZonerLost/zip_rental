// // ignore_for_file: prefer_final_fields

// import 'package:bounce/bounce.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:zip_peer/constants/app_colors.dart';
// import 'package:zip_peer/constants/app_sizes.dart';
// import 'package:zip_peer/generated/assets.dart';
// import 'package:zip_peer/views/screens/home/item_detail/check_out.dart';
// import 'package:zip_peer/views/screens/home/item_detail/comments.dart';
// import 'package:zip_peer/views/widget/common_image_view_widget.dart';
// import 'package:zip_peer/views/widget/custom_animated_column.dart';
// import 'package:zip_peer/views/widget/my_button_new.dart';
// import 'package:zip_peer/views/widget/my_text_widget.dart';

// class ItemDetailsScreen extends StatefulWidget {
//   const ItemDetailsScreen({super.key});

//   @override
//   State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
// }

// class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
//   int _currentImageIndex = 2;
//   int _monthCount = 1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: kWhite,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       MyText(text: "€98.99", size: 24, weight: FontWeight.w700),
//                       MyText(text: "Total amount", size: 14, color: kSubText),
//                     ],
//                   ),
//                   Gap(20),
//                   Expanded(
//                     child: MyButton(
//                       onTap: () {
//                         Get.to(() => const CheckoutScreen());
//                       },
//                       buttonText: "Book Now",
//                       height: 56,
//                       radius: 30,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: AnimatedListView(
//         padding: EdgeInsets.all(10),
//         children: [
//           Gap(50),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Bounce(
//                 onTap: () => Get.back(),
//                 child: Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: kWhite,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.arrow_back, size: 24),
//                 ),
//               ),
//               Bounce(
//                 onTap: () {},
//                 child: CommonImageView(
//                   imagePath: Assets.imagesHeartIcon,
//                   height: 50,
//                 ),
//               ),
//             ],
//           ),

//           Gap(20),
//           Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: CommonImageView(
//                   height: 350,
//                   width: double.infinity,
//                   radius: 25,
//                   imagePath: Assets.imagesShoes1,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               // Top bar
//               Positioned(
//                 top: 20,
//                 left: 30,
//                 right: 30,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: List.generate(3, (i) {
//                         return Container(
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           width: i == 0 ? 25 : 8,
//                           height: 6,
//                           decoration: BoxDecoration(
//                             color: i == 0 ? kWhite : kWhite,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         );
//                       }),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 16,
//                       ),
//                       decoration: BoxDecoration(
//                         color: kWhite,
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       child: MyText(
//                         text: "$_currentImageIndex/5",
//                         size: 14,
//                         color: kBlack,
//                         weight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Image indicator
//               Positioned(
//                 bottom: 10,
//                 left: 20,
//                 right: 20,
//                 child: Container(
//                   margin: EdgeInsets.symmetric(vertical: 10),
//                   padding: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: kWhite,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Bounce(
//                         onTap: () {
//                           if (_monthCount > 1) {
//                             setState(() {
//                               _monthCount--;
//                             });
//                           }
//                         },
//                         child: CommonImageView(
//                           imagePath: Assets.imagesMinusItemDetail,
//                           height: 50,
//                         ),
//                       ),
//                       MyText(
//                         text: "${_monthCount.toString().padLeft(2, '0')} Month",
//                         size: 18,
//                         weight: FontWeight.w600,
//                       ),
//                       Bounce(
//                         onTap: () {
//                           setState(() {
//                             _monthCount++;
//                           });
//                         },
//                         child: CommonImageView(
//                           imagePath: Assets.imagesAddItemDetail,
//                           height: 50,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Gap(10),
//           // Details section
//           Padding(
//             padding: AppSizes.DEFAULT,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         spacing: 5,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           MyText(
//                             text: "Nike's Jordan 3310",
//                             size: 24,
//                             weight: FontWeight.w700,
//                           ),
//                           Gap(8),
//                           MyText(
//                             text: "20 Times rented | used, like new",
//                             size: 14,
//                             color: kSubText,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         MyText(
//                           text: "\$49.99",
//                           size: 20,
//                           weight: FontWeight.w700,
//                         ),
//                         MyText(text: "/ month", size: 14, color: kSubText),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Gap(20),
//                 // Owner info
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: kWhite,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           CommonImageView(
//                             imagePath: Assets.imagesChatAvatar,
//                             height: 40,
//                           ),
//                           Gap(12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               MyText(
//                                 text: "Christopher Henry",
//                                 size: 16,
//                                 weight: FontWeight.w600,
//                               ),
//                               Gap(4),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.star,
//                                     size: 16,
//                                     color: Colors.amber,
//                                   ),
//                                   Gap(4),
//                                   MyText(
//                                     text: "4.7 ratings",
//                                     size: 14,
//                                     color: kBlack,
//                                   ),
//                                   Gap(12),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Bounce(
//                         onTap: () {
//                           Get.to(() => const CommentsScreen());
//                         },
//                         child: CommonImageView(
//                           imagePath: Assets.imagesCommentsNewIcon,
//                           height: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Gap(20),
//                 MyText(
//                   text:
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Ut enim ad minim veniam, quis nostrud exercitation",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text:
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Ut enim ad minim veniam, quis nostrud exercitation",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text:
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Ut enim ad minim veniam, quis nostrud exercitation",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text:
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Ut enim ad minim veniam, quis nostrud exercitation",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text:
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Ut enim ad minim veniam, quis nostrud exercitation",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text:
//                       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(8),
//                 MyText(
//                   text: "Ut enim ad minim veniam, quis nostrud exercitation",
//                   size: 14,
//                   color: kSubText,
//                 ),
//                 Gap(50),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: prefer_final_fields

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/home/item_detail/check_out.dart';
import 'package:zip_peer/views/screens/home/item_detail/comments.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _currentImageIndex = 2;
  int _monthCount = 1;
  String? _selectedOption; // null = nothing selected
  bool _showSelectDeliveryError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(text: "€98.99", size: 24, weight: FontWeight.w700),
                      MyText(text: "Total amount", size: 14, color: kSubText),
                    ],
                  ),
                  Gap(20),
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        if (_selectedOption == null) {
                          setState(() {
                            _showSelectDeliveryError = true;
                          });
                        } else {
                          Get.to(() => const CheckoutScreen());
                        }
                      },
                      buttonText: "Book Now",
                      height: 56,
                      radius: 30,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AnimatedListView(
        padding: EdgeInsets.all(10),
        children: [
          Gap(50),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bounce(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, size: 24),
                ),
              ),
              Bounce(
                onTap: () {},
                child: CommonImageView(
                  imagePath: Assets.imagesHeartIcon,
                  height: 50,
                ),
              ),
            ],
          ),

          Gap(20),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: CommonImageView(
                  height: 350,
                  width: double.infinity,
                  radius: 25,
                  imagePath: Assets.imagesShoes1,
                  fit: BoxFit.cover,
                ),
              ),
              // Top bar
              Positioned(
                top: 20,
                left: 30,
                right: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(3, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == 0 ? 25 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == 0 ? kWhite : kWhite,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: MyText(
                        text: "$_currentImageIndex/5",
                        size: 14,
                        color: kBlack,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Image indicator
              Positioned(
                bottom: 10,
                left: 20,
                right: 20,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Bounce(
                        onTap: () {
                          if (_monthCount > 1) {
                            setState(() {
                              _monthCount--;
                            });
                          }
                        },
                        child: CommonImageView(
                          imagePath: Assets.imagesMinusItemDetail,
                          height: 50,
                        ),
                      ),
                      MyText(
                        text: "${_monthCount.toString().padLeft(2, '0')} Month",
                        size: 18,
                        weight: FontWeight.w600,
                      ),
                      Bounce(
                        onTap: () {
                          setState(() {
                            _monthCount++;
                          });
                        },
                        child: CommonImageView(
                          imagePath: Assets.imagesAddItemDetail,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Gap(10),
          // Details section
          Padding(
            padding: AppSizes.DEFAULT,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: "Nike's Jordan 3310",
                            size: 24,
                            weight: FontWeight.w700,
                          ),
                          Gap(8),
                          MyText(
                            text: "20 Times rented | used, like new",
                            size: 14,
                            color: kSubText,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText(
                          text: "\$49.99",
                          size: 20,
                          weight: FontWeight.w700,
                        ),
                        MyText(text: "/ month", size: 14, color: kSubText),
                      ],
                    ),
                  ],
                ),
                Gap(20),
                // Owner info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CommonImageView(
                            imagePath: Assets.imagesChatAvatar,
                            height: 40,
                          ),
                          Gap(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: "Christopher Henry",
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                              Gap(4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  Gap(4),
                                  MyText(
                                    text: "4.7 ratings",
                                    size: 14,
                                    color: kBlack,
                                  ),
                                  Gap(12),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Bounce(
                        onTap: () {
                          Get.to(() => const CommentsScreen());
                        },
                        child: CommonImageView(
                          imagePath: Assets.imagesCommentsNewIcon,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(20),
                MyText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text: "Ut enim ad minim veniam, quis nostrud exercitation",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text: "Ut enim ad minim veniam, quis nostrud exercitation",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text: "Ut enim ad minim veniam, quis nostrud exercitation",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text: "Ut enim ad minim veniam, quis nostrud exercitation",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text: "Ut enim ad minim veniam, quis nostrud exercitation",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                  size: 14,
                  color: kSubText,
                ),
                Gap(8),
                MyText(
                  text: "Ut enim ad minim veniam, quis nostrud exercitation",
                  size: 14,
                  color: kSubText,
                ),
                Gap(20),

                // Delivery Options Buttons
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: MyButton(
                        onTap: () {
                          setState(() {
                            _selectedOption = "delivery";
                            _showSelectDeliveryError = false;
                          });
                        },
                        buttonText: "Delivery only",
                        height: 50,
                        radius: 30,
                        fontSize: 14,
                        backgroundColor: _selectedOption == "delivery"
                            ? kPrimaryColor
                            : kWhite,
                        fontColor: _selectedOption == "delivery"
                            ? kWhite
                            : kBlack,
                      ),
                    ),
                    Expanded(
                      child: MyButton(
                        onTap: () {
                          setState(() {
                            _selectedOption = "pickup";
                            _showSelectDeliveryError = false;
                          });
                        },
                        buttonText: "Pickup only",
                        height: 50,
                        radius: 30,
                        fontSize: 14,
                        backgroundColor: _selectedOption == "pickup"
                            ? kPrimaryColor
                            : kWhite,
                        fontColor: _selectedOption == "pickup"
                            ? kWhite
                            : kBlack,
                      ),
                    ),

                    Expanded(
                      child: MyButton(
                        onTap: () {
                          setState(() {
                            _selectedOption = "both";
                            _showSelectDeliveryError = false;
                          });
                        },
                        buttonText: "Enable both",
                        height: 50,
                        radius: 30,
                        fontSize: 14,
                        backgroundColor: _selectedOption == "both"
                            ? kPrimaryColor
                            : kWhite,
                        fontColor: _selectedOption == "both" ? kWhite : kBlack,
                      ),
                    ),
                  ],
                ),

                // Error message
                if (_showSelectDeliveryError) Gap(8),
                if (_showSelectDeliveryError)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: kredColor, size: 30),
                      Gap(8),
                      MyText(
                        text: "Please Select the Delivery Option",
                        size: 16,
                        color: kredColor,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),

                Gap(50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
