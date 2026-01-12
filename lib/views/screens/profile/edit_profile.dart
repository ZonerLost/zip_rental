// // ignore_for_file: prefer_const_constructors
// import 'package:bounce/bounce.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:zip_peer/constants/app_colors.dart';
// import 'package:zip_peer/generated/assets.dart';
// import 'package:zip_peer/views/widget/common_image_view_widget.dart';
// import 'package:zip_peer/views/widget/my_button_new.dart';
// import 'package:zip_peer/views/widget/my_text_widget.dart';
// import 'package:zip_peer/views/widget/my_textfeild.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final TextEditingController fullNameController = TextEditingController(
//     text: "Chris Henry",
//   );
//   final TextEditingController emailController = TextEditingController(
//     text: "christop234@gmail.com",
//   );
//   final TextEditingController phoneController = TextEditingController(text: "");

//   final FocusNode _focusNodeName = FocusNode();
//   final FocusNode _focusNodeEmail = FocusNode();
//   final FocusNode _focusNodePhone = FocusNode();

//   @override
//   void dispose() {
//     fullNameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     _focusNodeName.dispose();
//     _focusNodeEmail.dispose();
//     _focusNodePhone.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             MyButton(
//               height: 60,
//               buttonText: "Update",
//               onTap: () {},
//               backgroundColor: kPrimaryColor,
//               fontColor: kWhite,
//               radius: 30,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//             const Gap(50),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Gap(50),

//               // Header
//               Row(
//                 children: [
//                   Bounce(
//                     onTap: () => Get.back(),
//                     child: CommonImageView(
//                       imagePath: Assets.imagesBack,
//                       height: 50,
//                     ),
//                   ),
//                   const Gap(10),
//                   MyText(
//                     text: "Edit Profile",
//                     size: 18,
//                     color: kBlack,
//                     weight: FontWeight.w600,
//                   ),
//                 ],
//               ),

//               const Gap(40),

//               // Profile Photo Section
//               Center(
//                 child: Column(
//                   children: [
//                     CommonImageView(
//                       imagePath: Assets.imagesUpload,
//                       height: 120,
//                       width: 120,
//                     ),
//                     const Gap(24),
//                     MyText(
//                       text: "Upload Profile Photo",
//                       size: 18,
//                       color: kBlack,
//                       weight: FontWeight.w500,
//                     ),
//                     const Gap(12),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         spacing: 20,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: MyButton(
//                               buttonText: "Remove Photo",
//                               onTap: () {},
//                               hasgrad: false,

//                               backgroundColor: kWhite,
//                               fontColor: kSubText2,
//                               radius: 12,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           Expanded(
//                             child: MyButton(
//                               buttonText: "Change Photo",
//                               onTap: () {},
//                               hasgrad: false,
//                               backgroundColor: kPrimaryColor.withOpacity(0.2),
//                               fontColor: kPrimaryColor,
//                               radius: 12,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Gap(40),

//               // Personal Information Section
//               MyText(
//                 text: "PERSONAL INFORMATION",
//                 size: 12,

//                 color: kBlack.withOpacity(0.5),
//                 weight: FontWeight.w600,
//                 letterSpacing: 1.5,
//               ),

//               const Gap(20),

//               // Full Name Field
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   MyTextField(
//                     label: "Full name",
//                     labelColor: kSubText2,
//                     hint: "Full Name",
//                     hintColor: kBlack.withOpacity(0.4),
//                     controller: fullNameController,
//                     focusNode: _focusNodeName,
//                     radius: 25,
//                     onChanged: (value) => setState(() {}),
//                   ),
//                 ],
//               ),

//               MyTextField(
//                 label: "Email address",
//                 labelColor: kSubText2,
//                 hint: "Email address",
//                 hintColor: kBlack.withOpacity(0.4),
//                 controller: emailController,
//                 focusNode: _focusNodeEmail,
//                 radius: 25,
//                 onChanged: (value) => setState(() {}),
//               ),

//               // Phone Number Field
//               MyTextField(
//                 label: "Phone Number",
//                 labelColor: kSubText2,
//                 hint: "+123456789",
//                 hintColor: kBlack.withOpacity(0.4),
//                 controller: phoneController,
//                 focusNode: _focusNodePhone,
//                 radius: 25,
//                 onChanged: (value) => setState(() {}),
//               ),

//               MyTextField(
//                 label: "Country",
//                 labelColor: kSubText2,
//                 hint: "United States of America",
//                 hintColor: kBlack.withOpacity(0.4),

//                 radius: 25,
//                 onChanged: (value) => setState(() {}),
//               ),
//               MyTextField(
//                 maxLines: 4,
//                 label: "Address",
//                 labelColor: kSubText2,
//                 hint: "Lorem ipsum dolor ist amet",
//                 hintColor: kBlack.withOpacity(0.4),

//                 radius: 25,
//                 onChanged: (value) => setState(() {}),
//               ),

//               const Gap(100),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: prefer_const_constructors
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController(
    text: "Chris Henry",
  );
  final TextEditingController emailController = TextEditingController(
    text: "christop234@gmail.com",
  );
  final TextEditingController phoneController = TextEditingController(text: "");

  final FocusNode _focusNodeName = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePhone = FocusNode();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _focusNodeName.dispose();
    _focusNodeEmail.dispose();
    _focusNodePhone.dispose();
    super.dispose();
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        MyText(text: value, size: 18, color: kBlack, weight: FontWeight.w700),
        const Gap(4),
        MyText(
          text: label,
          size: 12,
          color: kSubText2,
          weight: FontWeight.w500,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              height: 60,
              buttonText: "Update",
              onTap: () {},
              backgroundColor: kPrimaryColor,
              fontColor: kWhite,
              radius: 30,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const Gap(50),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(50),

              // Header
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
                  MyText(
                    text: "Edit Profile",
                    size: 18,
                    color: kBlack,
                    weight: FontWeight.w600,
                  ),
                ],
              ),

              const Gap(40),

              // Profile Photo Section
              Center(
                child: Column(
                  children: [
                    CommonImageView(
                      imagePath: Assets.imagesUpload,
                      height: 120,
                      width: 120,
                    ),
                    const Gap(24),
                    MyText(
                      text: "Upload Profile Photo",
                      size: 18,
                      color: kBlack,
                      weight: FontWeight.w500,
                    ),
                    const Gap(12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MyButton(
                              buttonText: "Remove Photo",
                              onTap: () {},
                              hasgrad: false,
                              backgroundColor: kWhite,
                              fontColor: kSubText2,
                              radius: 12,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: MyButton(
                              buttonText: "Change Photo",
                              onTap: () {},
                              hasgrad: false,
                              backgroundColor: kPrimaryColor.withOpacity(0.2),
                              fontColor: kPrimaryColor,
                              radius: 12,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // Statistics Section - First Line
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBlack.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Times Rented\nOut", "24"),
                        Container(
                          height: 60,
                          width: 1,
                          color: kBlack.withOpacity(0.3),
                        ),
                        _buildStatItem("Times Rented\nFrom Others", "18"),
                        Container(
                          height: 60,
                          width: 1,
                          color: kBlack.withOpacity(0.3),
                        ),
                        _buildStatItem("Items\nListed", "12"),
                        Container(
                          height: 60,
                          width: 1,
                          color: kBlack.withOpacity(0.3),
                        ),
                        _buildStatItem("Overall\nRating", "4.8 "),
                      ],
                    ),
                    const Gap(20),
                    // Status / Badge - Second Line
                    Bounce(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.2),

                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kPrimaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: kPrimaryColor,
                              size: 30,
                            ),
                            const Gap(6),
                            MyText(
                              text: "Trusted Member",
                              size: 14,
                              color: kPrimaryColor,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(40),

              // Personal Information Section
              MyText(
                text: "PERSONAL INFORMATION",
                size: 12,
                color: kBlack.withOpacity(0.5),
                weight: FontWeight.w600,
                letterSpacing: 1.5,
              ),

              const Gap(20),

              // Full Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyTextField(
                    label: "Full name",
                    labelColor: kSubText2,
                    hint: "Full Name",
                    hintColor: kBlack.withOpacity(0.4),
                    controller: fullNameController,
                    focusNode: _focusNodeName,
                    radius: 25,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),

              MyTextField(
                label: "Email address",
                labelColor: kSubText2,
                hint: "Email address",
                hintColor: kBlack.withOpacity(0.4),
                controller: emailController,
                focusNode: _focusNodeEmail,
                radius: 25,
                onChanged: (value) => setState(() {}),
              ),

              // Phone Number Field
              MyTextField(
                label: "Phone Number",
                labelColor: kSubText2,
                hint: "+123456789",
                hintColor: kBlack.withOpacity(0.4),
                controller: phoneController,
                focusNode: _focusNodePhone,
                radius: 25,
                onChanged: (value) => setState(() {}),
              ),

              MyTextField(
                label: "Country",
                labelColor: kSubText2,
                hint: "United States of America",
                hintColor: kBlack.withOpacity(0.4),
                radius: 25,
                onChanged: (value) => setState(() {}),
              ),
              MyTextField(
                maxLines: 4,
                label: "Address",
                labelColor: kSubText2,
                hint: "Lorem ipsum dolor ist amet",
                hintColor: kBlack.withOpacity(0.4),
                radius: 25,
                onChanged: (value) => setState(() {}),
              ),

              const Gap(100),
            ],
          ),
        ),
      ),
    );
  }
}
